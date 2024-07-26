<#
Not aggressive script to perform clean-up on devices using sccm, for intune refer to disk_cleanup_intune.ps1
Script cleans up windows update files and other unnecessary files & .OST file if it's higher than 10GB (you can change to whatever value you like)
#>

#Percentage of C drive, if less than 10% it will execute the script
$threshold = 10

$drive = Get-PSDrive -Name C
$freeSpaceGB = $drive.Free / 1GB
$totalSpaceGB = $drive.Used / 1GB + $freeSpaceGB
$freeSpacePercentage = ($freeSpaceGB / $totalSpaceGB) * 100

if ($freeSpacePercentage -lt $threshold) {

    #Define the settings number (0009)
    $settingsNumber = 9
    $formattedSettingsNumber = $settingsNumber.ToString("0000")

    #Define the registry path for Disk Cleanup settings - list can be found here  : https://ss64.com/nt/cleanmgr.html
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"

#Define the cleanup items and their state flags - Change by your need
    $cleanupItems = @(
        @{ Name = "Active Setup Temp Folders"; Flag = 2 },
        @{ Name = "Branch Cache"; Flag = 2 },
        @{ Name = "Compress Old Files"; Flag = 2 },
        @{ Name = "Downloaded Program Files"; Flag = 2 },
        @{ Name = "Internet Cache Files"; Flag = 2 },
        @{ Name = "Memory Dump Files"; Flag = 2 },
        @{ Name = "Offline Pages Files"; Flag = 2 },
        @{ Name = "Old ChkDsk Files"; Flag = 2 },
        @{ Name = "Previous Installations"; Flag = 2 },
        @{ Name = "Recycle Bin"; Flag = 2 },
        @{ Name = "Service Pack Cleanup"; Flag = 2 },
        @{ Name = "Setup Log Files"; Flag = 2 },
        @{ Name = "System error memory dump files"; Flag = 2 },
        @{ Name = "System error minidump files"; Flag = 2 },
        @{ Name = "Temporary Files"; Flag = 2 },
        @{ Name = "Temporary Setup Files"; Flag = 2 },
        @{ Name = "Thumbnail Cache"; Flag = 2 },
        @{ Name = "Update Cleanup"; Flag = 2 },
        @{ Name = "Windows Defender"; Flag = 2 },
        @{ Name = "Windows Error Reporting"; Flag = 2 }
    )

    Write-Output "Starting to set registry keys for Disk Cleanup settings..."

    #Set the registry keys for each cleanup item
    foreach ($item in $cleanupItems) {
        $keyPath = "$registryPath\$($item.Name)"
        Write-Output "Processing $keyPath..."
        if (Test-Path $keyPath) {
            try {
                New-ItemProperty -Path $keyPath -Name "StateFlags$formattedSettingsNumber" -Value $item.Flag -PropertyType "DWORD" -Force
                Write-Output "Successfully set $keyPath\StateFlags$formattedSettingsNumber to $($item.Flag)"
            } catch {
                Write-Output "Failed to set registry key for $($item.Name): $_"
            }
        } else {
            Write-Output "Registry path not found: $keyPath"
        }
    }
    Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:$formattedSettingsNumber /VERYLOWDISK" -NoNewWindow -Wait

    $cleanupProcess = Get-Process -Name cleanmgr -ErrorAction SilentlyContinue
    if ($cleanupProcess) {
        Write-Output "Disk Cleanup is running."
    } else {
        Write-Output "Disk Cleanup process completed."
    }

    function Remove-LargeOstFiles {
        #Define limit size of .OST size
        $ostThresholdGB = 10

        $userProfilesPath = "C:\Users"
        $users = Get-ChildItem -Path $userProfilesPath -Directory

        foreach ($user in $users) {
            $ostFilePath = "$userProfilesPath\$($user.Name)\AppData\Local\Microsoft\Outlook"
            if (Test-Path $ostFilePath) {
                $ostFiles = Get-ChildItem -Path $ostFilePath -Filter *.ost -File
                foreach ($ostFile in $ostFiles) {
                    $ostFileSizeGB = $ostFile.Length / 1GB
                    if ($ostFileSizeGB -gt $ostThresholdGB) {
                        try {
                            Write-Output "Removing OST file: $($ostFile.FullName) (Size: $([math]::Round($ostFileSizeGB, 2)) GB)"
                            Remove-Item -Path $ostFile.FullName -Force
                        } catch {
                            Write-Output "Failed to remove OST file $($ostFile.FullName): $_"
                        }
                    }
                }
            } else {
                Write-Output "OST file path not found for user $($user.Name)"
            }
        }
    }
    Remove-LargeOstFiles


} else {
    Write-Output "Free space is above $threshold%. Exiting with code 0."
    exit 0
}