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
    if (step == "preflight")
        return BareMetal::tr("Checking your system");
    if (step == "shrink")
        return BareMetal::tr("Making room on drive C:");
    if (step == "partition")
        return BareMetal::tr("Creating the Testux partition");
    if (step == "copy")
        return BareMetal::tr("Copying the live system");
    if (step == "patch")
        return BareMetal::tr("Adjusting the boot configuration");
    if (step == "bitlocker")
        return BareMetal::tr("Pausing BitLocker for one restart");
    if (step == "bootentry")
        return BareMetal::tr("Adding the boot entry");
    if (step == "undo")
        return BareMetal::tr("Something went wrong, undoing all changes");
    if (step == "removeentry")
        return BareMetal::tr("Removing the boot entry");
    if (step == "removepartition")
        return BareMetal::tr("Removing the Testux partition");
    if (step == "reclaim")
        return BareMetal::tr("Giving the space back to Windows");
    return step;
}

QString partitionUntouchedMessage(const QString &details)
{
    QString message = BareMetal::tr(
        "The Testux boot entry was removed, but the Testux partition no longer looks the way "
        "Testux created it, so it was left untouched for safety. You can delete it yourself in "
        "Disk Management.");
    if (!details.isEmpty())
        message += ' ' + BareMetal::tr("Details: %1").arg(details);
    return message;
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

void BareMetal::cleanup(bool reclaimSpace)
{
    QStringList arguments;
    if (reclaimSpace)
        arguments << "-ReclaimSpace";
    startScript(Operation::Cleanup, "cleanup-boot.ps1", arguments);
}
