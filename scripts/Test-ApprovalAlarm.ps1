[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$alarm = Join-Path $PSScriptRoot 'ApprovalAlarm.ps1'

function Assert($Condition, $Message) {
    if (-not $Condition) { throw $Message }
}

function Wait-ForState($Expected, $TimeoutSeconds) {
    $wait = [Diagnostics.Stopwatch]::StartNew()
    do {
        $status = & $alarm -Action Status
        if ($status.State -eq 'Failed') {
            throw "Alarm failed: $($status.Error). Error log: $($status.ErrorLog)"
        }
        if ($status.State -eq $Expected) { return $status }
        Start-Sleep -Milliseconds 200
    } while ($wait.Elapsed.TotalSeconds -lt $TimeoutSeconds)
    throw "Timed out waiting for $Expected; actual state: $($status.State)."
}

$tokens = $null
$parseErrors = $null
[Management.Automation.Language.Parser]::ParseFile($alarm, [ref]$tokens, [ref]$parseErrors) | Out-Null
Assert ($parseErrors.Count -eq 0) 'Alarm script has PowerShell syntax errors.'
$initial = & $alarm -Action Status
Assert ($initial.State -notin @('Starting', 'Playing')) 'An existing alarm is active; stop it before testing.'
$ownedRun = $null
try {
    $latency = [Diagnostics.Stopwatch]::StartNew()
    $first = & $alarm -Action Start
    $latency.Stop()
    $ownedRun = $first.RunId
    Assert ($latency.Elapsed.TotalSeconds -lt 5) 'Start blocked for five seconds or longer.'
    $playing = Wait-ForState 'Playing' 15
    Assert $playing.WorkerAlive 'The background worker is not alive.'
    Write-Output "PASS: nonblocking start ($($latency.Elapsed.TotalSeconds) seconds), worker PID $($playing.ProcessId)."

    Start-Sleep -Seconds 3
    $restartClock = [Diagnostics.Stopwatch]::StartNew()
    $duplicate = & $alarm -Action Start
    $restartClock.Stop()
    $ownedRun = $duplicate.RunId
    Assert ($duplicate.RunId -ne $first.RunId) 'A new checkpoint did not restart the five-minute window.'
    $prior = Get-Content -LiteralPath $first.ResultPath -Raw | ConvertFrom-Json
    Assert ($prior.State -eq 'Stopped') 'Repeated Start did not stop the previous alarm before replacement.'
    Assert ($restartClock.Elapsed.TotalSeconds -lt 5) 'Repeated Start blocked for five seconds or longer.'
    $playing = Wait-ForState 'Playing' 15
    Assert $playing.WorkerAlive 'Replacement worker is not alive.'
    Write-Output "PASS: repeated Start resets the five-minute window without overlapping workers ($($restartClock.Elapsed.TotalSeconds) seconds)."

    Start-Sleep -Seconds 3
    $stopClock = [Diagnostics.Stopwatch]::StartNew()
    $stopped = & $alarm -Action Stop
    $stopClock.Stop()
    Assert ($stopped.State -eq 'Stopped') 'Manual Stop did not record Stopped.'
    Assert (-not $stopped.WorkerAlive) 'Manual Stop left the worker alive.'
    Assert ($stopClock.Elapsed.TotalSeconds -lt 5) 'Manual Stop took five seconds or longer.'
    Write-Output "PASS: manual Stop ($($stopClock.Elapsed.TotalSeconds) seconds)."
    $again = & $alarm -Action Stop
    Assert ($again.State -eq 'Stopped') 'Repeated Stop is not idempotent.'

    $restarted = & $alarm -Action Start
    $ownedRun = $restarted.RunId
    Assert ($restarted.RunId -ne $first.RunId) 'Restart reused the stopped run.'
    $playing = Wait-ForState 'Playing' 15
    Write-Output "Full five-minute audio test running. PID: $($playing.ProcessId); result: $($playing.ResultPath)"
    $completed = Wait-ForState 'Completed' 360
    Assert ($completed.ElapsedSeconds -ge 300) 'Playback ended before 300 seconds.'
    Assert ($completed.SoundsPlayed -ge 100) 'The full run did not repeat enough sounds.'
    $exitWait = [Diagnostics.Stopwatch]::StartNew()
    while ($completed.WorkerAlive -and $exitWait.Elapsed.TotalSeconds -lt 5) {
        Start-Sleep -Milliseconds 100
        $completed = & $alarm -Action Status
    }
    Assert (-not $completed.WorkerAlive) 'Worker remained alive after completion.'
    Write-Output "PASS: full run completed after $($completed.ElapsedSeconds) seconds with $($completed.SoundsPlayed) sounds."
    $completed | Format-List
    Write-Output 'Actual audibility must also be confirmed by a person at the Windows machine.'
}
finally {
    $last = & $alarm -Action Status
    if ($null -ne $ownedRun -and $last.RunId -eq $ownedRun -and $last.WorkerAlive) {
        & $alarm -Action Stop | Out-Null
    }
}
