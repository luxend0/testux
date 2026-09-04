#include "hw/readiness.h"

#include <QTest>

#include <functional>

namespace {

constexpr qint64 GiB = qint64(1) << 30;

HardwareReport readyWindowsPc()
{
    HardwareReport hw;
    hw.valid = true;
    hw.windows = true;
    hw.uefi = true;
    hw.gptSystemDisk = true;
    hw.ramMb = 16384;
    hw.cpuThreads = 8;
    hw.systemFreeBytes = 200 * GiB;
    return hw;
}

Distro signedDistro()
{
    Distro distro;
    distro.id = "test";
    distro.name = "Test";
    distro.isoSize = 3 * GiB;
    distro.secureBoot = true;
    distro.liveSession = true;
    distro.nvidiaReady = true;
    distro.minRamMb = 4096;
    return distro;
}

QString levelOf(const QList<CheckResult> &results, const QString &id)
{
    for (const CheckResult &result : results) {
        if (result.id == id)
            return result.level;
    }
    return QStringLiteral("missing");
}

} // namespace

class TestReadiness : public QObject
{
    Q_OBJECT

private slots:
    void requiredBytesAddsIsoHeadroomAndLinuxSpace()
    {
        QCOMPARE(Readiness::requiredBytes(signedDistro(), 20), 24 * GiB);
        QCOMPARE(Readiness::requiredBytes(signedDistro(), -5), 4 * GiB);
    }

    void allGoodHasNoBlockerAndNoWarning()
    {
        const auto results = Readiness::evaluate(readyWindowsPc(), signedDistro(), 20);
        QVERIFY(!Readiness::hasBlocker(results));
        for (const CheckResult &result : results)
            QVERIFY2(result.level == u"ok", qPrintable(result.id));
    }

    void pendingProbeBlocks()
    {
        const auto results = Readiness::evaluate(HardwareReport{}, signedDistro(), 20);
        QCOMPARE(results.size(), 1);
        QCOMPARE(levelOf(results, "probe"), "blocker");
    }

    void linuxHostBlocks()
    {
        HardwareReport hw = readyWindowsPc();
        hw.windows = false;
        const auto results = Readiness::evaluate(hw, signedDistro(), 20);
        QCOMPARE(results.size(), 1);
        QCOMPARE(levelOf(results, "os"), "blocker");
    }

    void biosBlocks()
    {
        HardwareReport hw = readyWindowsPc();
        hw.uefi = false;
        QCOMPARE(levelOf(Readiness::evaluate(hw, signedDistro(), 20), "uefi"), "blocker");
    }

    void mbrBlocks()
    {
        HardwareReport hw = readyWindowsPc();
        hw.gptSystemDisk = false;
        QCOMPARE(levelOf(Readiness::evaluate(hw, signedDistro(), 20), "gpt"), "blocker");
    }

    void secureBootNeedsShim()
    {
        HardwareReport hw = readyWindowsPc();
        hw.secureBoot = true;
        Distro distro = signedDistro();
        QCOMPARE(levelOf(Readiness::evaluate(hw, distro, 20), "secureboot"), "ok");

        distro.secureBoot = false;
        const auto results = Readiness::evaluate(hw, distro, 20);
        QCOMPARE(levelOf(results, "secureboot"), "blocker");
        QVERIFY(Readiness::hasBlocker(results));
    }

    void isoTooBigForFat32Blocks()
    {
        Distro distro = signedDistro();
        QCOMPARE(levelOf(Readiness::evaluate(readyWindowsPc(), distro, 20), "baremetal"), "ok");

        distro.bareMetal = false;
        const auto results = Readiness::evaluate(readyWindowsPc(), distro, 20);
        QCOMPARE(levelOf(results, "baremetal"), "blocker");
        QVERIFY(Readiness::hasBlocker(results));
    }

    void spaceBlocksBelowRequirement()
    {
        HardwareReport hw = readyWindowsPc();
        hw.systemFreeBytes = Readiness::requiredBytes(signedDistro(), 20);
        QCOMPARE(levelOf(Readiness::evaluate(hw, signedDistro(), 20), "space"), "ok");

        hw.systemFreeBytes -= 1;
        QCOMPARE(levelOf(Readiness::evaluate(hw, signedDistro(), 20), "space"), "blocker");
    }

    void nvidiaWarnsOnlyWithoutDriver()
    {
        HardwareReport hw = readyWindowsPc();
        hw.nvidiaGpu = true;
        Distro distro = signedDistro();
        QCOMPARE(levelOf(Readiness::evaluate(hw, distro, 20), "gpu"), "ok");

        distro.nvidiaReady = false;
        QCOMPARE(levelOf(Readiness::evaluate(hw, distro, 20), "gpu"), "warning");
    }

    void warningsNeverBlock()
    {
        struct Case
        {
            const char *id;
            std::function<void(HardwareReport &, Distro &)> apply;
        };
        const QList<Case> cases = {
            {"bitlocker", [](HardwareReport &hw, Distro &) { hw.bitLocker = true; }},
            {"faststartup", [](HardwareReport &hw, Distro &) { hw.fastStartup = true; }},
            {"wifi", [](HardwareReport &hw, Distro &) { hw.broadcomWifi = true; }},
            {"ram", [](HardwareReport &hw, Distro &) { hw.ramMb = 2048; }},
            {"live", [](HardwareReport &, Distro &d) { d.liveSession = false; }},
        };
        for (const Case &c : cases) {
            HardwareReport hw = readyWindowsPc();
            Distro distro = signedDistro();
            c.apply(hw, distro);
            const auto results = Readiness::evaluate(hw, distro, 20);
            QVERIFY2(levelOf(results, c.id) == u"warning", c.id);
            QVERIFY2(!Readiness::hasBlocker(results), c.id);
        }
    }
};

QTEST_APPLESS_MAIN(TestReadiness)
#include "tst_readiness.moc"
