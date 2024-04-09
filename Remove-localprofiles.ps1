<#Remove local profiles in loop by select number
  there was bug in this function but i can't remember what exactly #>


function Remove-LocalProfiles {
    param (
        [string]$Computer
    )

 

    $continue = $true

 

    while ($continue) {
        $profileList = @()

 

        try {
            $profileFolders = Get-WmiObject -ComputerName $Computer -Query "SELECT * FROM Win32_UserProfile" | Where-Object { $_.Special -eq $false }

 

            if ($profileFolders.Count -eq 0) {
                Write-Host "No local profiles found on $Computer"
                return
            }

 

            Write-Host "Local profiles found on $Computer"

 

            for ($i = 0; $i -lt $profileFolders.Count; $i++) {
                $profile = $profileFolders[$i]
                $lastLoginTime = [System.Management.ManagementDateTimeConverter]::ToDateTime($profile.LastUseTime)
                Write-Host "$i. User: $($profile.LocalPath.Split('\')[-1]), Profile Path: $($profile.LocalPath), Last Login Time: $($lastLoginTime.ToShortDateString()) $($lastLoginTime.ToShortTimeString())"
            }

 

            $selection = Read-Host "Enter the number of the profile to remove (Q to quit)"

 

            if ($selection -eq "Q" -or $selection -eq "q") {
                $continue = $false
            } elseif ($selection -ge 0 -and $selection -lt $profileFolders.Count) {
                $profileToRemove = $profileFolders[$selection]
                Write-Host "Removing local profile for $($profileToRemove.LocalPath)..."

                $result = $profileToRemove.Delete()

 

                if ($result.ReturnValue -eq 0) {
                    Write-Host "Local profile for $($profileToRemove.LocalPath) has been removed."
                } else {
                    Write-Host "Removed"
                }
            } else {
                Write-Host "Invalid selection."
            }
        } catch {
            Write-Host "Error: $($_.Exception.Message)"
        }
    }
}