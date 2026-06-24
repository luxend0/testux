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

function Mount-Iso([string] $Path) {
    $image = Get-DiskImage -ImagePath $Path
    $mountedByUs = -not $image.Attached
    if ($mountedByUs) {
        $image = Mount-DiskImage -ImagePath $Path -PassThru
    }
    $letter = $null
    for ($attempt = 0; $attempt -lt 20 -and -not $letter; $attempt++) {
        $letter = (Get-DiskImage -ImagePath $Path | Get-Volume).DriveLetter
        if (-not $letter) { Start-Sleep -Milliseconds 500 }
    }
    if (-not $letter) {
        throw 'Windows mounted the ISO without a drive letter.'
    }
    return @{ Root = "${letter}:\"; MountedByUs = $mountedByUs }
}

# Size of everything on the ISO; fails on files FAT32 cannot hold or a missing UEFI loader.
function Measure-IsoContent([string] $Root) {
    # Some ISOs (Rhino Linux) keep a 0-byte placeholder there and the real loader only in
    # the El Torito image, which a plain file copy cannot reach.
    $loader = Get-Item -LiteralPath (Join-Path $Root $BootLoader) -Force -ErrorAction SilentlyContinue
    if ($null -eq $loader -or $loader.Length -eq 0) {
        throw 'This ISO has no UEFI boot loader (\EFI\BOOT\BOOTX64.EFI) that can start from a hard drive.'
    }
    $files = @(Get-ChildItem -LiteralPath $Root -Recurse -File -Force)
    $tooLarge = @($files | Where-Object { $_.Length -gt $MaxFat32File })
    if ($tooLarge.Count -gt 0) {
        $names = ($tooLarge | ForEach-Object { $_.FullName.Substring($Root.Length) }) -join ', '
        throw "This ISO contains files larger than 4 GiB, which FAT32 cannot store: $names"
    }
    return [int64]($files | Measure-Object -Property Length -Sum).Sum
}

function Assert-CanShrink($SystemPartition, [int64] $Bytes) {
    $supported = Get-PartitionSupportedSize -DiskNumber $SystemPartition.DiskNumber `
        -PartitionNumber $SystemPartition.PartitionNumber
    $possible = [int64]$SystemPartition.Size - [int64]$supported.SizeMin
    if ($Bytes -gt $possible) {
        $needGB = [math]::Ceiling($Bytes / 1GB)
        $haveGB = [math]::Floor($possible / 1GB)
        throw "Drive C: can only give up $haveGB GB right now, $needGB GB are needed. Free up space or choose less space for Linux."
    }
}

function New-BootState($SystemPartition, [int64] $PartitionSize, [int64] $ShrinkBy) {
    $remaining = Get-AlignedDown ([int64]$SystemPartition.Size - $ShrinkBy)
    return [ordered]@{
        version            = 1
        distro             = $DistroName
        diskNumber         = $SystemPartition.DiskNumber
        systemDriveLetter  = [string]$SystemPartition.DriveLetter
        systemOriginalSize = [int64]$SystemPartition.Size
        systemShrunkSize   = $remaining
        partitionOffset    = Get-AlignedUp ([int64]$SystemPartition.Offset + $remaining)
        partitionSize      = $PartitionSize
        partitionGuid      = $null
        bootEntry          = $null
        bitLockerSuspended = $false
    }
}

function Get-PartitionByGuid([int] $DiskNumber, [string] $Guid) {
    return Get-Partition -DiskNumber $DiskNumber | Where-Object { $_.Guid -eq $Guid }
}

# TESTUX goes right behind where C: really ends, in case Windows rounded the new size.
function Resize-SystemPartition($SystemPartition, $State) {
    Resize-Partition -DiskNumber $SystemPartition.DiskNumber `
        -PartitionNumber $SystemPartition.PartitionNumber -Size $State.systemShrunkSize
    $shrunk = Get-Partition -DiskNumber $SystemPartition.DiskNumber -PartitionNumber $SystemPartition.PartitionNumber
    $State.partitionOffset = Get-AlignedUp ([int64]$shrunk.Offset + [int64]$shrunk.Size)
    Save-State $State
}

# Creates, formats and mounts TESTUX; returns its drive letter. Formatting happens before
# a letter is assigned so Explorer never offers to format a raw volume.
function New-TestuxPartition($State) {
    $partition = New-Partition -DiskNumber $State.diskNumber -Offset $State.partitionOffset `
        -Size $State.partitionSize -GptType $BasicDataType
    $State.partitionGuid = $partition.Guid
    $State.partitionSize = [int64]$partition.Size
    Save-State $State

    $partition | Format-Volume -FileSystem FAT32 -NewFileSystemLabel $Label -Force -Confirm:$false | Out-Null
    $partition | Add-PartitionAccessPath -AssignDriveLetter
    $letter = (Get-PartitionByGuid $State.diskNumber $State.partitionGuid).DriveLetter
    if (-not ([string]$letter -match '^[A-Z]$')) {
        throw 'The new partition did not get a drive letter.'
    }
    return [string]$letter
}

function Copy-IsoContent([string] $Source, [string] $Letter, [int64] $TotalBytes) {
    # "X:\." instead of "X:\": robocopy reads \" as an escaped quote.
    $arguments = "`"$($Source).`" `"${Letter}:\.`" /E /COPY:DT /DCOPY:T /FFT /R:2 /W:2 /NP /NFL /NDL /NJH /NJS"
    $process = Start-Process -FilePath 'robocopy.exe' -ArgumentList $arguments -WindowStyle Hidden -PassThru
    [void]$process.Handle # keeps ExitCode readable after the process ends
    $volume = Get-Volume -DriveLetter $Letter
    $baseline = [int64]$volume.Size - [int64]$volume.SizeRemaining
    $total = [double][math]::Max(1, $TotalBytes)
    while (-not $process.HasExited) {
        $volume = Get-Volume -DriveLetter $Letter
        $copied = [int64]$volume.Size - [int64]$volume.SizeRemaining - $baseline
        Send-Step 'copy' (0.2 + 0.7 * [math]::Min(1.0, [math]::Max(0, $copied) / $total))
        Start-Sleep -Seconds 2
    }
    $process.WaitForExit()
    if ($process.ExitCode -ge 8) {
        throw "Copying the ISO failed (robocopy exit code $($process.ExitCode))."
    }
}

function Update-BootConfig([string] $Root, [string] $IsoLabel) {
    # GRUB configs may escape spaces in labels.
    $variants = @($IsoLabel, $IsoLabel.Replace(' ', '\x20'), $IsoLabel.Replace(' ', '\040')) |
        Select-Object -Unique
    $configs = Get-ChildItem -LiteralPath $Root -Recurse -File -Force |
        Where-Object { ($_.Extension -eq '.cfg' -or $_.Extension -eq '.conf') -and $_.Length -lt 1MB }
    foreach ($config in $configs) {
        $original = [System.IO.File]::ReadAllText($config.FullName)
        $patched = $original
        foreach ($variant in $variants) {
            $patched = $patched.Replace($variant, $Label)
        }
        if ($patched -ne $original) {
            [System.IO.File]::WriteAllText($config.FullName, $patched, $Utf8)
        }
    }
}

function Get-SystemEncryptableVolume {
    try {
        return Get-CimInstance -Namespace 'root\cimv2\Security\MicrosoftVolumeEncryption' `
            -ClassName Win32_EncryptableVolume -Filter "DriveLetter = '$env:SystemDrive'"
    }
    catch {
        return $null # no BitLocker support on this edition
    }
}

# Changing the boot order makes BitLocker ask for the recovery key unless it is suspended.
# DisableCount 1 resumes protection by itself after the next Windows start.
function Suspend-BitLockerOnce($State) {
    $volume = Get-SystemEncryptableVolume
    if (-not $volume -or $volume.ProtectionStatus -ne 1) { return }
    $State.bitLockerSuspended = $true
    Save-State $State
    $result = Invoke-CimMethod -InputObject $volume -MethodName DisableKeyProtectors `
        -Arguments @{ DisableCount = [uint32]1 }
    if ($result.ReturnValue -ne 0) {
        throw "Pausing BitLocker failed (error $($result.ReturnValue))."
    }
}

function Add-BootEntry($State, [string] $Letter) {
    $safeName = $DistroName -replace '[^A-Za-z0-9 ._!+-]', ''
    $output = Invoke-Native 'bcdedit.exe' @('/copy', '{bootmgr}', '/d', "Testux: $safeName")
    $entry = [regex]::Match($output, '\{[0-9A-Fa-f-]{36}\}')
    if (-not $entry.Success) {
        throw "bcdedit did not return the new entry: $($output.Trim())"
    }
    $State.bootEntry = $entry.Value
    Save-State $State

    Invoke-Native 'bcdedit.exe' @('/set', $State.bootEntry, 'device', "partition=${Letter}:") | Out-Null
    Invoke-Native 'bcdedit.exe' @('/set', $State.bootEntry, 'path', $BootLoader) | Out-Null
    Invoke-Native 'bcdedit.exe' @('/set', '{fwbootmgr}', 'displayorder', $State.bootEntry, '/addlast') | Out-Null
    Invoke-Native 'bcdedit.exe' @('/set', '{fwbootmgr}', 'bootsequence', $State.bootEntry) | Out-Null
}

# The firmware finds TESTUX by its GPT partition GUID, so it needs no drive letter. Hidden
# from Explorer its files cannot be deleted by accident. Cosmetic, so failures are ignored.
function Hide-TestuxPartition($State, [string] $Letter) {
    try {
        $partition = Get-PartitionByGuid $State.diskNumber $State.partitionGuid
        $partition | Remove-PartitionAccessPath -AccessPath "${Letter}:\"
        $partition | Set-Partition -NoDefaultDriveLetter $true
    }
    catch {
        return
    }
}

function Undo-BootSetup {
    Send-Step 'undo' 0
    & (Join-Path $PSScriptRoot 'cleanup-boot.ps1') -ReclaimSpace -Quiet
}

$state = $null
$iso = $null
$exitCode = 0
try {
    New-Item -ItemType Directory -Force -Path $DataDir | Out-Null
    [System.IO.File]::WriteAllText($ProgressFile, '', $Utf8)

    Send-Step 'preflight' 0
    Assert-Administrator
    Assert-NothingPending
    if (-not (Test-Path -LiteralPath $IsoPath -PathType Leaf)) {
        throw "The ISO file does not exist: $IsoPath"
    }
    $systemPartition = Get-Partition -DriveLetter ($env:SystemDrive.Substring(0, 1))
    Assert-UefiGpt $systemPartition
    $isoLabel = Get-IsoVolumeLabel $IsoPath
    $iso = Mount-Iso $IsoPath
    $contentBytes = Measure-IsoContent $iso.Root
    $partitionSize = Get-AlignedUp ($contentBytes + $Headroom)
    if ($partitionSize -gt $MaxFat32Volume) {
        throw 'This ISO is too large for a FAT32 boot partition.'
    }
    $shrinkBy = $partitionSize + [int64]$LinuxSpaceGB * 1GB
    Assert-CanShrink $systemPartition $shrinkBy

    $state = New-BootState $systemPartition $partitionSize $shrinkBy
    Save-State $state

    Send-Step 'shrink' 0.05
    Resize-SystemPartition $systemPartition $state

    Send-Step 'partition' 0.15
    $letter = New-TestuxPartition $state

    Send-Step 'copy' 0.2
    Copy-IsoContent $iso.Root $letter $contentBytes

    Send-Step 'patch' 0.92
    Update-BootConfig "${letter}:\" $isoLabel

    Send-Step 'bitlocker' 0.95
    Suspend-BitLockerOnce $state

    Send-Step 'bootentry' 0.97
    Add-BootEntry $state $letter
    Hide-TestuxPartition $state $letter

    Send-Step 'bootentry' 1
    Send-Status @{ done = $true }
}
catch {
    $message = $_.Exception.Message
    if ($state) {
        try {
            Undo-BootSetup
        }
        catch {
            $message += " Undoing the changes failed as well: $($_.Exception.Message)"
            if (Test-Path -LiteralPath $StateFile) {
                $message += ' Remove the Testux boot setup in Testux to try again.'
            }
        }
    }
    Send-Status @{ error = $message }
    $exitCode = 1
}
finally {
    if ($iso -and $iso.MountedByUs) {
        Dismount-DiskImage -ImagePath $IsoPath | Out-Null
    }
}
exit $exitCode
