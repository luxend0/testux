#include "hw/hostinfo.h"

#include <QtGlobal>

#ifdef Q_OS_WIN
#include <cstring>
#include <memory>
#include <type_traits>

#include <windows.h>
#else
#include <fcntl.h>
#include <unistd.h>
#endif

#ifdef Q_OS_WIN

int HostInfo::totalRamMb()
{
    MEMORYSTATUSEX status{};
    status.dwLength = sizeof(status);
    return GlobalMemoryStatusEx(&status) ? int(status.ullTotalPhys >> 20) : 0;
}

// WinHvPlatform.dll only exists once the "Windows Hypervisor Platform" feature is enabled,
// so it is loaded at runtime instead of linked.
bool HostInfo::hardwareVirtualization()
{
    struct LibraryCloser
    {
        void operator()(HMODULE library) const { FreeLibrary(library); }
    };
    const std::unique_ptr<std::remove_pointer_t<HMODULE>, LibraryCloser> library(
        LoadLibraryExW(L"WinHvPlatform.dll", nullptr, LOAD_LIBRARY_SEARCH_SYSTEM32));
    if (!library)
        return false;

    using GetCapability = HRESULT(WINAPI *)(int code, void *buffer, UINT32 size, UINT32 *written);
    const auto getCapability =
        reinterpret_cast<GetCapability>(GetProcAddress(library.get(), "WHvGetCapability"));
    if (!getCapability)
        return false;

    constexpr int HypervisorPresent = 0;           // WHvCapabilityCodeHypervisorPresent
    alignas(8) unsigned char capability[256] = {}; // fits any WHV_CAPABILITY
    UINT32 written = 0;
    BOOL present = FALSE;
    std::memcpy(&present, capability, sizeof(present));
    return present;
}

#else

int HostInfo::totalRamMb()
{
    const long pages = sysconf(_SC_PHYS_PAGES);
    const long pageSize = sysconf(_SC_PAGE_SIZE);
    if (pages <= 0 || pageSize <= 0)
        return 0;
    return int(qint64(pages) * pageSize >> 20);
}

bool HostInfo::hardwareVirtualization()
{
    const int fd = ::open("/dev/kvm", O_RDWR | O_CLOEXEC);
    if (fd < 0)
        return false;
    ::close(fd);
    return true;
}

#endif
