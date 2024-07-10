# Install and Import Microsoft Teams PowerShell Module
Install-Module -Name MicrosoftTeams -Force -AllowClobber
Import-Module MicrosoftTeams

# Authenticate to Microsoft Teams
$credential = Get-Credential
Connect-MicrosoftTeams -Credential $credential

# Define the team name and retrieve group information
$teamName = "team name"
$group = Get-Team | Where-Object {$_.DisplayName -eq $teamName}
$groupId = $group.GroupId

# Define the users to add as owners
$usersToAdd = @("guest@guest.com", "guest@guest.com")
$userIds = @()

# Get User IDs
foreach ($user in $usersToAdd) {
    $userId = (Get-TeamUser -GroupId $groupId | Where-Object {$_.User -eq $user}).UserId
    $userIds += $userId
}

# Add Users as Owners
foreach ($userId in $userIds) {
    Add-TeamUser -GroupId $groupId -User $userId -Role Owner
}

# Disconnect from Microsoft Teams
Disconnect-MicrosoftTeams
