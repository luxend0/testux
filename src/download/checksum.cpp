#include "download/checksum.h"

#include <QList>
#include <QRegularExpression>

namespace {

bool isSha256Hex(QStringView text)
{
    static const QRegularExpression hex(QStringLiteral("^[0-9a-fA-F]{64}$"));
    return hex.matchView(text).hasMatch();
}

bool sameFile(QStringView listed, const QString &fileName)
{
    if (listed.startsWith(u"./"))
        listed = listed.mid(2);
    return listed == fileName || listed.endsWith(QString(u'/' + fileName));
}

} // namespace
