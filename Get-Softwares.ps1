#Get all installed softwares

Function Get-Softwares
{
        param (
        [string]$Computer
    )


    $softwareList = @()

    $registryPaths = @(
        "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        "SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    )

 

    foreach ($registryPath in $registryPaths) {
        $registry = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $Computer)
        $subKeys = $registry.OpenSubKey($registryPath).GetSubKeyNames()

 

        foreach ($subKey in $subKeys) {
            $key = $registry.OpenSubKey("$registryPath\$subKey")
            $displayName = $key.GetValue("DisplayName")

 

            if ($displayName -ne $null) {
                $softwareList += $displayName
            }
        }
    }

    Write-Host "Installed software on $Computer"

    $i = 1
    foreach ($software in $softwareList) {
        Write-Host "$i. $software"
        $i++
    }
}