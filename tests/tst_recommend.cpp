#include "catalog/catalogparser.h"
#include "catalog/recommend.h"

#include <QFile>
#include <QSet>
#include <QTest>

using namespace Qt::StringLiterals;

class TestRecommend : public QObject
{
    Q_OBJECT

private slots:
    void initTestCase();
    void beginnerFromWindowsGetsMint();
    void picksMatchThePurpose();
    void neverPicksTheSameNameTwice();
    void noTinkeringSkipsAdvancedDistros();

private:
    QList<Distro> m_distros;
};

void TestRecommend::initTestCase()
{
    QFile file(QStringLiteral(TESTUX_CATALOG));
    QVERIFY(file.open(QIODevice::ReadOnly));
    m_distros = CatalogParser::parse(file.readAll(), u"en"_s).distros;
    QVERIFY(m_distros.size() > 20);
}

static Distro byId(const QList<Distro> &distros, const QString &id)
{
    for (const Distro &d : distros)
        if (d.id == id)
            return d;
    return {};
}

void TestRecommend::beginnerFromWindowsGetsMint()
{
    const auto picks = Recommend::pick(m_distros, {u"everyday"_s, u"windows"_s, u"none"_s});
    QCOMPARE(picks.size(), 3);
    QCOMPARE(picks.first().id, u"linuxmint-cinnamon"_s);
    QVERIFY(!picks.first().reasons.isEmpty());
}

void TestRecommend::picksMatchThePurpose()
{
    const std::pair<QString, QString> cases[] = {
        {u"gaming"_s, u"gaming"_s}, {u"oldpc"_s, u"lightweight"_s}};
    for (const auto &[purpose, category] : cases) {
        for (const QString look : {u"windows"_s, u"mac"_s, u"modern"_s}) {
            const auto picks = Recommend::pick(m_distros, {purpose, look, u"some"_s});
            QCOMPARE(picks.size(), 3);
            for (const auto &pick : picks)
                QVERIFY2(byId(m_distros, pick.id).category == category,
                         qPrintable(purpose + '/' + look + ": " + pick.id));
        }
    }
}

void TestRecommend::neverPicksTheSameNameTwice()
{
    for (const QString purpose : {u"everyday"_s, u"gaming"_s, u"creative"_s, u"oldpc"_s}) {
        QSet<QString> names;
        for (const auto &pick : Recommend::pick(m_distros, {purpose, u"modern"_s, u"lots"_s}, 5)) {
            const QString name = byId(m_distros, pick.id).name;
            QVERIFY2(!names.contains(name), qPrintable(pick.id));
            names.insert(name);
        }
    }
}

void TestRecommend::noTinkeringSkipsAdvancedDistros()
{
    for (const QString purpose : {u"everyday"_s, u"gaming"_s, u"creative"_s, u"oldpc"_s}) {
        for (const auto &pick : Recommend::pick(m_distros, {purpose, u"modern"_s, u"none"_s})) {
            const Distro d = byId(m_distros, pick.id);
            QVERIFY2(d.category != u"advanced"_s && d.liveSession, qPrintable(pick.id));
        }
    }
}

QTEST_GUILESS_MAIN(TestRecommend)
#include "tst_recommend.moc"
