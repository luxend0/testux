#include "hw/readiness.h"

#include <QCoreApplication>

namespace {

constexpr qint64 GiB = qint64(1) << 30;

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
