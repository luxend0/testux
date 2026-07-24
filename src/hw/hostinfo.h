#pragma once

namespace HostInfo {

int totalRamMb(); // 0 if unknown

// Hardware accelerated VMs are usable right now: /dev/kvm opens read-write (Linux), or the
// Windows Hypervisor Platform is enabled and the hypervisor runs (WHPX).
bool hardwareVirtualization();

} // namespace HostInfo
