#Requires -Version 5.1
<#
.SYNOPSIS
Prepares a one-time boot into a Linux live ISO from the internal disk, no USB stick.

.DESCRIPTION
Shrinks C:, creates a FAT32 partition labelled TESTUX directly behind it, copies the ISO
contents onto it and makes \EFI\BOOT\BOOTX64.EFI on it the one-time UEFI boot target.
LinuxSpaceGB stays unallocated behind TESTUX for the distro installer.

How the copied live system finds its files again:
- casper (Ubuntu, Mint, Zorin, Pop!_OS, elementary, Kubuntu, KDE neon) and Debian
  live-boot scan every block device for /casper or /live, FAT32 included.
- archiso (CachyOS, EndeavourOS) falls back from archisosearchuuid to looking for
  /boot/<uuid>.uuid on every partition, and its GRUB finds its root by that file too.
- dracut dmsquash-live and kiwi (Fedora, Nobara, openSUSE) and Anaconda (Bazzite) boot
  with root=live:CDLABEL=<label> or inst.stage2=hd:LABEL=<label>, Manjaro uses
  misolabel=<label>, and their boot loaders search for that volume label.
So the only patch needed is replacing the ISO9660 volume label with TESTUX in the boot
loader configs. Lookups by file need nothing.

The partition keeps the basic data type instead of the ESP type, so an installer never
picks it as the EFI system partition of the new system; cleanup-boot.ps1 deletes it.

Every change is recorded in %ProgramData%\Testux\boot.json before it is made and undone
through cleanup-boot.ps1 if a later step fails. Progress goes to progress.jsonl, one JSON
object per line, each tagged with RunId.
#>
# Script scope parameters are used inside the helper functions, and the helpers are not
# meant to be called on their own, so these two rules only produce noise here.
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)] [string] $IsoPath,
    [Parameter(Mandatory = $true)] [string] $DistroName,
    [Parameter(Mandatory = $true)] [string] $RunId,
    [ValidateRange(0, 4096)] [int] $LinuxSpaceGB = 0
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Label = 'TESTUX'
$Headroom = 1GB
$MaxFat32File = 4GB - 1
$MaxFat32Volume = 32GB
$BasicDataType = '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}'
$BootLoader = '\EFI\BOOT\BOOTX64.EFI'
$DataDir = Join-Path $env:ProgramData 'Testux'
$ProgressFile = Join-Path $DataDir 'progress.jsonl'
$StateFile = Join-Path $DataDir 'boot.json'
$Utf8 = New-Object System.Text.UTF8Encoding $false

function Send-Status([hashtable] $Fields) {
    $Fields['run'] = $RunId
    $line = ($Fields | ConvertTo-Json -Compress) + "`n"
    [System.IO.File]::AppendAllText($ProgressFile, $line, $Utf8)
}

function Send-Step([string] $Step, [double] $Progress) {
    Send-Status @{ step = $Step; progress = [math]::Round($Progress, 3) }
}

function Save-State($State) {
    [System.IO.File]::WriteAllText($StateFile, ($State | ConvertTo-Json), $Utf8)
}

function Invoke-Native([string] $FilePath, [string[]] $Arguments) {
    # Native stderr must not turn into terminating errors; the exit code decides.
    $ErrorActionPreference = 'Continue'
    $output = & $FilePath @Arguments 2>&1 | Out-String
    if ($LASTEXITCODE -ne 0) {
        throw "$FilePath $($Arguments -join ' ') failed: $($output.Trim())"
    }
    return $output
}

function Get-AlignedDown([int64] $Bytes) {
    return $Bytes - ($Bytes % 1MB)
}

function Assert-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal $identity
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Administrator rights are required.'
    }
}

function Assert-UefiGpt($SystemPartition) {
    if ($env:firmware_type -ne 'UEFI') {
        throw 'This PC starts in legacy BIOS mode. Booting without a USB stick needs UEFI.'
    }
    $disk = Get-Disk -Number $SystemPartition.DiskNumber
    if ($disk.PartitionStyle -ne 'GPT') {
        throw 'The system disk uses MBR partitioning. Booting without a USB stick needs GPT.'
    }
}

function Assert-NothingPending {
    if (Test-Path -LiteralPath $StateFile) {
        throw 'A previous Testux boot setup still exists. Remove it in Testux first.'
    }
}

# The ISO9660 volume label from the primary volume descriptor. Windows shows the Joliet
# label instead, which is cut to 16 characters and would not match the boot configs.
function Get-IsoVolumeLabel([string] $Path) {
    $stream = [System.IO.File]::OpenRead($Path)
    try {
        $descriptor = New-Object byte[] 72
        [void]$stream.Seek(16 * 2048, [System.IO.SeekOrigin]::Begin)
        if ($stream.Read($descriptor, 0, 72) -ne 72) {
            throw 'The ISO file is too short.'
        }
        $magic = [System.Text.Encoding]::ASCII.GetString($descriptor, 1, 5)
        if ($descriptor[0] -ne 1 -or $magic -ne 'CD001') {
            throw 'The file is not an ISO9660 image.'
        }
        return [System.Text.Encoding]::ASCII.GetString($descriptor, 40, 32).Trim()
    }
    finally {
        $stream.Dispose()
    }
}
