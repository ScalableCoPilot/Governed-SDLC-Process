[CmdletBinding()]
param(
    [ValidateSet('Start', 'Stop', 'Status', 'Run')]
    [string]$Action = 'Status',
    [string]$RunId
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ($env:OS -ne 'Windows_NT') {
    throw 'ApprovalAlarm requires Windows and Windows PowerShell 5.1.'
}
if (-not $env:LOCALAPPDATA) {
    throw 'LOCALAPPDATA must be available for alarm runtime records.'
}

$checkout = Split-Path $PSScriptRoot -Parent
$sha = [System.Security.Cryptography.SHA256]::Create()
try {
    $key = ([BitConverter]::ToString($sha.ComputeHash(
        [Text.Encoding]::UTF8.GetBytes($checkout.ToLowerInvariant())
    ))).Replace('-', '').Substring(0, 24)
}
finally {
    $sha.Dispose()
}
$runtime = Join-Path $env:LOCALAPPDATA "AICustomerManagement\ApprovalAlarm\$key"
$currentPath = Join-Path $runtime 'current.json'
[IO.Directory]::CreateDirectory($runtime) | Out-Null

function Write-Record($Path, $Record) {
    $temporary = "$Path.$([guid]::NewGuid().ToString('N')).tmp"
    try {
        [IO.File]::WriteAllText($temporary, ($Record | ConvertTo-Json))
        if ([IO.File]::Exists($Path)) {
            [IO.File]::Replace($temporary, $Path, [System.Management.Automation.Language.NullString]::Value)
        }
        else {
            [IO.File]::Move($temporary, $Path)
        }
    }
    finally {
        if ([IO.File]::Exists($temporary)) { [IO.File]::Delete($temporary) }
    }
}

function Read-Record($Path) {
    for ($attempt = 0; $attempt -lt 5; $attempt++) {
        $stream = $null
        $reader = $null
        try {
            $stream = [IO.File]::Open($Path, [IO.FileMode]::Open, [IO.FileAccess]::Read,
                ([IO.FileShare]::ReadWrite -bor [IO.FileShare]::Delete))
            $reader = [IO.StreamReader]::new($stream)
            return ($reader.ReadToEnd() | ConvertFrom-Json)
        }
        catch [IO.IOException] {
            # Windows can briefly lock the destination during an atomic replacement.
            $code = $_.Exception.GetBaseException().HResult -band 0xffff
            if ($code -notin @(32, 33) -or $attempt -eq 4) { throw }
            Start-Sleep -Milliseconds 20
        }
        finally {
            if ($null -ne $reader) { $reader.Dispose() }
            if ($null -ne $stream) { $stream.Dispose() }
        }
    }
}

function Get-AlarmProcess($Record) {
    try {
        $candidate = [Diagnostics.Process]::GetProcessById([int]$Record.ProcessId)
    }
    catch [ArgumentException] {
        return $null
    }
    try {
        $matches = -not $candidate.HasExited -and
            $candidate.StartTime.ToUniversalTime().Ticks.ToString() -eq $Record.ProcessStartTicks
    }
    catch [InvalidOperationException] {
        $candidate.Dispose()
        return $null
    }
    if (-not $matches) {
        $candidate.Dispose()
        return $null
    }
    return $candidate
}

function Get-AlarmStatus {
    if (-not (Test-Path -LiteralPath $currentPath)) {
        return [pscustomobject]@{ State = 'Idle'; RuntimeDirectory = $runtime }
    }
    $record = Read-Record $currentPath
    $resultPath = Join-Path $runtime "$($record.RunId).json"
    $process = Get-AlarmProcess $record
    try {
        if (Test-Path -LiteralPath $resultPath) {
            $result = Read-Record $resultPath
        }
        else {
            $result = [pscustomobject]@{
                State = 'Starting'; ElapsedSeconds = 0; SoundsPlayed = 0; Error = $null
            }
        }
        $alive = $null -ne $process -and -not $process.HasExited
        if (-not $alive -and $result.State -in @('Starting', 'Playing')) {
            $result.State = 'Failed'
            $result.Error = "Worker exited without a final result. Inspect $($record.ErrorLog)"
        }
        return [pscustomobject]@{
            State = $result.State
            WorkerAlive = $alive
            ProcessId = $record.ProcessId
            RunId = $record.RunId
            DurationSeconds = 300
            ElapsedSeconds = $result.ElapsedSeconds
            SoundsPlayed = $result.SoundsPlayed
            Error = $result.Error
            ResultPath = $resultPath
            ErrorLog = $record.ErrorLog
            RuntimeDirectory = $runtime
        }
    }
    finally {
        if ($null -ne $process) { $process.Dispose() }
    }
}

if ($Action -eq 'Run') {
    $parsedId = [guid]::Empty
    if (-not [guid]::TryParseExact($RunId, 'N', [ref]$parsedId)) {
        throw 'Run is an internal worker action and requires a valid run identifier.'
    }
    $resultPath = Join-Path $runtime "$RunId.json"
    $stopPath = Join-Path $runtime "$RunId.stop"
    $clock = [Diagnostics.Stopwatch]::StartNew()
    $sounds = 0
    $player = $null
    $stream = $null
    $writer = $null
    try {
        # A generated WAV avoids dependence on a possibly disabled Windows sound theme.
        $sampleRate = 22050
        $sampleCount = [int]($sampleRate * 0.4)
        $stream = [IO.MemoryStream]::new()
        $writer = [IO.BinaryWriter]::new($stream, [Text.Encoding]::ASCII, $true)
        $writer.Write([Text.Encoding]::ASCII.GetBytes('RIFF'))
        $writer.Write([int](36 + $sampleCount * 2))
        $writer.Write([Text.Encoding]::ASCII.GetBytes('WAVEfmt '))
        $writer.Write([int]16)
        $writer.Write([int16]1)
        $writer.Write([int16]1)
        $writer.Write([int]$sampleRate)
        $writer.Write([int]($sampleRate * 2))
        $writer.Write([int16]2)
        $writer.Write([int16]16)
        $writer.Write([Text.Encoding]::ASCII.GetBytes('data'))
        $writer.Write([int]($sampleCount * 2))
        for ($i = 0; $i -lt $sampleCount; $i++) {
            $writer.Write([int16](10000 * [Math]::Sin(2 * [Math]::PI * 880 * $i / $sampleRate)))
        }
        $writer.Flush()
        $stream.Position = 0
        $player = [System.Media.SoundPlayer]::new($stream)
        $player.Load()
        $clock.Restart()
        Write-Record $resultPath @{
            State = 'Playing'; ElapsedSeconds = 0; SoundsPlayed = 0; Error = $null
        }
        while ($clock.Elapsed.TotalSeconds -lt 300 -and -not (Test-Path -LiteralPath $stopPath)) {
            $player.PlaySync()
            $sounds++
            Write-Record $resultPath @{
                State = 'Playing'; ElapsedSeconds = $clock.Elapsed.TotalSeconds
                SoundsPlayed = $sounds; Error = $null
            }
            $nextSound = $clock.Elapsed.TotalSeconds + 1.6
            while ($clock.Elapsed.TotalSeconds -lt $nextSound -and
                $clock.Elapsed.TotalSeconds -lt 300 -and
                -not (Test-Path -LiteralPath $stopPath)) {
                Start-Sleep -Milliseconds 100
            }
        }
        $state = 'Completed'
        if (Test-Path -LiteralPath $stopPath) { $state = 'Stopped' }
        Write-Record $resultPath @{
            State = $state; ElapsedSeconds = $clock.Elapsed.TotalSeconds
            SoundsPlayed = $sounds; Error = $null
        }
    }
    catch {
        Write-Record $resultPath @{
            State = 'Failed'; ElapsedSeconds = $clock.Elapsed.TotalSeconds
            SoundsPlayed = $sounds; Error = $_.Exception.Message
        }
        throw
    }
    finally {
        if ($null -ne $player) { $player.Dispose() }
        if ($null -ne $writer) { $writer.Dispose() }
        if ($null -ne $stream) { $stream.Dispose() }
    }
    return
}

$mutex = [Threading.Mutex]::new($false, "Local\AICustomerManagement.ApprovalAlarm.$key")
$locked = $false
try {
    try { $locked = $mutex.WaitOne(3000) }
    catch [Threading.AbandonedMutexException] { $locked = $true }
    if (-not $locked) { throw 'Another alarm control command is active. Retry shortly.' }

    if ($Action -eq 'Status') {
        Get-AlarmStatus
        return
    }
    if (Test-Path -LiteralPath $currentPath) {
        $record = Read-Record $currentPath
        $existing = Get-AlarmProcess $record
    }
    else {
        $existing = $null
    }
    try {
        if ($Action -eq 'Stop') {
            if ($null -ne $existing -and -not $existing.HasExited) {
                [IO.File]::WriteAllText((Join-Path $runtime "$($record.RunId).stop"), 'stop')
                if (-not $existing.WaitForExit(5000)) {
                    throw "Alarm did not stop within five seconds. Inspect $(Join-Path $runtime "$($record.RunId).json")."
                }
            }
            Get-AlarmStatus
            return
        }
        if ($null -ne $existing -and -not $existing.HasExited) {
            [IO.File]::WriteAllText((Join-Path $runtime "$($record.RunId).stop"), 'stop')
            if (-not $existing.WaitForExit(5000)) {
                throw 'Existing alarm did not stop; a second worker will not be started.'
            }
        }
    }
    finally {
        if ($null -ne $existing) { $existing.Dispose() }
    }

    $id = [guid]::NewGuid().ToString('N')
    $errorLog = Join-Path $runtime "$id.stderr.log"
    $hostPath = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
    $worker = Start-Process -FilePath $hostPath -ArgumentList @(
        '-NoLogo', '-NoProfile', '-NonInteractive', '-File', "`"$PSCommandPath`"",
        '-Action', 'Run', '-RunId', $id
    ) -WindowStyle Hidden -RedirectStandardError $errorLog -PassThru
    try {
        Write-Record $currentPath @{
            RunId = $id; ProcessId = $worker.Id
            ProcessStartTicks = $worker.StartTime.ToUniversalTime().Ticks.ToString()
            ErrorLog = $errorLog
        }
    }
    catch {
        # If publication fails, do not leave an unmanageable background worker.
        [IO.File]::WriteAllText((Join-Path $runtime "$id.stop"), 'stop')
        throw
    }
    finally {
        $worker.Dispose()
    }
    Get-AlarmStatus
}
finally {
    if ($locked) { $mutex.ReleaseMutex() }
    $mutex.Dispose()
}
