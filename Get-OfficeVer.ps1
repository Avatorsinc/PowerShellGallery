#Function to read office version

function Get-OfficeVer ($computer = $env:COMPUTERNAME) {
    $version = $null
    $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $computer)
    try {
        $reg.OpenSubKey('SOFTWARE\Microsoft\Office').GetSubKeyNames() | ForEach-Object {
            if ($_ -match '(\d+\.\d+)') {  
                $numericVersion = [int][math]::Truncate([decimal]$_)  
                if ($numericVersion -gt $version) {
                    $version = $_  
                }
            }
        }
    } catch {
        Write-Error "Failed to query the registry: $($_.Exception.Message)"
    }

    if ($version -ne $null) {
        return $version
    } else {
        Write-Output "No Office version found."
        return $null  
    }
}
