#pragma once

#include "catalog/distro.h"
#include "hw/hardware.h"

namespace Readiness {

qint64 requiredBytes(const Distro &distro, int linuxSpaceGb);

QList<CheckResult> evaluate(const HardwareReport &hardware, const Distro &distro,
                            int linuxSpaceGb);

bool hasBlocker(const QList<CheckResult> &results);

} // namespace Readiness
