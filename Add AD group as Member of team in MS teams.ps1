
Connect-MicrosoftTeams
 
 # Team ID for MS teams
$teamId = 'teamID'
 
 #GUID for AD groups
$adGroupIds = @("ADgroupID1", "ADgroupID2", "ADgroupID3", "ADgroupID4", "ADgroupID5" )
 

foreach ($groupId in $adGroupIds) {

    $groupMembers = Get-AdGroupMember -Identity $groupId
 

    foreach ($member in $groupMembers) {

        if ($member.objectClass -eq "user") {
            $userUPN = (Get-ADUser -Identity $member.SamAccountName).UserPrincipalName
 
            if ($userUPN) {
                try {
                    Add-TeamUser -GroupId $teamId -User $userUPN
                    Write-Host "Added user $userUPN to team"
                } catch {
                    Write-Warning "Failed to add user"
                }
            } else {
                Write-Warning "UserPrincipalName for user $($member.SamAccountName) is null or empty"
            }
        }
    }
}