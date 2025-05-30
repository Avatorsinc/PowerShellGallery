<#
.SYNOPSIS
    Convert system disk from MBR → GPT and enable Secure Boot and UEFI on HP EliteBook.

.DESCRIPTION
    - Validates and safely converts boot disk from MBR to GPT.
    - Enables Secure Boot and UEFI Native Mode in BIOS.
    - Verifies BIOS settings without automatic restart.
    - Verified on HP EliteBook G1–G6 models.
    - For models higher than G6, verify BIOS setting names and adjust script accordingly.
    - Provide BIOS setup password (if applicable).

.NOTES
    Author   : Avatorsinc@gmail.com
    Date     : 2024-05-29
    Version  : 1.0
    Reference: Based on scripts by Matthew D. Daugherty and community contributions from GitHub/Reddit.
#>


if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw "Run script as Administrator."
}

# Ensure BIOS Module Available
function Ensure-Module($Name) {
    if (-not (Get-Module -ListAvailable -Name $Name)) {
        Install-Module -Name $Name -Scope CurrentUser -Force
    }
}
$sysDisk = Get-Disk | Where-Object IsBoot -EQ $true
if (-not $sysDisk) { throw "Boot disk not found." }

if ($sysDisk.PartitionStyle -eq 'MBR') {
    Write-Host "Validating disk for GPT conversion..."
    mbr2gpt.exe /validate /disk:$($sysDisk.Number) /allowFullOS
    if ($LASTEXITCODE -ne 0) { throw "Validation failed." }

    Write-Host "Converting disk to GPT..."
    mbr2gpt.exe /convert /disk:$($sysDisk.Number) /allowFullOS
    if ($LASTEXITCODE -ne 0) { throw "GPT conversion failed." }
}
else {
    Write-Host "Disk already GPT — skipping conversion."
}

$BiosPassword = ''
$BiosPassword_UTF = "<utf-16/>$BiosPassword"

$BiosSettings = Get-WmiObject -Namespace root/hp/instrumentedBIOS -Class HP_BiosEnumeration
$Bios = Get-WmiObject -Namespace root/hp/instrumentedBIOS -Class HP_BiosSettingInterface
$biosConfigs = @{
    'Configure Legacy Support and Secure Boot' = 'Legacy Support Disable and Secure Boot Enable'
    'Legacy Boot Options'                    = 'Disable'
    'UEFI Boot Options'                      = 'Enable'
    'Legacy Support'                         = 'Disable'
    'Secure Boot'                            = 'Enable'
    'SecureBoot'                             = 'Enable'
    'Boot Mode'                              = 'UEFI Native (Without CSM)'
}

foreach ($setting in $biosConfigs.GetEnumerator()) {
    if ($BiosSettings | Where-Object { $_.Name -eq $setting.Key -or $_.PossibleValues -contains $setting.Value }) {
        Write-Host "Setting BIOS '$($setting.Key)' → '$($setting.Value)'"
        [void]$Bios.SetBiosSetting($setting.Key, $setting.Value, $BiosPassword_UTF)
    }
}
Write-Host "Validating BIOS configuration (manual reboot required to apply fully):"

$validationResults = Get-WmiObject -Namespace root/hp/instrumentedBIOS -Class HP_BiosEnumeration |
    Where-Object Name -in $biosConfigs.Keys |
    Select-Object Name, CurrentValue

$validationResults | Format-Table -AutoSize

Write-Host "`nManual reboot required to fully apply BIOS changes."
Write-Host "Reboot manually to finalize UEFI & Secure Boot activation."
# here automatic reboot or inside TS depending which approach ?
