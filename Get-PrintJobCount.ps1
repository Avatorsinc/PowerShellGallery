#retrive total job count from remote server

function Get-PrintJobCount {
    param (
        [string]$PrintServer
    )

    try {
        $printJobs = Get-WmiObject -Query "SELECT * FROM Win32_PrintJob" -ComputerName $PrintServer

        if ($printJobs.Count -eq 0) {
            Write-Host "No active print jobs found on server '$ServerName'."
            return
        }

        Write-Host "Active print jobs found on server '$PrintServer':"
        Write-Host "Number of active print jobs: $($printJobs.Count)"
    } catch {
        Write-Host "Error: $($_.Exception.Message)"
    }
}