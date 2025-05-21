$sysDisk = Get-Disk | Where-Object IsBoot -EQ $true
if ($sysDisk.PartitionStyle -EQ 'MBR') {
    Write-Host "Validating disk $($sysDisk.Number) for GPT conversion..."
    mbr2gpt.exe /validate /disk:$($sysDisk.Number) /allowFullOS
    if ($LASTEXITCODE -ne 0) {
        Throw "Disk validation failed. Aborting."
    }
    Write-Host "Converting disk $($sysDisk.Number) to GPT..."
    mbr2gpt.exe /convert /disk:$($sysDisk.Number) /allowFullOS
    if ($LASTEXITCODE -ne 0) {
        Throw "MBR→GPT conversion failed."
    }
} else {
    Write-Host "Disk is already GPT—skipping MBR2GPT."
}

$manufacturer = (Get-CimInstance Win32_ComputerSystem).Manufacturer
switch ($manufacturer) {
    'Dell Inc.' {
        Write-Host "Configuring Dell BIOS→UEFI…"
        Import-Module DellBIOSProvider -ErrorAction Stop
        Set-Item -Path 'DellSmbios:\BootSequence\BootListOption' -Value 'UEFI'
    }
    'HP' {
        Write-Host "Configuring HP BIOS→UEFI…"
        Import-Module HPBIOSCmdlets -ErrorAction Stop
        Set-HPUEFIBootMode -EnableUEFI
    }
    'Lenovo' {
        Write-Host "Configuring Lenovo BIOS→UEFI…"
        $set = Get-CimInstance -Namespace root\wmi -Class Lenovo_SetBiosSetting
        $set.SetBiosSetting('BootMode,UEFI')
        $save = Get-CimInstance -Namespace root\wmi -Class Lenovo_SaveBiosSettings
        $save.SaveBiosSettings()
    }
    default {
        Write-Warning "Unsupported OEM '$manufacturer'. Manual firmware change required."
    }
}

Write-Host "Rebooting into UEFI mode…"
Restart-Computer -Force

