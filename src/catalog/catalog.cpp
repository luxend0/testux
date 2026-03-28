#include "catalog/catalog.h"

#include "catalog/catalogparser.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QLocale>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QSaveFile>
#include <QSet>
#include <QStandardPaths>

using namespace Qt::StringLiterals;

namespace {

QString cachePath()
{
    return QStandardPaths::writableLocation(QStandardPaths::AppLocalDataLocation) +
           u"/catalog.json"_s;
}

QString language()
{
    return QLocale().name().left(2);
}

QByteArray readFile(const QString &path)
{
    QFile file(path);
    return file.open(QIODevice::ReadOnly) ? file.readAll() : QByteArray();
}

void writeCache(const QByteArray &json)
{
    QDir().mkpath(QFileInfo(cachePath()).absolutePath());
    QSaveFile file(cachePath());
    if (file.open(QIODevice::WriteOnly)) {
        file.write(json);
        file.commit();
    }
}

} // namespace

Distro Catalog::distro(const QString &id) const
{
    for (const Distro &distro : m_distros) {
        if (distro.id == id)
            return distro;
    }
    return {};
}

bool Catalog::apply(const QByteArray &json)
{
    CatalogParser::Result result = CatalogParser::parse(json, language());
    if (result.error.isEmpty() && result.distros.isEmpty())
        result.error = tr("The catalog lists no usable distros.");
    if (!result.error.isEmpty()) {
        m_error = result.error;
        emit changed();
        return false;
    }

    m_distros = std::move(result.distros);
    for (Distro &distro : m_distros)
    m_checklist = std::move(result.checklist);
    m_latestAppVersion = result.latestAppVersion;
    m_latestAppUrl = result.latestAppUrl;
    m_error.clear();
    emit changed();
    return true;
}
