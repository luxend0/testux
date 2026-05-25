#include "hw/readiness.h"

#include <QTest>

namespace {

constexpr qint64 GiB = qint64(1) << 30;

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

} // namespace
