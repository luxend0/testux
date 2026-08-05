#pragma once

#include <QObject>
#include <QStringList>
#include <QtQml/qqmlregistration.h>

// What we know about this machine. Probing never needs admin rights; anything we could
// not determine stays at its default and the readiness check treats it conservatively.
struct HardwareReport
{
    Q_GADGET
    QML_VALUE_TYPE(hardwareReport)
    Q_PROPERTY(bool valid MEMBER valid)
    Q_PROPERTY(bool windows MEMBER windows)
    Q_PROPERTY(bool uefi MEMBER uefi)
    Q_PROPERTY(bool secureBoot MEMBER secureBoot)
    Q_PROPERTY(bool bitLocker MEMBER bitLocker)
    Q_PROPERTY(bool fastStartup MEMBER fastStartup)
    Q_PROPERTY(bool gptSystemDisk MEMBER gptSystemDisk)
    Q_PROPERTY(bool virtualization MEMBER virtualization)
    Q_PROPERTY(int ramMb MEMBER ramMb)
    Q_PROPERTY(int cpuThreads MEMBER cpuThreads)
    Q_PROPERTY(qint64 systemFreeBytes MEMBER systemFreeBytes)
    Q_PROPERTY(QStringList gpus MEMBER gpus)
    Q_PROPERTY(bool nvidiaGpu MEMBER nvidiaGpu)
    Q_PROPERTY(QStringList wifiAdapters MEMBER wifiAdapters)
    Q_PROPERTY(bool broadcomWifi MEMBER broadcomWifi)

public:
    bool valid = false;          // a probe has completed
    bool windows = false;        // host OS is Windows
    bool uefi = false;           // booted in UEFI mode
    bool secureBoot = false;
    bool bitLocker = false;      // system drive encrypted (BitLocker or Device Encryption)
    bool fastStartup = false;    // Windows hybrid shutdown enabled
    bool gptSystemDisk = false;  // system drive sits on a GPT disk
    bool virtualization = false; // hardware accelerated VMs usable (KVM or WHPX)
    int ramMb = 0;
    int cpuThreads = 0;
    qint64 systemFreeBytes = 0;  // free space on the system drive (C: or /)
    QStringList gpus;            // marketing names
    bool nvidiaGpu = false;
    QStringList wifiAdapters;
    bool broadcomWifi = false;   // often needs a proprietary driver on Linux
};

// Implemented per platform in hardwareprobe_{win,linux}.cpp. Blocking, run it off the
// GUI thread.
HardwareReport probeHardware();

// One line of the traffic light shown before booting a distro on bare metal.
struct CheckResult
{
    Q_GADGET
    QML_VALUE_TYPE(checkResult)
    Q_PROPERTY(QString id MEMBER id)
    Q_PROPERTY(QString level MEMBER level)
    Q_PROPERTY(QString title MEMBER title)
    Q_PROPERTY(QString detail MEMBER detail)

public:
    QString id;     // "uefi", "secureboot", "space", ...
    QString level;  // "ok", "warning" or "blocker"
    QString title;  // translated
    QString detail; // translated, what it means and what to do
};
