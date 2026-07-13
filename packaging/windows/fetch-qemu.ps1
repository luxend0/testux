<#
.SYNOPSIS
    Puts a trimmed QEMU for Windows into <Destination>\qemu.

.DESCRIPTION
    Downloads the pinned build from qemu.weilnetz.de, checks its SHA-512, unpacks the NSIS
    installer with 7-Zip and keeps only what qemu-system-x86_64 and qemu-img need at run
    time. Testux looks for <app dir>\qemu\qemu-system-x86_64.exe.

.EXAMPLE
    ./packaging/windows/fetch-qemu.ps1 -Destination deploy
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string] $Destination,

    # Keeps the downloaded installer between runs.
    [string] $CacheDir = (Join-Path ([IO.Path]::GetTempPath()) 'testux-qemu')
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue' # the progress bar slows Invoke-WebRequest down a lot
Set-StrictMode -Version Latest

# QEMU 11.1.0 by Stefan Weil. The hash is the one published next to the installer.
$InstallerUrl = 'https://qemu.weilnetz.de/w64/2026/qemu-w64-setup-20260811.exe'
$InstallerSha512 = '5bcf9eed634e8575a37b74f445af41a2fe4106da512d0c30c368301d4c105037fdfab40a5287367a28a957624cddebbc8c07e16c88ab6634f554cdf3d16bf543'

# Files from share\ that an x86_64 VM loads: UEFI firmware, SeaBIOS, VGA BIOSes and
# option ROMs. Wildcards must match at least one file.
$ShareFiles = @(
    'edk2-x86_64-code.fd'
    'edk2-i386-vars.fd'   # the x86_64 UEFI variable store template
    'edk2-licenses.txt'
    'bios*.bin'
    'vgabios*.bin'
    'kvmvapic.bin'
    'linuxboot*.bin'
    'multiboot*.bin'
    'pvh.bin'
    'qboot.rom'
    'efi-*.rom'
    'pxe-*.rom'
)
# keymaps for -k, locale for translated GTK menus, icons for the GTK window.
$ShareDirs = @('keymaps', 'locale', 'icons\hicolor', 'icons\Adwaita')

New-Item -ItemType Directory -Force $CacheDir | Out-Null
$installer = Join-Path $CacheDir (Split-Path $InstallerUrl -Leaf)
if (-not (Test-Installer $installer)) {
    Write-Host "Downloading $InstallerUrl"
    Invoke-WebRequest $InstallerUrl -OutFile $installer
    if (-not (Test-Installer $installer)) {
        Remove-Item $installer
        throw "SHA-512 mismatch for $InstallerUrl"
    }
}

$unpacked = Join-Path $CacheDir 'unpacked'
if (Test-Path $unpacked) { Remove-Item -Recurse -Force $unpacked }
& (Get-SevenZip) x -y "-o$unpacked" $installer | Out-Null
if ($LASTEXITCODE -ne 0) { throw "7-Zip failed to unpack $installer (exit code $LASTEXITCODE)" }

$bytes = (Get-ChildItem $target -Recurse -File | Measure-Object Length -Sum).Sum
Write-Host ('QEMU {0} in {1}: {2:N0} MB' -f
    (Get-Content (Join-Path $unpacked 'VERSION')).Trim(), $target, ($bytes / 1MB))
