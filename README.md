# Testux

[![Build](https://github.com/luxend0/testux/actions/workflows/build.yml/badge.svg)](https://github.com/luxend0/testux/actions/workflows/build.yml)
[![Release](https://img.shields.io/github/v/release/luxend0/testux)](https://github.com/luxend0/testux/releases/latest)
[![License](https://img.shields.io/github/license/luxend0/testux)](LICENSE)

Testux lets you try Linux distributions in a window on your current system, and when you
found one you like, boot its live ISO directly on your PC and install it from there. No
USB stick needed.

<!-- screenshot: catalog page -->

## Who it is for

- **Windows users who are curious about Linux.** Click a distro, it downloads and starts in
  a window. Poke around, open the app store, check if your games and tools are there. If it
  feels right, Testux prepares your PC so it can boot that distro for real.
- **Linux users who hop distros.** Try the newest Fedora, CachyOS or openSUSE in a VM
  without hunting for ISOs, checksums and QEMU flags.

## Features

- **Catalog of 88 distros** in eight groups: beginner friendly, KDE Plasma, gaming, older
  PCs, privacy and security, creative and education, for experienced users, and more.
  From Linux Mint, Ubuntu, Fedora and Zorin OS to CachyOS, Bazzite, Tails, NixOS and Arch.
  The catalog is fetched from this repository on every start, so new versions and new
  distros show up without updating the app.
- **Search and filters**: by name, desktop, base, Secure Boot, live session, NVIDIA driver,
  release model and whether a distro fits your PC's memory.
- **Official ISOs only**, downloaded from the distro's own servers and verified against
  their published SHA-256 checksums. Downloads resume if they get interrupted.
- **VM mode**: the live system runs in a QEMU window with hardware acceleration (KVM on
  Linux, Windows Hypervisor Platform on Windows). RAM and CPU cores are picked
  automatically. On Windows, copy and paste works between your system and the VM (the
  QEMU builds of Linux distros leave that feature out).
- **Optional test disk**: a 30 GB disk (it only takes the space you actually use) so you
  can run the distro's installer inside the VM and keep the installed system.
- **Hardware check**: Secure Boot, BitLocker, Fast Startup, UEFI, free space, NVIDIA GPU,
  Broadcom Wi-Fi and RAM, shown as a simple traffic light for the distro you picked.
- **Checklist**: things worth trying before you decide, like installing an app, playing a
  video, connecting a printer or checking for updates.
- **Comparison**: the distros side by side, including the RAM each one actually used in
  your VM.
- **Boot on this PC** (Windows, UEFI): boots the live ISO on the real hardware without a
  USB stick. You install from the live system like you would from a stick.

## Download

Get the latest version from the [releases page](https://github.com/luxend0/testux/releases/latest).

### Windows

Download and run the `TestuxSetup` installer. It installs Testux together with QEMU and
turns on the Windows Hypervisor Platform feature, which can require one restart.

The installer is not code signed yet, so Windows SmartScreen will show "Windows protected
your PC". Click **More info**, then **Run anyway**. Signing is on the list.

Windows 10 or 11, 64-bit. Windows Home works too.

### Linux

Download the AppImage, make it executable and run it:

```sh
chmod +x Testux-*-x86_64.AppImage
./Testux-*-x86_64.AppImage
```

Testux uses the QEMU from your distribution. If it is missing, Testux shows the right
command, but here they are:

| Distro                   | Command                                                         |
| ------------------------ | --------------------------------------------------------------- |
| Debian, Ubuntu, Mint     | `sudo apt install qemu-system-x86 qemu-system-gui qemu-utils`   |
| Fedora                   | `sudo dnf install qemu-system-x86 qemu-ui-gtk qemu-img`         |
| Arch, CachyOS, Manjaro   | `sudo pacman -S qemu-desktop`                                   |
| openSUSE                 | `sudo zypper install qemu-x86 qemu-ui-gtk qemu-tools`           |
| Gentoo                   | `sudo emerge app-emulation/qemu` (with `USE="gtk"`)             |

For fast VMs your user needs access to `/dev/kvm`. On most distros that means:

```sh
sudo usermod -aG kvm $USER
```

Log out and back in afterwards. Without KVM the VM still runs, just very slowly.

## How "Boot on this PC" works

This is the part that replaces the USB stick. It is Windows only for now; booting from a
Linux host is planned.

1. **Hardware check.** Testux refuses to continue if the PC boots in legacy BIOS mode, the
   system disk uses MBR, there is not enough free space, or Secure Boot is on while the
   distro cannot boot with it.
2. **You pick how much space Linux gets.** Testux shrinks C: by that amount plus the size
   of the ISO and about 1 GB of headroom. Shrinking uses the same Windows function as Disk
   Management, your files stay where they are.
3. **A temporary partition named TESTUX** (FAT32) is created right after C: and the
   contents of the ISO are copied onto it. The rest of the freed space stays unallocated,
   that is where Linux will go.
4. **A one-time boot entry** is added to the firmware. Only the next restart uses it,
   every restart after that goes back to your normal boot order.
5. **BitLocker is suspended for exactly one restart** if your drive is encrypted, so the
   changed boot entry does not trigger the recovery key screen. It turns itself back on.
6. **Restart.** The PC boots into the live system, the same one you tried in the window.
   Start the installer and choose the option to install alongside Windows (the name
   differs per distro). It will use the unallocated space.
7. **Back in Windows**, Testux starts once on its own, removes the TESTUX partition and the
   boot entry, and asks if it should give the unused space back to C:. That only happens
   if the space is still empty, so an installed Linux is never touched.

You can also undo everything from Testux before restarting.

### Before you start

Please read this. Changing partitions is safe when it works and painful when it does not.

- **Back up your important files first.** Testux uses the standard Windows storage
  functions, but power loss during a resize or a bug can always happen.
- **Have your BitLocker recovery key ready** if your drive is encrypted (Windows 11 Home
  often encrypts silently as "Device encryption"). You can find it at
  <https://aka.ms/myrecoverykey>. Testux suspends BitLocker for one restart, but some
  firmware still asks for the key. After Linux is installed, its boot menu usually comes
  first; starting Windows from there can make BitLocker ask for the key, picking Windows in
  the firmware boot menu does not.
- **Secure Boot.** Most distros in the catalog boot with Secure Boot on. CachyOS,
  EndeavourOS and Manjaro do not ship a signed bootloader; for those Testux tells you how
  to turn Secure Boot off in your firmware settings and waits until it is off.
- **UEFI and GPT only.** Very old PCs that boot in legacy BIOS mode are not supported.
- **ISOs with files over 4 GB** cannot be copied to FAT32. Testux checks this and stops
  before changing anything.
- **Fast Startup** keeps Windows half hibernated. Testux warns about it; turning it off
  lets Linux read your Windows drive safely later.

### If the PC boots straight back into Windows

Some firmware ignores one-time boot entries. Open the firmware boot menu while the PC
starts (usually F12, F11, F8 or Esc, depending on the manufacturer) and pick the entry
named **Testux**. Alternatively, in Windows go to Settings > System > Recovery > Advanced
startup > Restart now, then choose "Use a device" and pick Testux.

If you installed Linux and never go back to Windows, the TESTUX partition stays on the
disk. It does no harm. You can delete it from Linux with GNOME Disks or KDE Partition
Manager.

## Privacy

No telemetry, no account. Testux talks to GitHub to load the catalog and to the distro
mirrors to download ISOs. Nothing else.

## Building from source

You need Qt 6.8 or newer (Quick, Quick Controls 2, Network, Concurrent, Linguist tools),
CMake 3.21+ and a C++20 compiler.

### Linux

```sh
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build
ctest --test-dir build
./build/testux
```

### Windows

In a "Developer PowerShell for VS 2022" with Qt for MSVC installed:

```powershell
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=C:\Qt\6.8.3\msvc2022_64
cmake --build build
ctest --test-dir build
C:\Qt\6.8.3\msvc2022_64\bin\windeployqt.exe --qmldir qml build\testux.exe
```

The installer and the AppImage are built by CI, see `.github/workflows/build.yml` and the
`packaging/` folder.

To update the translation files after changing UI strings:

```sh
cmake --build build --target update_translations
```

## Adding or updating a distro

Everything lives in [`catalog/catalog.json`](catalog/catalog.json); the format is described
in [`catalog/README.md`](catalog/README.md). After editing, check that every URL and
checksum still resolves:

```sh
python3 tools/check_catalog.py
```

Then open a pull request. Once it is merged, every Testux picks it up on the next start.
New translations of the app itself go into `i18n/`.

## Credits

Tux by Larry Ewing (lewing@isc.tamu.edu), created with The GIMP. The vector version the
Testux icon builds on is by Simon Budig and Garrett LeSage
([File:Tux.svg](https://commons.wikimedia.org/wiki/File:Tux.svg) on Wikimedia Commons).

Distro names and logos are trademarks of their owners and are shown only to identify each
distro; sources and licenses are listed in [catalog/logos](catalog/logos/README.md).
