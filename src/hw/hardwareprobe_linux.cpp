#include "hw/hardware.h"

#include <QDir>
#include <QFile>
#include <QStorageInfo>
#include <QThread>

namespace {

constexpr quint16 VendorNvidia = 0x10de;
constexpr quint16 VendorBroadcomPci = 0x14e4;
constexpr quint16 VendorBroadcomUsb = 0x0a5c;

struct Device
{
    QString name;
    quint16 vendor = 0;
};

QByteArray readFile(const QString &path)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly))
        return {};
    return file.readAll();
}

// sysfs id files hold "0x10de\n".
quint32 readHex(const QString &path)
{
    return readFile(path).trimmed().toUInt(nullptr, 16);
}

bool secureBootEnabled()
{
    // efivarfs: 4 bytes of attributes, then the variable data (1 = enabled).
    const QByteArray var =
        readFile("/sys/firmware/efi/efivars/SecureBoot-8be4df61-93ca-11d2-aa0d-00e098032b8c");
    return var.size() >= 5 && var.at(4) == 1;
}

QByteArray loadPciIds()
{
    for (const char *path : {"/usr/share/hwdata/pci.ids", "/usr/share/misc/pci.ids"}) {
        if (QByteArray ids = readFile(path); !ids.isEmpty())
            return ids;
    }
    return {};
}

// pci.ids names often carry the familiar name in brackets: "AD102 [GeForce RTX 4090]".
QString preferBracketed(const QString &name)
{
    const qsizetype open = name.indexOf(u'[');
    if (open < 0 || !name.endsWith(u']'))
        return name;
    return name.sliced(open + 1, name.size() - open - 2);
}

QString fallbackVendorName(quint16 vendor)
{
    switch (vendor) {
    case VendorNvidia:
        return QStringLiteral("NVIDIA");
    case 0x1002:
        return QStringLiteral("AMD");
    case 0x8086:
        return QStringLiteral("Intel");
    case VendorBroadcomPci:
        return QStringLiteral("Broadcom");
    default:
        return QStringLiteral("PCI %1").arg(vendor, 4, 16, QLatin1Char('0'));
    }
}

QString pciName(quint16 vendor, quint16 device, const QByteArray &pciIds)
{
    const QByteArray vendorKey = QByteArray::number(vendor, 16).rightJustified(4, '0') + "  ";
    const QByteArray deviceKey =
        '\t' + QByteArray::number(device, 16).rightJustified(4, '0') + "  ";

    QString vendorName;
    for (const QByteArray &line : pciIds.split('\n')) {
        if (vendorName.isEmpty()) {
            if (line.startsWith(vendorKey))
                vendorName = preferBracketed(QString::fromUtf8(line.mid(vendorKey.size())));
            continue;
        }
        if (!line.startsWith('\t') && !line.startsWith('#') && !line.isEmpty())
            break; // next vendor, the device is not listed
        if (line.startsWith(deviceKey))
            return vendorName + u' ' +
                   preferBracketed(QString::fromUtf8(line.mid(deviceKey.size())));
    }
    return vendorName.isEmpty() ? fallbackVendorName(vendor) : vendorName;
}

// PCI deviecs expose vendor/device next to each other; USB network interfaces sit one
// level below the USB device, which carries idVendor. Anything else (SDIO, platform
// devices) is named after its sysfs node.
Device deviceAt(const QString &sysfsDevice, const QByteArray &pciIds)
{
    if (QFile::exists(sysfsDevice + "/vendor")) {
        const auto vendor = quint16(readHex(sysfsDevice + "/vendor"));
        const auto device = quint16(readHex(sysfsDevice + "/device"));
        return {pciName(vendor, device, pciIds), vendor};
    }
    if (QFile::exists(sysfsDevice + "/../idVendor")) {
        const auto vendor = quint16(readHex(sysfsDevice + "/../idVendor"));
        const auto product = quint16(readHex(sysfsDevice + "/../idProduct"));
        return {QStringLiteral("USB %1:%2")
                    .arg(vendor, 4, 16, QLatin1Char('0'))
                    .arg(product, 4, 16, QLatin1Char('0')),
                vendor};
    }
    return {QDir(sysfsDevice).dirName(), 0};
}

QList<Device> gpus(const QByteArray &pciIds)
{
    QList<Device> result;
    const QDir devices("/sys/bus/pci/devices");
    for (const QString &entry : devices.entryList(QDir::Dirs | QDir::NoDotAndDotDot)) {
        const QString path = devices.filePath(entry);
        if ((readHex(path + "/class") >> 16) == 0x03) // display controller
            result << deviceAt(path, pciIds);
    }
    return result;
}

QList<Device> wifiAdapters(const QByteArray &pciIds)
{
    QList<Device> result;
    const QDir interfaces("/sys/class/net");
    for (const QString &name : interfaces.entryList(QDir::Dirs | QDir::NoDotAndDotDot)) {
        const QString path = interfaces.filePath(name);
        const bool wireless =
            QFile::exists(path + "/wireless") || QFile::exists(path + "/phy80211");
        if (wireless && QFile::exists(path + "/device"))
            result << deviceAt(QDir(path + "/device").canonicalPath(), pciIds);
    }
    return result;
}

} // namespace

HardwareReport probeHardware()
{
    HardwareReport report;
    report.windows = false;
    report.uefi = QFile::exists("/sys/firmware/efi");
    report.secureBoot = report.uefi && secureBootEnabled();
    report.virtualization = HostInfo::hardwareVirtualization();
    report.ramMb = HostInfo::totalRamMb();
    report.cpuThreads = QThread::idealThreadCount();
    report.systemFreeBytes = QStorageInfo::root().bytesAvailable();

    const QByteArray pciIds = loadPciIds();
    for (const Device &gpu : gpus(pciIds)) {
        report.gpus << gpu.name;
        report.nvidiaGpu |= gpu.vendor == VendorNvidia;
    }
    for (const Device &adapter : wifiAdapters(pciIds)) {
        report.wifiAdapters << adapter.name;
        report.broadcomWifi |=
            adapter.vendor == VendorBroadcomPci || adapter.vendor == VendorBroadcomUsb;
    }

    report.valid = true;
    return report;
}
