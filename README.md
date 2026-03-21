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
