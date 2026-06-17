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
