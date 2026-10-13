#include "hw/hardware.h"
#include "hw/hostinfo.h"

#include <QRegularExpression>
#include <QStorageInfo>
#include <QThread>

#include <algorithm>
#include <memory>
#include <optional>
#include <vector>

#include <windows.h>

#include <propsys.h>
#include <propvarutil.h>
#include <setupapi.h>
#include <shobjidl.h>
#include <winioctl.h>
#include <wrl/client.h>

// initguid.h before devguid.h, so GUID_DEVCLASS_* get defined in this unit.
#include <initguid.h>

#include <devguid.h>

using Microsoft::WRL::ComPtr;

namespace {

constexpr quint16 VendorNvidia = 0x10de;
constexpr quint16 VendorBroadcomPci = 0x14e4;
constexpr quint16 VendorBroadcomUsb = 0x0a5c;

struct HandleCloser
{
    void operator()(HANDLE handle) const { CloseHandle(handle); }
};
struct DeviceInfoSetCloser
{
    void operator()(HDEVINFO set) const { SetupDiDestroyDeviceInfoList(set); }
};
using UniqueHandle = std::unique_ptr<void, HandleCloser>;
using UniqueDeviceInfoSet = std::unique_ptr<void, DeviceInfoSetCloser>;

class ComScope
{
public:
    ComScope()
        : m_result(CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED | COINIT_DISABLE_OLE1DDE))
    {
    }
    ~ComScope()
    {
        if (SUCCEEDED(m_result))
            CoUninitialize();
    }
    ComScope(const ComScope &) = delete;
    ComScope &operator=(const ComScope &) = delete;

private:
    HRESULT m_result;
};

class PropVariant
{
public:
    PropVariant() { PropVariantInit(&value); }
    ~PropVariant() { PropVariantClear(&value); }
    PropVariant(const PropVariant &) = delete;
    PropVariant &operator=(const PropVariant &) = delete;

    PROPVARIANT value;
};

struct Device
{
    QString name;
    QString hardwareId;
    quint16 vendor = 0;
};

const wchar_t *wide(const QString &text)
{
    return reinterpret_cast<const wchar_t *>(text.utf16());
}

std::optional<DWORD> registryDword(const wchar_t *subKey, const wchar_t *name)
{
    DWORD value = 0;
    DWORD size = sizeof(value);
    if (RegGetValueW(HKEY_LOCAL_MACHINE, subKey, name, RRF_RT_REG_DWORD, nullptr, &value, &size) !=
        ERROR_SUCCESS)
        return std::nullopt;
    return value;
}

QString systemDrive()
{
    wchar_t windowsDir[MAX_PATH];
    const UINT length = GetSystemWindowsDirectoryW(windowsDir, MAX_PATH);
    if (length < 2 || length >= MAX_PATH)
        return QStringLiteral("C:");
    return QString::fromWCharArray(windowsDir, 2);
}

bool isUefi()
{
    FIRMWARE_TYPE type = FirmwareTypeUnknown;
    return GetFirmwareType(&type) && type == FirmwareTypeUefi;
}

bool secureBootEnabled()
{
    return registryDword(L"SYSTEM\\CurrentControlSet\\Control\\SecureBoot\\State",
                         L"UEFISecureBootEnabled")
               .value_or(0) == 1;
}

// Fast Startup is part of hibernation and only takes effect while hibernation is enabled.
bool fastStartupEnabled()
{
    const bool hiberboot =
        registryDword(L"SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Power",
                      L"HiberbootEnabled")
            .value_or(0) == 1;
    const bool hibernation =
        registryDword(L"SYSTEM\\CurrentControlSet\\Control\\Power", L"HibernateEnabled")
            .value_or(1) != 0;
    return hiberboot && hibernation;
}

// The shell property System.Volume.BitLockerProtection needs no admin rights, unlike WMI's
// Win32_EncryptableVolume. Values: 1 on, 2 off, 3 encrypting, 4 decrypting, 5 suspended,
// 6 on and locked, missing when the volume cannot use BitLocker. 1, 3, 5 and 6 mean the
// data is encrypted and a recovery prompt is possible.
bool bitLockerProtected(const QString &drive)
{
    PROPERTYKEY key;
    if (FAILED(PSGetPropertyKeyFromName(L"System.Volume.BitLockerProtection", &key)))
        return false;

    ComPtr<IShellItem2> item;
    const QString root = drive + u'\\';
    if (FAILED(SHCreateItemFromParsingName(wide(root), nullptr, IID_PPV_ARGS(&item))))
        return false;

    PropVariant property;
    LONG state = 0;
    if (FAILED(item->GetProperty(key, &property.value)) ||
        FAILED(PropVariantToInt32(property.value, &state)))
        return false;
    return state == 1 || state == 3 || state == 5 || state == 6;
}

