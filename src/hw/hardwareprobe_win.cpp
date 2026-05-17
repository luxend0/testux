#include "hw/hardware.h"

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
    return QString::fromWCharArray(windowsDir, 2);
}

bool secureBootEnabled()
{
    return registryDword(L"SYSTEM\\CurrentControlSet\\Control\\SecureBoot\\State",
                         L"UEFISecureBootEnabled")
               .value_or(0) == 1;
}

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

bool onGptDisk(const QString &drive)
{
    const QString volumePath = QStringLiteral("\\\\.\\") + drive;
    HANDLE raw = CreateFileW(wide(volumePath), 0, FILE_SHARE_READ | FILE_SHARE_WRITE, nullptr,
                             OPEN_EXISTING, 0, nullptr);
    const UniqueHandle volume(raw);

    PARTITION_INFORMATION_EX info{};
    DWORD returned = 0;
    return DeviceIoControl(volume.get(), IOCTL_DISK_GET_PARTITION_INFO_EX, nullptr, 0, &info,
                           sizeof(info), &returned, nullptr) &&
           info.PartitionStyle == PARTITION_STYLE_GPT;
}

} // namespace
