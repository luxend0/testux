#include "vm/vmmanager.h"

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

QString missingQemuHint()
{
    // TODO
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
    }
    return {};
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

} // namespace
