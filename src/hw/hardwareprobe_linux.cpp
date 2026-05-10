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
    }
    return {};
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

} // namespace
