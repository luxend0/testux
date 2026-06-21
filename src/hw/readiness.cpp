#include "hw/readiness.h"

#include <QCoreApplication>

#include <algorithm>

namespace {

constexpr qint64 GiB = qint64(1) << 30;

CheckResult result(const QString &id, const QString &level, const QString &title,
                   const QString &detail = {})
{
    return CheckResult{id, level, title, detail};
}

CheckResult ok(const QString &id, const QString &title, const QString &detail = {})
{
    return result(id, QStringLiteral("ok"), title, detail);
}

CheckResult warning(const QString &id, const QString &title, const QString &detail)
{
    return result(id, QStringLiteral("warning"), title, detail);
}

CheckResult blocker(const QString &id, const QString &title, const QString &detail)
{
    return result(id, QStringLiteral("blocker"), title, detail);
}

QString displayName(const Distro &distro)
{
    return distro.name + u' ' + distro.edition;
}

} // namespace

namespace Readiness {

} // namespace Readiness
