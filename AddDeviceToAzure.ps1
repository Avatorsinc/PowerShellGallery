<# Script below will add your PC to specific Azure Group using powershell

Set-ExecutionPolicy -ExecutionPolicy Unrestricted or Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -CurrentUser

Make sure you have Microsoft.graph module and Ngu

Ignore hashed write-hosts as it was used to debug during creation
#>

Set-PSRepository PSGallery -InstallationPolicy Trusted


#You can remove below and simplify it by install module or edit it creating log file / add clean-up action

try {
    Install-Module -Name PowershellGet -Force -Scope AllUsers -Confirm:$false
    Write-Host "Get module installed successfully."
} catch {
    Write-Host "Error occurred while installing Get: $_" -ForegroundColor Red
}


try {
    Install-Module -Name NuGet -Force -Scope AllUsers -Confirm:$false
    Write-Host "NuGet module installed successfully."
} catch {
    Write-Host "Error occurred while installing NuGet: $_" -ForegroundColor Red
}


try {
    Install-Module -Name Microsoft.Graph -Force -Scope AllUsers -Confirm:$false
    Write-Host "Microsoft.Graph module installed successfully."
} catch {
    Write-Host "Error occurred while installing Microsoft.Graph module: $_" -ForegroundColor Red
}

#Microsoft graph application & Azure information
$tenantId = "TENANTID"
$clientId = "CLIENTID"
$clientSecret = "CLIENTSECRET"
$groupId = "AZURE GROUP ID"
$tokenEndpoint = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
$body = "client_id=$clientId&scope=https%3A%2F%2Fgraph.microsoft.com%2F.default&client_secret=$clientSecret&grant_type=client_credentials"
$response = Invoke-RestMethod -Uri $tokenEndpoint -Method Post -ContentType "application/x-www-form-urlencoded" -Body $body
$token = $response.access_token

#obtain device name and read object.id from Azure
$Name = $env:computername
$secureClientSecret = ConvertTo-SecureString -String $clientSecret -AsPlainText -Force
$clientCredential = New-Object System.Management.Automation.PSCredential($clientId, $secureClientSecret)
Connect-MgGraph -TenantId $tenantId -ClientSecretCredential $clientCredential

#Define the URL for the Microsoft Graph API request. This URL targets the members of a specific group.
#The group ID is dynamically inserted into the URL. The `$ref is used to access the reference link of members in the group.
$url = "https://graph.microsoft.com/v1.0/groups/$groupId/members/`$ref"

#This body includes the `@odata.id` key, which specifies the ID of a directory object (user or group) to be added as a member.
#The `$name03` variable is expected to contain the object ID of the user or group you want to add as a member.
$body = @{
  "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$name03"
} | ConvertTo-Json


 
#Write-Host "Request URL: $url"
#Write-Host "Request Body: $body"
 
$par = @{
    Uri = $url
    Headers = @{Authorization = "Bearer $token"}
    Method = 'POST'
    Body = $body
    ContentType = 'application/json'
}
Invoke-RestMethod @par
 
#Write-Output "Parameters: $($par | Out-String)"
 
 
try {
    #$response = Invoke-RestMethod -Headers @{Authorization = "Bearer $token"} -Uri $url -Method Post -ContentType "application/json" -Body $body
    $response = $par
    Write-Host "Response: $response"
} catch {
    Write-Host "StatusCode: $($_.Exception.Response.StatusCode.Value__)"
    Write-Host "StatusDescription: $($_.Exception.Response.StatusDescription)"
    $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
    $responseBody = $streamReader.ReadToEnd()
    Write-Host "ResponseBody: $responseBody"
}