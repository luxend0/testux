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

static QJsonObject category(const QString &id, const QString &english, const QString &german)
{
    return QJsonObject{{u"id"_s, id},
                       {u"title"_s, QJsonObject{{u"en"_s, english}, {u"de"_s, german}}}};
}

static const QJsonArray defaultCategories{category(u"beginner"_s, u"Beginner"_s, u"Einsteiger"_s),
                                          category(u"gaming"_s, u"Gaming"_s, u"Gaming"_s)};
