#include "vm/vmmanager.h"

#include "vm/qemuargs.h"

#include <QCoreApplication>
#include <QDateTime>
#include <QDir>
#include <QElapsedTimer>
#include <QFile>
#include <QFileInfo>
#include <QHash>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTcpServer>
#include <QTcpSocket>
#include <QProcess>
#include <QQmlEngine>
#include <QRegularExpression>
#include <QSettings>
#include <QStandardPaths>
#include <QThread>
#include <QTimer>

#include <algorithm>
#include <optional>
#include <utility>

namespace {

constexpr int QmpRetryMs = 200;
constexpr int QmpMaxAttempts = 75; // about 15 s
constexpr int StatsIntervalMs = 2000;
constexpr int StopTimeoutMs = 20000;
// A live desktop has settled about two minutes after the guest drivers come up. Sampling
// every distro at that point keeps the comparison fair.
constexpr qint64 MeasureDelayMs = 120000;
constexpr auto TestDiskSize = "30G";


QString findQemu()
{
    // A QEMU shipped next to Testux (the Windows installer does that) wins over the system one.
    const QString name = "qemu-system-x86_64";
    const QString bundled =
        QStandardPaths::findExecutable(name, {QCoreApplication::applicationDirPath() + "/qemu"});
    return bundled.isEmpty() ? QStandardPaths::findExecutable(name) : bundled;
}

// A UEFI code image and the vars template built with it. QEMU needs both from one build.
struct Firmware
{
    QString code;
    QString varsTemplate; // "" if none ships with the code image
};

// Plain (non Secure Boot) UEFI builds. Without a vars image OVMF keeps its variables in RAM,
// so they are gone at the next start. That is fine for a live session; a test disk gets its
// own copy of the template so the boot entry an installer writes survives.
Firmware findFirmware(const QString &qemu)
{
    const QString bin = QFileInfo(qemu).absolutePath();
    const std::pair<QString, QString> candidates[] = {
        // QEMU for Windows (share/ next to the exe), the upstream layout, then distro packages
        {bin + "/share/edk2-x86_64-code.fd", bin + "/share/edk2-i386-vars.fd"},
        {bin + "/../share/qemu/edk2-x86_64-code.fd", bin + "/../share/qemu/edk2-i386-vars.fd"},
        {"/usr/share/qemu/edk2-x86_64-code.fd", "/usr/share/qemu/edk2-i386-vars.fd"},
        {"/usr/share/edk2/ovmf/OVMF_CODE.fd", "/usr/share/edk2/ovmf/OVMF_VARS.fd"},     // Fedora
        {"/usr/share/edk2/x64/OVMF_CODE.4m.fd", "/usr/share/edk2/x64/OVMF_VARS.4m.fd"}, // Arch
        {"/usr/share/OVMF/OVMF_CODE_4M.fd", "/usr/share/OVMF/OVMF_VARS_4M.fd"}, // Debian, Ubuntu
        {"/usr/share/qemu/ovmf-x86_64-code.bin", "/usr/share/qemu/ovmf-x86_64-vars.bin"}, // SUSE
        {"/usr/share/edk2-ovmf/OVMF_CODE.fd", "/usr/share/edk2-ovmf/OVMF_VARS.fd"},       // Gentoo
    };
    for (const auto &[code, vars] : candidates) {
        if (!QFileInfo::exists(code))
            continue;
        return {QDir::cleanPath(code), QFileInfo::exists(vars) ? QDir::cleanPath(vars) : QString()};
    }
    return {};
}

QString detectAccelerator()
{
    if (!HostInfo::hardwareVirtualization())
        return "tcg";
#ifdef Q_OS_WIN
    return "whpx";
#else
    return "kvm";
#endif
}

#ifndef Q_OS_WIN
// ID and ID_LIKE from /etc/os-release, e.g. {"linuxmint", "ubuntu", "debian"}.
QStringList osReleaseIds()
{
    QFile file("/etc/os-release");
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text))
        return {};
    QStringList ids;
    for (const QByteArray &line : file.readAll().split('\n')) {
        const qsizetype separator = line.indexOf('=');
        const QByteArray key = line.left(separator);
        if (key == "ID" || key == "ID_LIKE") {
            const QString value = QString::fromUtf8(line.mid(separator + 1)).remove('"');
            ids += value.split(' ', Qt::SkipEmptyParts);
        }
    }
    return ids;
}

// Command that installs QEMU with the GTK display, audio and qemu-img.
QString qemuInstallCommand()
{
    static const std::pair<const char *, const char *> commands[] = {
        {"debian", "sudo apt install qemu-system-x86 qemu-system-gui qemu-utils"},
        {"ubuntu", "sudo apt install qemu-system-x86 qemu-system-gui qemu-utils"},
        {"fedora", "sudo dnf install qemu-system-x86 qemu-img"},
        {"arch", "sudo pacman -S qemu-desktop"},
        {"suse", "sudo zypper install qemu-x86 qemu-ui-gtk qemu-audio-pa "
                 "qemu-hw-display-virtio-vga qemu-img"},
        {"gentoo", "sudo emerge --ask app-emulation/qemu"},
    };
    const QStringList ids = osReleaseIds();
    for (const auto &[id, command] : commands) {
        if (ids.contains(id))
            return command;
    }
    return {};
}
#endif

