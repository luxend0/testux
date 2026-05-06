#include "hw/hardware.h"

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
    // TODO
}

} // namespace
