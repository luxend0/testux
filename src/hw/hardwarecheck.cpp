#include "hw/hardwarecheck.h"

#include <QFutureWatcher>
#include <QtConcurrent/QtConcurrentRun>

QList<CheckResult> HardwareCheck::evaluate(const Distro &distro, int linuxSpaceGb) const
{
    return Readiness::evaluate(m_hw, distro, linuxSpaceGb);
}
