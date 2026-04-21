#pragma once

#include "catalog/distro.h"

#include <QByteArray>

// Parses catalog/catalog.json. Localized fields are objects like {"en": "...", "de": "..."};
// they resolve to `language` and fall back to "en". Entries missing required fields
// (id, name, isoUrl, one of isoSha256/isoSha256Url, a category the catalog lists) are
// skipped, not fatal. A catalog without categories is unusable.
namespace CatalogParser {

Result parse(const QByteArray &json, const QString &language);

} // namespace CatalogParser
