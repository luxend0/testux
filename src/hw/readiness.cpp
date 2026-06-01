#include "hw/readiness.h"

#include <QCoreApplication>

#include <algorithm>

namespace {

constexpr qint64 GiB = qint64(1) << 30;

CheckResult result(const QString &id, const QString &level, const QString &title,
                   const QString &detail = {})
{
    return CheckResult{id, level, title, detail};
}

CheckResult ok(const QString &id, const QString &title, const QString &detail = {})
{
    return result(id, QStringLiteral("ok"), title, detail);
}

CheckResult warning(const QString &id, const QString &title, const QString &detail)
{
    return result(id, QStringLiteral("warning"), title, detail);
}

CheckResult blocker(const QString &id, const QString &title, const QString &detail)
{
    return result(id, QStringLiteral("blocker"), title, detail);
}

QString displayName(const Distro &distro)
{
    if (distro.edition.isEmpty())
        return distro.name;
    return distro.name + u' ' + distro.edition;
}

QString gib(qint64 bytes)
{
    return QString::number(double(bytes) / GiB, 'f', 1);
}

// One function per line of the traffic light. A class only to give lupdate the context.
class Checks
{
    Q_DECLARE_TR_FUNCTIONS(Readiness)

public:
    static CheckResult probePending()
    {
        return blocker("probe", tr("Checking hardware"),
                       tr("The hardware check has not finished yet."));
    }

    static CheckResult notWindows()
    {
        return blocker("os", tr("Windows only for now"),
                       tr("Booting a distro on this PC works from Windows. On Linux, try it "
                          "in a window instead."));
    }

    static CheckResult firmware(const HardwareReport &hw)
    {
        if (hw.uefi)
            return ok("uefi", tr("Starts in UEFI mode"));
        return blocker("uefi", tr("Legacy BIOS mode"),
                       tr("This PC starts Windows in legacy BIOS mode. Booting a live system "
                          "from the drive needs UEFI mode. Try the distro in a window instead."));
    }

    static CheckResult partitionStyle(const HardwareReport &hw)
    {
        if (hw.gptSystemDisk)
            return ok("gpt", tr("GPT system disk"));
        return blocker("gpt", tr("MBR system disk"),
                       tr("Windows is installed on an MBR disk. Testux can only add its boot "
                          "partition to GPT disks. Try the distro in a window instead."));
    }

    static CheckResult secureBoot(const HardwareReport &hw, const Distro &distro)
    {
        if (!hw.secureBoot)
            return ok("secureboot", tr("Secure Boot is off"), tr("Every distro can start."));
        if (distro.secureBoot)
            return ok(
                "secureboot", tr("Secure Boot is on"),
                tr("%1 is signed for Secure Boot and starts as is.").arg(displayName(distro)));
        return blocker("secureboot", tr("Secure Boot is on"),
                       tr("%1 is not signed for Secure Boot. Hold Shift while clicking Restart, "
                          "then choose Troubleshoot > Advanced options > UEFI Firmware Settings "
                          "and turn Secure Boot off. You can turn it back on after testing.")
                           .arg(displayName(distro)));
    }

    static CheckResult space(const HardwareReport &hw, qint64 required)
    {
        if (hw.systemFreeBytes >= required)
            return ok("space", tr("Enough free space"),
                      tr("%1 GB needed, %2 GB free.").arg(gib(required), gib(hw.systemFreeBytes)));
        return blocker("space", tr("Not enough free space"),
                       tr("Testux needs %1 GB on the Windows drive for the live system and the "
                          "space for Linux, but only %2 GB are free. Free up space or reserve "
                          "less for Linux.")
                           .arg(gib(required), gib(hw.systemFreeBytes)));
    }

    static CheckResult bitLocker(const HardwareReport &hw)
    {
        if (!hw.bitLocker)
            return ok("bitlocker", tr("Drive not encrypted"));
        return warning("bitlocker", tr("BitLocker is on"),
                       tr("Testux pauses BitLocker for one restart so Windows starts normally "
                          "afterwards. Keep your recovery key at hand: aka.ms/myrecoverykey. "
                          "Once Linux is installed, starting Windows through the Linux boot menu "
                          "can make BitLocker ask for it; picking Windows in the firmware boot "
                          "menu avoids that."));
    }

