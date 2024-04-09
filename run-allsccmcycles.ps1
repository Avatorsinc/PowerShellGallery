Function run-Allcycles
{
<#
Run all cycles instead of selecting from run-sccmcycles
#>

$server = read-host -prompt 'Input PC name'



    Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000121}" | Out-Null
    Start-Sleep -Seconds 2
    Write-Progress -Activity "Status Update: 1/12"

    Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000003}" | Out-Null
    Start-Sleep -Seconds 2
    Write-Progress -Activity "Status Update: 2/12"

    Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000010}" | Out-Null
    Start-Sleep -Seconds 2
    Write-Progress -Activity "Status Update: 3/12"

    Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000001}" | Out-Null
    Start-Sleep -Seconds 2
    Write-Progress -Activity "Status Update: 4/12"

    Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000021}" | Out-Null
    Start-Sleep -Seconds 2
    Write-Progress -Activity "Status Update: 5/12"

    Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000022}" | Out-Null
    Start-Sleep -Seconds 2
    Write-Progress -Activity "Status Update: 6/12"
    
    Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000002}" | Out-Null
    Start-Sleep -Seconds 2
    Write-Progress -Activity "Status Update: 7/12"

    Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000031}" | Out-Null
    Start-Sleep -Seconds 2
    Write-Progress -Activity "Status Update: 8/12"

    Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000114}" | Out-Null
    Start-Sleep -Seconds 2
    Write-Progress -Activity "Status Update: 9/12"

    Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000113}" | Out-Null
    Start-Sleep -Seconds 2
    Write-Progress -Activity "Status Update: 10/12"

    Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000111}" | Out-Null
    Start-Sleep -Seconds 2
    Write-Progress -Activity "Status Update: 11/12"

    #this cycles were not used 
    #Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000026}" | Out-Null
    #Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000027}" | Out-Null

    Invoke-WMIMethod -ComputerName $Server -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000032}" | Out-Null
    Start-Sleep -Seconds 2
    Write-Progress -Activity "Status Update: 12/12"

Write-Output 'All cycles runned succesfully'

}