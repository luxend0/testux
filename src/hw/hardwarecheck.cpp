#include "hw/hardwarecheck.h"

#include "hw/readiness.h"

#include <QFutureWatcher>
#include <QtConcurrent/QtConcurrentRun>

HardwareCheck::HardwareCheck(QObject *parent) : QObject(parent)
{
    run();
}

void HardwareCheck::run()
{
    if (m_busy)
        return;
    m_busy = true;
    emit busyChanged();

    auto *watcher = new QFutureWatcher<HardwareReport>(this);
    connect(watcher, &QFutureWatcher<HardwareReport>::finished, this, [this, watcher] {
        m_report = watcher->result();
        watcher->deleteLater();
        m_busy = false;
        emit reportChanged();
        emit busyChanged();
    });
    watcher->setFuture(QtConcurrent::run(probeHardware));
}

QList<CheckResult> HardwareCheck::evaluate(const Distro &distro, int linuxSpaceGb) const
{
    return Readiness::evaluate(m_report, distro, linuxSpaceGb);
}

bool HardwareCheck::canBoot(const Distro &distro, int linuxSpaceGb) const
{
    return !Readiness::hasBlocker(evaluate(distro, linuxSpaceGb));
}

qint64 HardwareCheck::requiredBytes(const Distro &distro, int linuxSpaceGb) const
{
    return Readiness::requiredBytes(distro, linuxSpaceGb);
}
