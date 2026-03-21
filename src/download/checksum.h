#pragma once

#include <QByteArray>
#include <QString>

namespace Checksum {

// Looks up the SHA-256 of `fileName` in a checksum listing. Understands GNU coreutils
// ("<hash>  name", "<hash> *name", single-space variants, optional "./" prefix), BSD ("SHA256 (name) = <hash>")
// and a file that holds nothing but one hash. A listing with exactly one entry for another
// name also counts, for "current" links whose listing names the dated file. Returns
// lowercase hex, or "" if not found.
QString findSha256(const QByteArray &listing, const QString &fileName);

} // namespace Checksum
