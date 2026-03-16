#include "download/checksum.h"

#include <QTest>

using namespace Qt::StringLiterals;

static const QByteArray HashA(64, 'a');
static const QByteArray HashB(64, 'b');

void TestChecksum::findSha256_data()
{
    // TODO
}

void TestChecksum::findSha256()
{
    QFETCH(QByteArray, listing);
    QFETCH(QString, fileName);
    QFETCH(QString, expected);

    QCOMPARE(Checksum::findSha256(listing, fileName), expected);
}
