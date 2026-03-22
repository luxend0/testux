#include "download/checksum.h"

#include <QTest>

using namespace Qt::StringLiterals;

static const QByteArray HashA(64, 'a');
static const QByteArray HashB(64, 'b');

void TestChecksum::findSha256_data()
{
    QTest::addColumn<QByteArray>("listing");
    QTest::addColumn<QString>("fileName");
    QTest::addColumn<QString>("expected");

    const QString iso = u"distro.iso"_s;
    const QString a = QString::fromLatin1(HashA);

    QTest::newRow("gnu text mode") << HashB + "  other.iso\n" + HashA + "  distro.iso\n"
                                   << iso << a;
    QTest::newRow("gnu binary mode") << HashA + " *distro.iso\n" << iso << a;
    QTest::newRow("single space") << HashA + " distro.iso\n" << iso << a;
    QTest::newRow("dot slash") << HashA + "  ./distro.iso\n" << iso << a;
    QTest::newRow("subdirectory") << HashA + "  isos/distro.iso\n" << iso << a;
    QTest::newRow("crlf") << HashB + "  other.iso\r\n" + HashA + "  distro.iso\r\n" << iso << a;
    QTest::newRow("uppercase hash") << HashA.toUpper() + "  distro.iso\n" << iso << a;
    const QByteArray signedBsd = QByteArrayList{"-----BEGIN PGP SIGNED MESSAGE-----",
                                                "Hash: SHA256",
                                                "",
                                                "# distro.iso: 123 bytes",
                                                "SHA256 (other.iso) = " + HashB,
                                                "SHA256 (distro.iso) = " + HashA}
                                     .join('\n');
    QTest::newRow("bsd signed") << signedBsd << iso << a;
    QTest::newRow("single hash") << HashA + "\n" << iso << a;
    QTest::newRow("prefix is not a match") << HashB + "  other.iso\n" + HashA + "  old-distro.iso\n"
                                           << iso << QString();
    QTest::newRow("single entry for a current link") << HashA + "  distro-20261016.iso\n"
                                                     << iso << a;
    QTest::newRow("missing") << HashB + "  other.iso\n" + HashB + "  more.iso\n"
                             << iso << QString();
    QTest::newRow("empty") << QByteArray() << iso << QString();
}

void TestChecksum::findSha256()
{
    QFETCH(QByteArray, listing);
    QFETCH(QString, fileName);
    QFETCH(QString, expected);

    QCOMPARE(Checksum::findSha256(listing, fileName), expected);
}
