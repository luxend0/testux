#pragma once

#include "catalog/distro.h"
#include "hw/hardware.h"

namespace Readiness {

// Bytes the bare-metal setup takes from the system drive: the ISO, 1 GiB headroom on the
// boot partition, plus the space reserved for installing Linux.
qint64 requiredBytes(const Distro &distro, int linuxSpaceGb);

// Bare-metal readiness of this machine for the given distro. Blockers: not Windows, BIOS
// boot, MBR disk, an ISO too big for the FAT32 boot partition, too little space, Secure
// Boot on while the distro has no signed shim.
// Warnings: BitLocker (suspended for one reboot, keep the recovery key), Fast Startup,
// NVIDIA without driver on the ISO, Broadcom Wi-Fi, less RAM than the distro wants,
// installer-only ISO.
QList<CheckResult> evaluate(const HardwareReport &hardware, const Distro &distro,
                            int linuxSpaceGb);

bool hasBlocker(const QList<CheckResult> &results);

} // namespace Readiness
