# Testux

Try Linux distros in a VM before you install them.

Very early. Right now it boots a hardcoded ISO in QEMU, that's it.

## Building

Needs Qt 6 and CMake.

```
cmake -B build
cmake --build build
./build/testux
```
