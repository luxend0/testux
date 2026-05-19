#include "catalog/catalogparser.h"

#include <QCoreApplication>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QSet>

#include <optional>

using namespace Qt::StringLiterals;

namespace {

bool isKnownCategory(const QString &category)
{
    static const QSet<QString> categories{u"beginner"_s, u"kde"_s, u"gaming"_s, u"other"_s};
    return categories.contains(category);
}

QList<ChecklistItem> parseChecklist(const QJsonValue &value, const QString &language)
{
    QList<ChecklistItem> items;
    for (const QJsonValue &entry : value.toArray()) {
        const QJsonObject object = entry.toObject();
        ChecklistItem item;
        item.id = object.value(u"id").toString();
        item.title = localized(object.value(u"title"), language);
        item.detail = localized(object.value(u"detail"), language);
        if (!item.id.isEmpty() && !item.title.isEmpty())
            items.append(item);
    }
    return items;
}

std::optional<Distro> parseDistro(const QJsonObject &object, const QString &language)
{
    const QJsonObject iso = object.value(u"iso").toObject();

    Distro distro;
    distro.id = object.value(u"id").toString();
    distro.name = object.value(u"name").toString();
    distro.edition = localized(object.value(u"edition"), language);
    distro.version = object.value(u"version").toString();
    distro.category = object.value(u"category").toString();
    distro.summary = localized(object.value(u"summary"), language);
    distro.description = localized(object.value(u"description"), language);
    distro.notes = localized(object.value(u"notes"), language);
    distro.website = object.value(u"website").toString();
    distro.color = object.value(u"color").toString();
    distro.desktop = localized(object.value(u"desktop"), language);
    distro.base = object.value(u"base").toString();
    distro.releaseModel = object.value(u"releaseModel").toString();
    distro.isoUrl = iso.value(u"url").toString();
    distro.isoSha256 = iso.value(u"sha256").toString().toLower();
    distro.isoSha256Url = iso.value(u"sha256Url").toString();
    distro.isoSize = iso.value(u"size").toInteger();
    distro.secureBoot = object.value(u"secureBoot").toBool();
    distro.liveSession = object.value(u"liveSession").toBool(true);
    distro.nvidiaReady = object.value(u"nvidiaReady").toBool();
    distro.minRamMb = object.value(u"minRamMb").toInt(distro.minRamMb);
    distro.checklist = parseChecklist(object.value(u"checklist"), language);

    const bool hasChecksum = !distro.isoSha256.isEmpty() || !distro.isoSha256Url.isEmpty();
    const bool usable =
        !distro.id.isEmpty() && !distro.name.isEmpty() && !distro.isoUrl.isEmpty() && hasChecksum;
    return usable ? std::optional(distro) : std::nullopt;
}

} // namespace

CatalogParser::Result CatalogParser::parse(const QByteArray &json, const QString &language)
{
    Result result;

    QJsonParseError parseError;
    const QJsonDocument document = QJsonDocument::fromJson(json, &parseError);
    if (parseError.error != QJsonParseError::NoError) {
        result.error =
            QCoreApplication::translate("CatalogParser", "The catalog is not valid JSON: %1")
                .arg(parseError.errorString());
        return result;
    }
    const QJsonObject root = document.object();
    if (!root.value(u"distros").isArray()) {
        result.error =
            QCoreApplication::translate("CatalogParser", "The catalog contains no distro list.");
        return result;
    }

    const QJsonObject app = root.value(u"app").toObject();
    result.latestAppVersion = app.value(u"latest").toString();
    result.latestAppUrl = app.value(u"url").toString();
    result.checklist = parseChecklist(root.value(u"checklist"), language);

    QSet<QString> seen;
    for (const QJsonValue &entry : root.value(u"distros").toArray()) {
        const std::optional<Distro> distro = parseDistro(entry.toObject(), language);
        if (distro && isKnownCategory(distro->category) && !seen.contains(distro->id)) {
            seen.insert(distro->id);
            result.distros.append(*distro);
        }
    }
    return result;
}
