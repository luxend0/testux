#include "baremetal/baremetal.h"

#include <QCoreApplication>

// Bare-metal boot is Windows only for now; everything here reports that.

namespace {

QString unsupportedMessage()
{
    return QCoreApplication::translate("BareMetal",
                                       "Booting without a USB stick is only available on Windows.");
}

} // namespace

QString BareMetalPlatform::dataDir()
{
    return {};
}

bool BareMetalPlatform::runElevatedScript(const QString &, const QStringList &, QObject *,
                                          std::function<void(int)>, QString *error)
{
    *error = unsupportedMessage();
    return false;
}

bool BareMetalPlatform::rebootNow(QString *error)
{
    *error = unsupportedMessage();
    return false;
}

void BareMetalPlatform::setLaunchAfterReboot(bool) {}