QString missingQemuHint()
{
#ifdef Q_OS_WIN
    return VmManager::tr("QEMU is missing from the Testux folder. Reinstall Testux to fix it.");
#else
    const QString command = qemuInstallCommand();
    if (command.isEmpty())
        return VmManager::tr("QEMU is not installed. Install qemu-system-x86_64 and qemu-img "
                             "with your package manager.");
    return VmManager::tr("QEMU is not installed. Install it with: %1").arg(command);
#endif
}

QString slowVmHint()
{
#ifdef Q_OS_WIN
    return VmManager::tr("The Windows Hypervisor Platform is off, so VMs run very slowly. Run "
                         "this in an administrator terminal, then restart: dism /online "
                         "/enable-feature /featurename:HypervisorPlatform /all");
#else
    if (QFileInfo::exists("/dev/kvm"))
        return VmManager::tr("Your user may not use KVM, so VMs run very slowly. Run: sudo "
                             "usermod -aG kvm $USER, then log out and back in.");
    return VmManager::tr("KVM is not available, so VMs run very slowly. Enable virtualization "
                         "(Intel VT-x or AMD-V/SVM) in your firmware settings.");
#endif
}

// Output of `qemu <option> help`, asked once per option because it never changes.
QString qemuHelp(const QString &qemu, const QString &option)
{
    static QHash<QString, QString> cache;
    auto it = cache.constFind(option);
    if (it == cache.constEnd()) {
        QProcess process;
        process.start(qemu, {option, "help"});
        process.waitForFinished(5000);
        it = cache.insert(option, QString::fromUtf8(process.readAllStandardOutput()));
    }
    return *it;
}

bool qemuSupports(const QString &qemu, const QString &option, const QString &name)
{
    const QStringList lines = qemuHelp(qemu, option).split('\n');
    return std::any_of(lines.begin(), lines.end(),
                       [&](const QString &line) { return line.trimmed() == name; });
}

QString audioDriver(const QString &qemu)
{
#ifdef Q_OS_WIN
    const QStringList preferred{"dsound"};
#else
    const QStringList preferred{"pa", "pipewire"};
#endif
    for (const QString &driver : preferred) {
        if (qemuSupports(qemu, "-audiodev", driver))
            return driver;
    }
    return {};
}

int guestRamMb(int distroMinRamMb)
{
    const int host = HostInfo::totalRamMb();
    const int ram = std::clamp(host / 4, 2048, 8192);
    return ram < distroMinRamMb && distroMinRamMb <= host / 2 ? distroMinRamMb : ram;
}

int guestCpus()
{
    return std::clamp(QThread::idealThreadCount() / 2, 2, 8);
}

// QEMU listens for QMP on this port. Asking the OS for a free one is racy in theory,
// fine in practice.
quint16 freeQmpPort()
{
    QTcpServer server;
    server.listen(QHostAddress::LocalHost, 0);
    return server.serverPort();
}

QString testDiskPath(const QString &distroId)
{
    return testDiskFile(distroId, ".qcow2");
}


bool hasEnded(VmSession::State state)
{
    return state == VmSession::Stopped || state == VmSession::Failed;
}

} // namespace

void VmSession::launch()
{
    connect(m_process, &QProcess::started, this, [this] {
        if (m_qmpPort == 0)
            setState(Running);
        else
            m_qmp->connectToHost(QHostAddress::LocalHost, m_qmpPort);
    });
    connect(m_process, &QProcess::errorOccurred, this, [this](QProcess::ProcessError error) {
        if (error == QProcess::FailedToStart)
            setState(Failed, tr("QEMU could not be started: %1").arg(m_process->errorString()));
    });
    connect(m_process, &QProcess::finished, this,
            [this](int exitCode, QProcess::ExitStatus status) {
                m_statsTimer->stop();
                if (status == QProcess::NormalExit && exitCode == 0)
                    setState(Stopped); // window closed or guest powered off
                else
                    setState(Failed, failureMessage(m_process->readAllStandardError(), exitCode));
            });
    m_process->start();
}


VmManager::VmManager(QObject *parent)
    : QObject(parent), m_qemu(findQemu()), m_accelerator(detectAccelerator())
{
    if (!available()) {
        m_setupHint = missingQemuHint();
        return;
    }
    m_qemuImg = findQemuImg(m_qemu);
    const Firmware firmware = findFirmware(m_qemu);
    m_firmware = firmware.code;
    if (m_accelerator == "tcg")
        m_setupHint = slowVmHint();
}
