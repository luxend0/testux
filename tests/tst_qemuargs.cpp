#include "vm/qemuargs.h"

#include <QTest>

#include <algorithm>

namespace {

QemuConfig baseConfig()
{
    QemuConfig config;
    config.isoPath = "/isos/mint.iso";
    config.accelerator = "kvm";
    config.ramMb = 4096;
    config.cpus = 4;
    config.title = "Linux Mint 22.2 in Testux";
    return config;
}

QStringList valuesOf(const QStringList& args, const QString& option)
{
    qDebug() << Q_FUNC_INFO;
    QStringList values;
    for (qsizetype i = 0; i + 1 < args.size(); ++i) {
        if (args[i] == option)
            values << args[i + 1];
    }
    return values;
}

bool anyStartsWith(const QStringList& values, const QString& prefix)
{
    return std::any_of(values.begin(), values.end(),
                       [&](const QString& value) { return value.startsWith(prefix); });
}

} // namespace

class TestQemuArgs : public QObject
{
    Q_OBJECT

private slots:
    void baseMachine()
    {
        const QStringList args = QemuArgs::build(baseConfig());
        QCOMPARE(valuesOf(args, "-machine"), QStringList{"q35"});
        QCOMPARE(valuesOf(args, "-m"), QStringList{"4096"});
        QCOMPARE(valuesOf(args, "-smp"), QStringList{"4"});
        QCOMPARE(valuesOf(args, "-name"), QStringList{"Linux Mint 22.2 in Testux"});
        QVERIFY(args.contains("-nodefaults"));
        QCOMPARE(valuesOf(args, "-display"), QStringList{"gtk,zoom-to-fit=on"});
        QVERIFY(valuesOf(args, "-device").contains("virtio-vga"));
        QVERIFY(valuesOf(args, "-device").contains("usb-tablet"));
        QVERIFY(anyStartsWith(valuesOf(args, "-device"), "virtio-balloon-pci,id=balloon0,"));
        QVERIFY(anyStartsWith(valuesOf(args, "-device"), "virtio-net-pci,"));
    }

    void accelerator_data()
    {
        QTest::addColumn<QString>("accelerator");
        QTest::addColumn<QString>("accelOption");
        QTest::addColumn<QStringList>("cpu");
        QTest::newRow("kvm") << "kvm" << "kvm" << QStringList{"host"};
        QTest::newRow("whpx") << "whpx" << "whpx,kernel-irqchip=off" << QStringList{};
        QTest::newRow("tcg") << "tcg" << "tcg" << QStringList{"max"};
        QTest::newRow("unknown falls back to tcg") << "hvf" << "tcg" << QStringList{"max"};
    }

    void accelerator()
    {
        QFETCH(QString, accelerator);
        QFETCH(QString, accelOption);
        QFETCH(QStringList, cpu);
        QemuConfig config = baseConfig();
        config.accelerator = accelerator;
        const QStringList args = QemuArgs::build(config);
        QCOMPARE(valuesOf(args, "-accel"), QStringList{accelOption});
        QCOMPARE(valuesOf(args, "-cpu"), cpu);
    }

    void firmware()
    {
        QemuConfig config = baseConfig();
        QVERIFY(!anyStartsWith(valuesOf(QemuArgs::build(config), "-drive"), "if=pflash"));

        config.firmwarePath = "/usr/share/qemu/edk2-x86_64-code.fd";
        QStringList drives = valuesOf(QemuArgs::build(config), "-drive");
        QVERIFY(drives.contains("if=pflash,format=raw,unit=0,readonly=on,"
                                "file=/usr/share/qemu/edk2-x86_64-code.fd"));
        QVERIFY(!anyStartsWith(drives, "if=pflash,format=raw,unit=1"));
    }

    void testDiskBootsBeforeIso()
    {
        QemuConfig config = baseConfig();
        QStringList devices = valuesOf(QemuArgs::build(config), "-device");
        QVERIFY(devices.contains("ide-cd,drive=cd0,bootindex=0"));
        QVERIFY(!anyStartsWith(devices, "virtio-blk-pci"));

        config.diskPath = "/disks/mint.qcow2";
        const QStringList args = QemuArgs::build(config);
        devices = valuesOf(args, "-device");
        QVERIFY(devices.contains("virtio-blk-pci,drive=disk0,bootindex=0"));
        QVERIFY(devices.contains("ide-cd,drive=cd0,bootindex=1"));
        QVERIFY(
            valuesOf(args, "-drive")
                .contains("if=none,id=disk0,format=qcow2,discard=unmap,file=/disks/mint.qcow2"));
    }

    void commasInPathsAreEscaped()
    {
        QemuConfig config = baseConfig();
        config.isoPath = "C:/Users/Max, Jr/mint.iso";
        QVERIFY(valuesOf(QemuArgs::build(config), "-drive")
                    .contains("if=none,id=cd0,media=cdrom,readonly=on,"
                              "file=C:/Users/Max,, Jr/mint.iso"));
    }

    void qmpPort()
    {
        QemuConfig config = baseConfig();
        config.qmpPort = 4444;
        QCOMPARE(valuesOf(QemuArgs::build(config), "-qmp"),
                 QStringList{"tcp:127.0.0.1:4444,server=on,wait=off"});
    }

    void audio()
    {
        QemuConfig config = baseConfig();
        QStringList args = QemuArgs::build(config);
        QVERIFY(!args.contains("-audiodev"));
        QVERIFY(!valuesOf(args, "-device").contains("intel-hda"));

        config.audioDriver = "pa";
        args = QemuArgs::build(config);
        QCOMPARE(valuesOf(args, "-audiodev"), QStringList{"pa,id=audio0"});
        QVERIFY(valuesOf(args, "-device").contains("intel-hda"));
        QVERIFY(valuesOf(args, "-device").contains("hda-duplex,audiodev=audio0"));
    }

    void clipboard()
    {
        QemuConfig config = baseConfig();
        config.clipboard = false;
        QStringList args = QemuArgs::build(config);
        QVERIFY(!args.contains("-chardev"));

        config.clipboard = true;
        args = QemuArgs::build(config);
        QVERIFY(anyStartsWith(valuesOf(args, "-chardev"), "qemu-vdagent,"));
        QVERIFY(valuesOf(args, "-device")
                    .contains("virtserialport,chardev=vdagent,name=com.redhat.spice.0"));
    }

    void gl()
    {
        QemuConfig config = baseConfig();
        config.gl = true;
        const QStringList args = QemuArgs::build(config);
        QVERIFY(valuesOf(args, "-device").contains("virtio-vga-gl"));
        QCOMPARE(valuesOf(args, "-display"), QStringList{"gtk,gl=on,zoom-to-fit=on"});
    }
};

QTEST_APPLESS_MAIN(TestQemuArgs)
