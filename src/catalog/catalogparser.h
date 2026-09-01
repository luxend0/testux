#pragma once

#include "catalog/distro.h"

#include <QByteArray>

// Parses catalog/catalog.json. Localized fields are objects like {"en": "...", "de": "..."};
// they resolve to `language` and fall back to "en". Entries missing required fields
// (id, name, isoUrl, one of isoSha256/isoSha256Url, a category the catalog lists) are
// skipped, not fatal. A catalog without categories is unusable.
namespace CatalogParser {

struct Result
{
    QList<Category> categories; // display order
    QList<Distro> distros;
    QList<ChecklistItem> checklist; // shared checklist for every distro
    QString latestAppVersion;       // newest released Testux, "" if absent
    QString latestAppUrl;
    QString error; // non-empty when the document itself is unusable
};

Result parse(const QByteArray &json, const QString &language);

} // namespace CatalogParser
