Function Get-LastBootTime
{
<#
        .Synopsis
            Shows last reboot time for CPU.
        .Description
            Shows last CPU boot time on desired host.
#>
        $server = read-host -prompt 'Input PC name'
        $wmi = Get-WmiObject Win32_OperatingSystem -Computer $server
        $obj = $wmi.ConvertToDateTime($wmi.LastBootUpTime)
        Write-Output $obj
    }