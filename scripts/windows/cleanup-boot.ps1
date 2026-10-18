#Requires -Version 5.1
<#
.SYNOPSIS
Undoes the Testux boot setup recorded in %ProgramData%\Testux\boot.json.

.DESCRIPTION
Deletes the firmware boot entry and the TESTUX partition, restores BitLocker protection if
prepare-boot.ps1 paused it and, with -ReclaimSpace, grows C: back into the unallocated
space directly behind it, never beyond its original size. Windows can only extend a
partition into free space that directly follows it, so an installed Linux is never
touched.

TESTUX is only deleted after disk, offset, type and label all match the record. If they
do not, the partition is left untouched for safety, the rest is still undone and the
record is moved aside to boot.json.abandoned-<time> so a new setup is possible. That
outcome is reported with code "partition-untouched" and exit code 2.

Safe to run more than once: whatever is already gone is skipped. With -Quiet (used by
prepare-boot.ps1 while undoing a failed setup) no progress is written and errors are
thrown to the caller.
#>
# Script scope parameters are used inside the helper functions, and the helpers are not
# meant to be called on their own, so these two rules only produce noise here.
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
[CmdletBinding()]
param(
    [string] $RunId = '',
    [switch] $ReclaimSpace,
    [switch] $Quiet
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$Label = 'TESTUX'
$BasicDataType = '{ebd0a0a2-b9e5-4433-87c0-68b6b72699c7}'
$DataDir = Join-Path $env:ProgramData 'Testux'
$ProgressFile = Join-Path $DataDir 'progress.jsonl'
$StateFile = Join-Path $DataDir 'boot.json'
$Utf8 = New-Object System.Text.UTF8Encoding $false
$PartitionUntouchedExitCode = 2

function Send-Status([hashtable] $Fields) {
    if ($Quiet) { return }
    $Fields['run'] = $RunId
    $line = ($Fields | ConvertTo-Json -Compress) + "`n"
    [System.IO.File]::AppendAllText($ProgressFile, $line, $Utf8)
}

function Send-Step([string] $Step, [double] $Progress) {
    Send-Status @{ step = $Step; progress = $Progress }
}

function Invoke-Native([string] $FilePath, [string[]] $Arguments) {
    # Native stderr must not turn into terminating errors; the exit code decides.
    $ErrorActionPreference = 'Continue'
    $output = & $FilePath @Arguments 2>&1 | Out-String
    return @{ ExitCode = $LASTEXITCODE; Output = $output.Trim() }
}

function Remove-BootEntry([string] $Entry) {
    if (-not $Entry) { return }
    if ((Invoke-Native 'bcdedit.exe' @('/enum', $Entry)).ExitCode -ne 0) { return }
    $result = Invoke-Native 'bcdedit.exe' @('/delete', $Entry)
    if ($result.ExitCode -ne 0) {
        throw "Removing the boot entry failed: $($result.Output)"
    }
}

# The recorded TESTUX partition, $null if it does not exist (any more).
function Find-TestuxPartition($State) {
    $partitions = @(Get-Partition -DiskNumber $State.diskNumber -ErrorAction SilentlyContinue)
    if ($State.partitionGuid) {
        return $partitions | Where-Object { $_.Guid -eq $State.partitionGuid }
    }
    return $partitions | Where-Object { [int64]$_.Offset -eq [int64]$State.partitionOffset }
}

# Why $Partition must not be deleted, '' if it is exactly the one prepare-boot.ps1 made.
function Get-PartitionMismatch($State, $Partition) {
    if ([int64]$Partition.Offset -ne [int64]$State.partitionOffset -or $Partition.GptType -ne $BasicDataType) {
        return 'The partition at the recorded place is not the Testux partition.'
    }
    $volume = $Partition | Get-Volume -ErrorAction SilentlyContinue
    if ($volume -and $volume.FileSystem -and $volume.FileSystemLabel -ne $Label) {
        return "The partition at the recorded place is labelled '$($volume.FileSystemLabel)', not $Label."
    }
    return ''
}

# Deletes TESTUX. Returns why it was left untouched instead, '' once it is gone.
function Remove-TestuxPartition($State) {
    $partition = Find-TestuxPartition $State
    if (-not $partition) { return '' }
    $mismatch = Get-PartitionMismatch $State $partition
    if (-not $mismatch) {
        $partition | Remove-Partition -Confirm:$false
    }
    return $mismatch
}

# Keeps the record for reference, but out of the way of the next setup.
function Move-BootRecordAside {
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    Move-Item -LiteralPath $StateFile -Destination "$StateFile.abandoned-$stamp"
}

# Turns BitLocker protection back on if this setup paused it and it has not resumed yet.
function Resume-BitLocker($State) {
    if (-not $State.bitLockerSuspended) { return }
    $volume = Get-CimInstance -Namespace 'root\cimv2\Security\MicrosoftVolumeEncryption' `
        -ClassName Win32_EncryptableVolume -Filter "DriveLetter = '$($State.systemDriveLetter):'"
    if (-not $volume -or $volume.ProtectionStatus -ne 0) { return }
    $result = Invoke-CimMethod -InputObject $volume -MethodName EnableKeyProtectors
    if ($result.ReturnValue -ne 0) {
        throw "Turning BitLocker protection back on failed (error $($result.ReturnValue))."
    }
}

function Expand-SystemPartition($State) {
    $system = Get-Partition -DriveLetter $State.systemDriveLetter
    if ($system.DiskNumber -ne $State.diskNumber) { return }
    $supported = Get-PartitionSupportedSize -DiskNumber $system.DiskNumber -PartitionNumber $system.PartitionNumber
    $target = [math]::Min([int64]$supported.SizeMax, [int64]$State.systemOriginalSize)
    if ($target -gt [int64]$system.Size) {
        Resize-Partition -DiskNumber $system.DiskNumber -PartitionNumber $system.PartitionNumber -Size $target
    }
}

# Returns why TESTUX was left untouched, '' when everything was undone.
function Invoke-Cleanup {
    if (-not (Test-Path -LiteralPath $StateFile)) { return '' }
    $state = Get-Content -LiteralPath $StateFile -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($state.version -ne 1) {
        throw "Unknown Testux boot record version $($state.version)."
    }

    Send-Step 'removeentry' 0.1
    Remove-BootEntry $state.bootEntry

    Send-Step 'removepartition' 0.4
    $untouched = Remove-TestuxPartition $state
    Resume-BitLocker $state
    if ($untouched) {
        Move-BootRecordAside
        return "$untouched It was left untouched for safety."
    }

    if ($ReclaimSpace) {
        Send-Step 'reclaim' 0.7
        Expand-SystemPartition $state
    }

    Remove-Item -LiteralPath $StateFile
    return ''
}

if ($Quiet) {
    $untouched = Invoke-Cleanup
    if ($untouched) { throw $untouched }
    return
}

$exitCode = 0
try {
    New-Item -ItemType Directory -Force -Path $DataDir | Out-Null
    [System.IO.File]::WriteAllText($ProgressFile, '', $Utf8)
    $untouched = Invoke-Cleanup
    if ($untouched) {
        Send-Status @{ error = $untouched; code = 'partition-untouched' }
        $exitCode = $PartitionUntouchedExitCode
    }
    else {
        Send-Status @{ done = $true }
    }
}
catch {
    Send-Status @{ error = $_.Exception.Message }
    $exitCode = 1
}
exit $exitCode
