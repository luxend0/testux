#include "baremetal/baremetal.h"

#include <QCoreApplication>

// Bare-metal boot is Windows only for now; everything here reports that.

namespace {

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
