#include "baremetal/baremetal.h"

#include <QCoreApplication>
#include <QDir>
#include <QProcess>
#include <QSettings>
#include <QWinEventNotifier>

#include <windows.h>

#include <shellapi.h> // needs windows.h first

namespace {

constexpr auto RunOnceKey =
    R"(HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\RunOnce)";
constexpr auto RunOnceValue = "Testux";

std::wstring powerShellPath()
{
    wchar_t system[MAX_PATH];
    const UINT length = GetSystemDirectoryW(system, MAX_PATH);
    return std::wstring(system, length) + L"\\WindowsPowerShell\\v1.0\\powershell.exe";
}

} // namespace
