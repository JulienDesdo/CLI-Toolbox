Get-NetTCPConnection | ForEach-Object {
    $Process = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
    [PSCustomObject]@{
        LocalPort = $_.LocalPort
        RemotePort = $_.RemotePort
        State = $_.State
        ProcessId = $_.OwningProcess
        ProcessName = if ($Process) { $Process.ProcessName } else { "Unknown" }
    }
} | Format-Table -AutoSize