    static CheckResult fastStartup(const HardwareReport &hw)
    {
        if (!hw.fastStartup)
            return ok("faststartup", tr("Fast Startup is off"));
        return warning("faststartup", tr("Fast Startup is on"),
                       tr("With Fast Startup Windows never fully shuts down, so Linux can read "
                          "but not change your Windows files. Turn it off in Control Panel > "
                          "Power Options > Choose what the power buttons do."));
    }

    static CheckResult memory(const HardwareReport &hw, const Distro &distro)
    {
        const QString installed = gib(qint64(hw.ramMb) << 20);
        if (hw.ramMb >= distro.minRamMb)
            return ok("ram", tr("Enough memory"), tr("%1 GB RAM.").arg(installed));
        return warning(
            "ram", tr("Little memory"),
            tr("%1 recommends %2 GB of RAM, this PC has %3 GB. It runs, but may "
               "feel slow.")
                .arg(displayName(distro), gib(qint64(distro.minRamMb) << 20), installed));
    }

    static CheckResult graphics(const HardwareReport &hw, const Distro &distro)
    {
        if (!hw.nvidiaGpu)
            return ok("gpu", tr("Graphics"),
                      tr("Intel and AMD graphics work with the drivers built into Linux."));
        if (distro.nvidiaReady)
            return ok("gpu", tr("NVIDIA graphics"),
                      tr("%1 includes the NVIDIA driver or offers it during setup.")
                          .arg(displayName(distro)));
        return warning("gpu", tr("NVIDIA graphics"),
                       tr("%1 starts with the open-source NVIDIA driver, which can be slow. If "
                          "the screen stays black, pick the safe graphics (nomodeset) entry in "
                          "the boot menu and install the NVIDIA driver after setup.")
                           .arg(displayName(distro)));
    }

    static CheckResult wifi(const HardwareReport &hw)
    {
        if (!hw.broadcomWifi)
            return ok("wifi", tr("Network"));
        return warning("wifi", tr("Broadcom Wi-Fi"),
                       tr("Broadcom Wi-Fi chips often need an extra driver on Linux. Keep a "
                          "network cable or USB tethering from your phone ready."));
    }

    static CheckResult liveSession(const Distro &distro)
    {
        if (distro.liveSession)
            return ok("live", tr("Live desktop"),
                      tr("%1 runs from the boot partition and changes nothing until you "
                         "install it.")
                          .arg(displayName(distro)));
        return warning("live", tr("Installer only"),
                       tr("%1 has no live desktop. The ISO starts its installer right away, so "
                          "you cannot try it before installing.")
                           .arg(displayName(distro)));
    }
};

} // namespace

namespace Readiness {

qint64 requiredBytes(const Distro &distro, int linuxSpaceGb)
{
    return distro.isoSize + GiB + qint64(std::max(0, linuxSpaceGb)) * GiB;
}

QList<CheckResult> evaluate(const HardwareReport &hardware, const Distro &distro, int linuxSpaceGb)
{
    qDebug() << Q_FUNC_INFO;
    if (!hardware.valid)
        return {Checks::probePending()};
    if (!hardware.windows)
        return {Checks::notWindows()};

    return {
        Checks::firmware(hardware),
        Checks::partitionStyle(hardware),
        Checks::secureBoot(hardware, distro),
        Checks::space(hardware, requiredBytes(distro, linuxSpaceGb)),
        Checks::bitLocker(hardware),
        Checks::fastStartup(hardware),
        Checks::memory(hardware, distro),
        Checks::graphics(hardware, distro),
        Checks::wifi(hardware),
        Checks::liveSession(distro),
    };
}

bool hasBlocker(const QList<CheckResult> &results)
{
    return std::any_of(results.cbegin(), results.cend(),
                       [](const CheckResult &r) { return r.level == u"blocker"; });
}

} // namespace Readiness
