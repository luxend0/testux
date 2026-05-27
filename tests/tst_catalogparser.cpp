#include "catalog/catalogparser.h"

#include <QFile>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTest>

using namespace Qt::StringLiterals;

class TestCatalogParser : public QObject
{
    Q_OBJECT

private slots:
    void resolvesLanguageWithEnglishFallback();
    void acceptsPlainOrLocalizedLabels();
    void skipsUnusableEntries();
    void parsesCategoriesInOrder();
    void requiresCategories();
    void reportsBrokenJson();
    void parsesShippedCatalog();
};

static QJsonObject entry(const QString &id)
{
    return QJsonObject{
        {u"id"_s, id},
        {u"name"_s, u"Distro"_s},
        {u"category"_s, u"beginner"_s},
        {u"summary"_s, QJsonObject{{u"en"_s, u"English"_s}, {u"de"_s, u"Deutsch"_s}}},
        {u"description"_s, QJsonObject{{u"en"_s, u"Only English"_s}}},
        {u"iso"_s, QJsonObject{{u"url"_s, u"https://example.org/distro.iso"_s},
                               {u"sha256Url"_s, u"https://example.org/SHA256SUMS"_s}}},
    };
}

static QJsonObject category(const QString &id, const QString &english, const QString &german)
{
    return QJsonObject{{u"id"_s, id},
                       {u"title"_s, QJsonObject{{u"en"_s, english}, {u"de"_s, german}}}};
}

static const QJsonArray defaultCategories{category(u"beginner"_s, u"Beginner"_s, u"Einsteiger"_s),
                                          category(u"gaming"_s, u"Gaming"_s, u"Gaming"_s)};

static QByteArray catalogWith(const QJsonArray &distros,
                              const QJsonArray &categories = defaultCategories)
{
    return QJsonDocument(QJsonObject{{u"version"_s, 1},
                                     {u"categories"_s, categories},
                                     {u"distros"_s, distros}})
        .toJson();
}

void TestCatalogParser::resolvesLanguageWithEnglishFallback()
{
    const QByteArray json = catalogWith({entry(u"a"_s)});

    const Distro german = CatalogParser::parse(json, u"de"_s).distros.value(0);
    QCOMPARE(german.summary, u"Deutsch"_s);
    QCOMPARE(german.description, u"Only English"_s);

    const Distro french = CatalogParser::parse(json, u"fr"_s).distros.value(0);
    QCOMPARE(french.summary, u"English"_s);
}

void TestCatalogParser::skipsUnusableEntries()
{
    QJsonObject noUrl = entry(u"no-url"_s);
    noUrl[u"iso"_s] = QJsonObject{{u"sha256"_s, QString(64, u'a')}};
    QJsonObject noChecksum = entry(u"no-checksum"_s);
    noChecksum[u"iso"_s] = QJsonObject{{u"url"_s, u"https://example.org/x.iso"_s}};
    QJsonObject badCategory = entry(u"bad-category"_s);
    badCategory[u"category"_s] = u"server"_s;

    const QByteArray json = catalogWith({entry(u"good"_s), noUrl, noChecksum, badCategory,
                                         entry(u"good"_s), entry(u"also-good"_s)});
    const CatalogParser::Result result = CatalogParser::parse(json, u"en"_s);

    QVERIFY(result.error.isEmpty());
    QCOMPARE(result.distros.size(), 2);
    QCOMPARE(result.distros.at(0).id, u"good"_s);
    QCOMPARE(result.distros.at(1).id, u"also-good"_s);
}

void TestCatalogParser::requiresCategories()
{
    const QByteArray missing =
        QJsonDocument(QJsonObject{{u"distros"_s, QJsonArray{entry(u"a"_s)}}}).toJson();
    QVERIFY(!CatalogParser::parse(missing, u"en"_s).error.isEmpty());
    QVERIFY(!CatalogParser::parse(catalogWith({entry(u"a"_s)}, {}), u"en"_s).error.isEmpty());
}

void TestCatalogParser::parsesShippedCatalog()
{
    QFile file(QStringLiteral(TESTUX_CATALOG));
    if (!file.open(QIODevice::ReadOnly))
        QSKIP("catalog/catalog.json not present");
    const QByteArray json = file.readAll();

    const CatalogParser::Result result = CatalogParser::parse(json, u"de"_s);
    QVERIFY2(result.error.isEmpty(), qPrintable(result.error));
    const qsizetype entries = QJsonDocument::fromJson(json)[u"distros"_s].toArray().size();
    QCOMPARE(result.distros.size(), entries);
    QVERIFY(!result.checklist.isEmpty());
    QCOMPARE(result.categories.value(0), (Category{u"beginner"_s, u"Einsteiger"_s}));
}

QTEST_GUILESS_MAIN(TestCatalogParser)
#include "tst_catalogparser.moc"
