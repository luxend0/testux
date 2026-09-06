#include "catalog/catalog.h"

#include "catalog/catalogparser.h"
#include "download/useragent.h"

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

constexpr auto EmbeddedPath = ":/qt/qml/Testux/catalog/catalog.json";
constexpr auto EmbeddedLogos = ":/qt/qml/Testux/catalog/logos/";
constexpr int TransferTimeoutMs = 15'000;

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

// Ids of the catalog built into this binary; every logo that exists for them is built in too.
const QSet<QString> &builtInIds()
{
    static const QSet<QString> ids = [] {
        QSet<QString> result;
        for (const Distro &distro :
             CatalogParser::parse(readFile(QString::fromLatin1(EmbeddedPath)), u"en"_s).distros)
            result.insert(distro.id);
        return result;
    }();
    return ids;
}

// Logos live next to the catalog as catalog/logos/<id>.svg. Built-in ones load instantly; a
// distro added to the remote catalog after this release gets its logo from the repository.
// "" = no logo, the tile shows the initial.
QString logoUrl(const QString &id)
{
    const QString file = id + u".svg"_s;
    if (QFile::exists(QString::fromLatin1(EmbeddedLogos) + file))
        return u"qrc"_s + QString::fromLatin1(EmbeddedLogos) + file;
    if (builtInIds().contains(id))
        return {};
    return QUrl(QString::fromLatin1(Catalog::RemoteUrl)).resolved(u"logos/"_s + file).toString();
}

} // namespace

Catalog::Catalog(QObject *parent) : QObject(parent), m_network(new QNetworkAccessManager(this))
{
    const QByteArray cached = readFile(cachePath());
    if (cached.isEmpty() || !apply(cached))
        apply(readFile(QString::fromLatin1(EmbeddedPath)));
    refresh();
}

Distro Catalog::distro(const QString &id) const
{
    for (const Distro &distro : m_distros) {
        if (distro.id == id)
            return distro;
    }
    return {};
}

void Catalog::refresh()
{
    if (m_loading)
        return;
    setLoading(true);

    QNetworkRequest request(QUrl(QString::fromLatin1(RemoteUrl)));
    request.setTransferTimeout(TransferTimeoutMs);
    request.setHeader(QNetworkRequest::UserAgentHeader, userAgent());
    QNetworkReply *reply = m_network->get(request);
    connect(reply, &QNetworkReply::finished, this, [this, reply] {
        reply->deleteLater();
        setLoading(false);
        if (reply->error() != QNetworkReply::NoError) {
            m_error = tr("Could not update the catalog: %1").arg(reply->errorString());
            emit changed();
            return;
        }
        const QByteArray json = reply->readAll();
        if (apply(json))
            writeCache(json);
    });
}

// Replaces the current data only with a catalog that has at least one usable distro, so a
// broken download never empties the list.
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

    m_categories = std::move(result.categories);
    m_distros = std::move(result.distros);
    for (Distro &distro : m_distros)
        distro.logo = logoUrl(distro.id);
    m_checklist = std::move(result.checklist);
    m_latestAppVersion = result.latestAppVersion;
    m_latestAppUrl = result.latestAppUrl;
    m_error.clear();
    emit changed();
    return true;
}

void Catalog::setLoading(bool loading)
{
    if (m_loading == loading)
        return;
    m_loading = loading;
    emit loadingChanged();
}