bool onGptDisk(const QString &drive)
{
    // IOCTL_DISK_GET_PARTITION_INFO_EX is FILE_ANY_ACCESS, so a handle without any access
    // rights works for regular users.
    const QString volumePath = QStringLiteral("\\\\.\\") + drive;
    HANDLE raw = CreateFileW(wide(volumePath), 0, FILE_SHARE_READ | FILE_SHARE_WRITE, nullptr,
                             OPEN_EXISTING, 0, nullptr);
    if (raw == INVALID_HANDLE_VALUE)
        return false;
    const UniqueHandle volume(raw);

    PARTITION_INFORMATION_EX info{};
    DWORD returned = 0;
    return DeviceIoControl(volume.get(), IOCTL_DISK_GET_PARTITION_INFO_EX, nullptr, 0, &info,
                           sizeof(info), &returned, nullptr) &&
           info.PartitionStyle == PARTITION_STYLE_GPT;
}

// For REG_MULTI_SZ properties (hardware ids) this returns the first, most specific entry.
QString deviceProperty(HDEVINFO set, SP_DEVINFO_DATA &device, DWORD property)
{
    DWORD required = 0;
    SetupDiGetDeviceRegistryPropertyW(set, &device, property, nullptr, nullptr, 0, &required);
    if (required == 0)
        return {};

    std::vector<wchar_t> buffer(required / sizeof(wchar_t) + 1, L'\0');
    if (!SetupDiGetDeviceRegistryPropertyW(set, &device, property, nullptr,
                                           reinterpret_cast<PBYTE>(buffer.data()),
                                           DWORD(buffer.size() * sizeof(wchar_t)), nullptr))
        return {};
    return QString::fromWCharArray(buffer.data());
}

// Hardware ids look like "PCI\VEN_10DE&DEV_2684&..." or "USB\VID_0A5C&PID_BD1E&...".
quint16 vendorId(const QString &hardwareId)
{
    static const QRegularExpression pattern(QStringLiteral("(?:VEN|VID)_([0-9A-Fa-f]{4})"));
    const QRegularExpressionMatch match = pattern.match(hardwareId);
    return match.hasMatch() ? match.captured(1).toUShort(nullptr, 16) : 0;
}

QList<Device> presentDevices(const GUID &deviceClass)
{
    QList<Device> devices;
    HDEVINFO raw = SetupDiGetClassDevsW(&deviceClass, nullptr, nullptr, DIGCF_PRESENT);
    if (raw == INVALID_HANDLE_VALUE)
        return devices;
    const UniqueDeviceInfoSet set(raw);

    SP_DEVINFO_DATA data{};
    data.cbSize = sizeof(data);
    for (DWORD index = 0; SetupDiEnumDeviceInfo(raw, index, &data); ++index) {
        Device device;
        device.name = deviceProperty(raw, data, SPDRP_FRIENDLYNAME);
        if (device.name.isEmpty())
            device.name = deviceProperty(raw, data, SPDRP_DEVICEDESC);
        device.hardwareId = deviceProperty(raw, data, SPDRP_HARDWAREID);
        device.vendor = vendorId(device.hardwareId);
        devices << device;
    }
    return devices;
}

// The network class also holds WAN miniports, VPN, Bluetooth and Hyper-V adapters. A Wi-Fi
// adapter is a real bus device whose name says so, which vendors do consistently
// ("Intel(R) Wi-Fi 6 AX201", "Broadcom 802.11ac Network Adapter", "... Wireless LAN Card").
bool isWifiAdapter(const Device &device)
{
    static const QStringList buses = {"PCI\\", "USB\\", "SDIO\\"};
    static const QStringList markers = {"wi-fi", "wifi", "wireless", "wlan", "802.11"};

    const bool physical = std::any_of(buses.cbegin(), buses.cend(), [&](const QString &bus) {
        return device.hardwareId.startsWith(bus, Qt::CaseInsensitive);
    });
    const QString name = device.name.toLower();
    const bool wireless = std::any_of(markers.cbegin(), markers.cend(),
                                      [&](const QString &marker) { return name.contains(marker); });
    return physical && wireless;
}

} // namespace

HardwareReport probeHardware()
{
    const ComScope com;
    const QString drive = systemDrive();

    HardwareReport report;
    report.windows = true;
    report.uefi = isUefi();
    report.secureBoot = report.uefi && secureBootEnabled();
    report.fastStartup = fastStartupEnabled();
    report.bitLocker = bitLockerProtected(drive);
    report.gptSystemDisk = onGptDisk(drive);
    report.virtualization = HostInfo::hardwareVirtualization();
    report.ramMb = HostInfo::totalRamMb();
    report.cpuThreads = QThread::idealThreadCount();
    report.systemFreeBytes = QStorageInfo(drive + u'\\').bytesAvailable();

    for (const Device &gpu : presentDevices(GUID_DEVCLASS_DISPLAY)) {
        report.gpus << gpu.name;
        report.nvidiaGpu |= gpu.vendor == VendorNvidia;
    }
    for (const Device &adapter : presentDevices(GUID_DEVCLASS_NET)) {
        if (!isWifiAdapter(adapter))
            continue;
        report.wifiAdapters << adapter.name;
        report.broadcomWifi |=
            adapter.vendor == VendorBroadcomPci || adapter.vendor == VendorBroadcomUsb;
    }

    report.valid = true;
    return report;
}
