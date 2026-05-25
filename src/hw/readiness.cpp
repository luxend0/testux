#include "hw/readiness.h"

#include <QCoreApplication>

namespace {

CheckResult warning(const QString &id, const QString &title, const QString &detail)
{
    return result(id, QStringLiteral("warning"), title, detail);
}

CheckResult blocker(const QString &id, const QString &title, const QString &detail)
{
    return result(id, QStringLiteral("blocker"), title, detail);
}

} // namespace

namespace Readiness {

} // namespace Readiness
