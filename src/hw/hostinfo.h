#pragma once

// Host facts that both the hardware check and the VM launcher need. Never needs admin rights.
namespace HostInfo {

int totalRamMb(); // 0 if unknown

// Hardware accelerated VMs are usable right now: /dev/kvm opens read-write (Linux), or the
// Windows Hypervisor Platform is enabled and the hypervisor runs (WHPX).
bool hardwareVirtualization();

} // namespace HostInfo
