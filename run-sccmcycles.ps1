Function run-cycles
{
<#
  Run SCCM cycles remotely
#>
$server = read-host -prompt 'Input PC name'
Do{
Write-Host '-------------------------------------------------------------------------------------------------------'
Write-Host '1 - Machine policy retrieval & Evaluation Cycle'-ForegroundColor red -BackgroundColor white
Write-Host '-------------------------------------------------------------------------------------------------------'
Write-Host '2 - Machine policy evaluation cycle'-ForegroundColor red -BackgroundColor white
Write-Host '-------------------------------------------------------------------------------------------------------'
Write-Host '3 - Hardware inventory cycle'-ForegroundColor red -BackgroundColor white
Write-Host '-------------------------------------------------------------------------------------------------------'
Write-Host '4 - Software inventory cycle'-ForegroundColor red -BackgroundColor white
Write-Host '-------------------------------------------------------------------------------------------------------'
Write-Host '5 - Discovery Data Collection Cycle'-ForegroundColor red -BackgroundColor white
Write-Host '-------------------------------------------------------------------------------------------------------'
Write-Host '6 - Software updates scan cycle'-ForegroundColor red -BackgroundColor white
Write-Host '-------------------------------------------------------------------------------------------------------'
Write-Host '7 - Software updates deployment evaluation cycle'-ForegroundColor red -BackgroundColor white
Write-Host '-------------------------------------------------------------------------------------------------------'
Write-Host '8 - Software metering usage report cycle'-ForegroundColor red -BackgroundColor white
Write-Host '-------------------------------------------------------------------------------------------------------'
Write-Host '9 - Application deployment evaluation cycle'-ForegroundColor red -BackgroundColor white
Write-Host '-------------------------------------------------------------------------------------------------------'
Write-Host '10 - User policy retrieval'-ForegroundColor red -BackgroundColor white
Write-Host '-------------------------------------------------------------------------------------------------------'
Write-Host '11 - User policy evaluation cycle'-ForegroundColor red -BackgroundColor white
Write-Host '-------------------------------------------------------------------------------------------------------'
Write-Host '12 - Windows installer source list update cycle'-ForegroundColor red -BackgroundColor white
Write-Host '-------------------------------------------------------------------------------------------------------'
Write-Host '13 - File collection'-ForegroundColor red -BackgroundColor white
Write-Host '-------------------------------------------------------------------------------------------------------'
Write-Host 'anything else - Exit'-ForegroundColor red -BackgroundColor white
Write-Host '-------------------------------------------------------------------------------------------------------'
$Cycle = read-host -prompt 'Choose which cycle should be used 1-13'

switch($Cycle){
    1{
    $trigger = "{00000000-0000-0000-0000-000000000021}"
    Invoke-WmiMethod -ComputerName $server -Namespace root\ccm -Class sms_client -Name TriggerSchedule $trigger | Out-Null
    Write-Output 'Success'
}
    2{
    $trigger = "{00000000-0000-0000-0000-000000000022}"
    Invoke-WmiMethod -ComputerName $server -Namespace root\ccm -Class sms_client -Name TriggerSchedule $trigger | Out-Null
    Write-Output 'Success'
}
    3{
    $trigger = "{00000000-0000-0000-0000-000000000001}"
    Invoke-WmiMethod -ComputerName $server -Namespace root\ccm -Class sms_client -Name TriggerSchedule $trigger | Out-Null
    Write-Output 'Success'
}
    4{
    $trigger = "{00000000-0000-0000-0000-000000000002}"
    Invoke-WmiMethod -ComputerName $server -Namespace root\ccm -Class sms_client -Name TriggerSchedule $trigger | Out-Null
    Write-Output 'Success'
}
    5{
    $trigger = "{00000000-0000-0000-0000-000000000003}"
    Invoke-WmiMethod -ComputerName $server -Namespace root\ccm -Class sms_client -Name TriggerSchedule $trigger | Out-Null
    Write-Output 'Success'
}
    6{
    $trigger = "{00000000-0000-0000-0000-000000000113}"
    Invoke-WmiMethod -ComputerName $server -Namespace root\ccm -Class sms_client -Name TriggerSchedule $trigger | Out-Null
    Write-Output 'Success'
}
    7{
    $trigger = "{00000000-0000-0000-0000-000000000114}"
    Invoke-WmiMethod -ComputerName $server -Namespace root\ccm -Class sms_client -Name TriggerSchedule $trigger | Out-Null
    Write-Output 'Success'
}
    8{
    $trigger = "{00000000-0000-0000-0000-000000000031}"
    Invoke-WmiMethod -ComputerName $server -Namespace root\ccm -Class sms_client -Name TriggerSchedule $trigger | Out-Null
    Write-Output 'Success'
}
    9{
    $trigger = "{00000000-0000-0000-0000-000000000121}"
    Invoke-WmiMethod -ComputerName $server -Namespace root\ccm -Class sms_client -Name TriggerSchedule $trigger | Out-Null
    Write-Output 'Success'
}
    10{
    $trigger = "{00000000-0000-0000-0000-000000000026}"
    Invoke-WmiMethod -ComputerName $server -Namespace root\ccm -Class sms_client -Name TriggerSchedule $trigger | Out-Null
    Write-Output 'Success'
}
    11{
    $trigger = "{00000000-0000-0000-0000-000000000027}"
    Invoke-WmiMethod -ComputerName $server -Namespace root\ccm -Class sms_client -Name TriggerSchedule $trigger | Out-Null
    Write-Output 'Success'
}
    12{
    $trigger = "{00000000-0000-0000-0000-000000000032}"
    Invoke-WmiMethod -ComputerName $server -Namespace root\ccm -Class sms_client -Name TriggerSchedule $trigger | Out-Null
    Write-Output 'Success'
}
    13{
    $trigger = "{00000000-0000-0000-0000-000000000010}"
    Invoke-WmiMethod -ComputerName $server -Namespace root\ccm -Class sms_client -Name TriggerSchedule $trigger | Out-Null
    Write-Output 'Success'
}
    default{
        Write-Host 'Bye Bye'
        return
        }
}
}While($true)
}