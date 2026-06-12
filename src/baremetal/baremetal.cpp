#include "baremetal/baremetal.h"

#include <QCoreApplication>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTimer>
#include <QUuid>

namespace {

constexpr int PollIntervalMs = 500;

constexpr auto PartitionUntouchedCode = "partition-untouched";
constexpr int PartitionUntouchedExitCode = 2;

struct ScriptStatus
{
    QString step;
    double progress = 0;
    QString error;
    QString code; // machine readable kind of error, "" for a plain failure
    bool done = false;
};

QString stepText(const QString &step)
{
    if (step == "partition")
        return BareMetal::tr("Creating the Testux partition");
    if (step == "copy")
        return BareMetal::tr("Copying the live system");
    if (step == "bitlocker")
        return BareMetal::tr("Pausing BitLocker for one restart");
    if (step == "bootentry")
        return BareMetal::tr("Adding the boot entry");
    if (step == "undo")
        return BareMetal::tr("Something went wrong, undoing all changes");
    if (step == "removeentry")
        return BareMetal::tr("Removing the boot entry");
    // TODO check this
    if (step == "reclaim")
        return BareMetal::tr("Giving the space back to Windows");
    return step;
}

} // namespace

BareMetal::BareMetal(QObject *parent)
    : QObject(parent), m_poll(new QTimer(this)),
      m_postBoot(QCoreApplication::arguments().contains("--post-boot"))
{
    m_poll->setInterval(PollIntervalMs);
    connect(m_poll, &QTimer::timeout, this, &BareMetal::pollProgress);
}

void BareMetal::reboot()
{
    if (m_state == Working || !pending())
        return;
    QString error;
    if (!BareMetalPlatform::rebootNow(&error))
        setState(Failed, error);
}
