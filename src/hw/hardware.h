#pragma once

// Implemented per platform in hardwareprobe_{win,linux}.cpp. Blocking, run it off the
// GUI thread.
HardwareReport probeHardware();
