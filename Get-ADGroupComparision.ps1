Function Get-ADGroupComparision{

<#
compare AD groups of users
#>

    [CmdletBinding()] 
    param (
        [Parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$True,ValueFromPipeline=$True,
        HelpMessage="1st")] 
        [string]$Identity1,

        [Parameter(ValueFromPipelineByPropertyName=$true,Mandatory=$False,ValueFromPipeline=$True,
        HelpMessage="2nd")] 
        [string]$Identity2
    )

    $user1 = (Get-ADPrincipalGroupMembership -Identity $Identity1 | select Name | Sort-Object -Property Name).Name
    Write-Verbose ($user1 -join "; ")
    $user2 = (Get-ADPrincipalGroupMembership -Identity $Identity2 | select Name | Sort-Object -Property Name).Name
    Write-Verbose ""
    Write-Verbose ($user2 -join "; ")
    $SameGroups = (Compare-Object $user1 $user2 -PassThru -IncludeEqual -ExcludeDifferent)
    Write-Verbose ""
    Write-Verbose ($SameGroups -join "; ")
    $UniqueID1 = (Compare-Object $user1 $user2 -PassThru | where {$_.SideIndicator -eq "<="})
    Write-Verbose ""
    Write-Verbose ($UniqueID1 -join "; ")
    $UniqueID2 = (Compare-Object $user1 $user2 -PassThru | where {$_.SideIndicator -eq "=>"})
    Write-Verbose ""
    Write-Verbose ($UniqueID2 -join "; ")
    $ID1Name = (Get-ADUser -Identity $Identity1 | Select Name).Name
    Write-Verbose ""
    Write-Verbose ($ID1Name -join "; ")
    $ID2Name = (Get-ADUser -Identity $Identity2 | Select Name).Name
    Write-Verbose ""
    Write-Verbose ($ID2Name -join "; ")

    Write-Host "-----------------------------------------------------------------------------------"
    Write-Host "[$ID1Name] and [$ID2Name] have the same groups:"
    Write-Host "-----------------------------------------------------------------------------------"
    $SameGroups
    Write-Host ""

    Write-Host "-----------------------------------------------------------------------------------"
    Write-Host "The following groups are unique to [$ID1Name]:"
    Write-Host "-----------------------------------------------------------------------------------"
    $UniqueID1
    Write-Host ""
    Write-Host "-----------------------------------------------------------------------------------"
    Write-Host "The following groups are unique to [$ID2Name]:"
    Write-Host "-----------------------------------------------------------------------------------"
    $UniqueID2
    Write-Host "-----------------------------------------------------------------------------------"

}