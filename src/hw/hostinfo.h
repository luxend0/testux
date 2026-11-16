#pragma once

// Host facts that both the hardware check and the VM launcher need. Never needs admin rights.
#include <QString>

namespace HostInfo {

int totalRamMb(); // 0 if unknown

// Hardware accelerated VMs are usable right now: /dev/kvm opens read-write (Linux), or the
// Windows Hypervisor Platform is enabled and the hypervisor runs (WHPX).
bool hardwareVirtualization();

// Windows: the "Windows Hypervisor Platform" feature is installed (WinHvPlatform.dll exists).
// Installed is not usable yet: that takes a restart, and virtualization switched on in the
// firmware. Always true on Linux, where nothing needs installing.
bool hypervisorPlatformInstalled();

// Full path of a program in Windows' System32 folder, which only administrators can change.
QString systemProgram(const QString &fileName);

} // namespace HostInfo
