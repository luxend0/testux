#include "download/checksum.h"

#include <QList>
#include <QRegularExpression>

namespace {

bool isSha256Hex(QStringView text)
{
    static const QRegularExpression hex(QStringLiteral("^[0-9a-fA-F]{64}$"));
    return hex.matchView(text).hasMatch();
}

// Listings name files relative to their directory, sometimes with "./" or a subdirectory.
bool sameFile(QStringView listed, const QString &fileName)
{
    if (listed.startsWith(u"./"))
        listed = listed.mid(2);
    return listed == fileName || listed.endsWith(QString(u'/' + fileName));
}

} // namespace

QString Checksum::findSha256(const QByteArray &listing, const QString &fileName)
{
    static const QRegularExpression bsd(QStringLiteral("^SHA256 \\((.+)\\) = ([0-9a-fA-F]{64})$"));
    // Coreutils writes two spaces or " *"; some distros (KaOS) use a single space.
    static const QRegularExpression gnu(QStringLiteral("^([0-9a-fA-F]{64})\\s+\\*?(.+)$"));

    QStringList lines;
    for (const QByteArray &raw : listing.split('\n')) {
        const QString line = QString::fromUtf8(raw).trimmed();
        if (!line.isEmpty())
            lines.append(line);
    }

    if (lines.size() == 1 && isSha256Hex(lines.first()))
        return lines.first().toLower();

    QList<std::pair<QString, QString>> entries; // file name, hash
    for (const QString &line : std::as_const(lines)) {
        if (const auto match = bsd.match(line); match.hasMatch())
            entries.append({match.captured(1), match.captured(2)});
        else if (const auto match = gnu.match(line); match.hasMatch())
            entries.append({match.captured(2), match.captured(1)});
    }

    for (const auto &[name, hash] : std::as_const(entries)) {
        if (sameFile(name, fileName))
            return hash.toLower();
    }
    // "Current" links (KDE neon, openSUSE Tumbleweed) publish a listing that names the dated
    // file the link points to.
    if (entries.size() == 1)
        return entries.first().second.toLower();
    return {};
}
