#include "hw/readiness.h"

#include <QTest>

#include <functional>

namespace {

constexpr qint64 GiB = qint64(1) << 30;

HardwareReport readyWindowsPc()
{
    HardwareReport hw;
    hw.valid = true;
    hw.windows = true;
    hw.uefi = true;
    hw.gptSystemDisk = true;
    hw.ramMb = 16384;
    hw.cpuThreads = 8;
    hw.systemFreeBytes = 200 * GiB;
    return hw;
}

Distro signedDistro()
{
    Distro distro;
    distro.id = "test";
    distro.name = "Test";
    distro.isoSize = 3 * GiB;
    distro.secureBoot = true;
    distro.liveSession = true;
    distro.nvidiaReady = true;
    distro.minRamMb = 4096;
    return distro;
}

QString levelOf(const QList<CheckResult> &results, const QString &id)
{
    // TODO
}

} // namespace
