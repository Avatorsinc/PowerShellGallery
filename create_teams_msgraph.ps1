<# Microsoft Graph script to create Microsoft Teams group from input,
this script allows you to create teams using JWT token & ms graph
firstly it creates online group in azure then converts it into ms teams
#>

[CmdletBinding()]
param([parameter(Mandatory=$true)][string]$Creator,
[parameter(Mandatory=$true)][string]$Name,
[parameter(Mandatory=$true)][string]$Description,
[parameter(Mandatory=$true)][string[]]$Owners,
[parameter(Mandatory=$true)][string[]]$Members)

$OwnersArray = $Owners -split ","
$MembersArray = $Members -split ","

#Write-Host "OwnersArray: $($OwnersArray -join ', ')"
#Write-Host "MembersArray: $($MembersArray -join ', ')"

#fill with your data
$clientId = "clientid"
$tenantId = "tenantid"
$thumbprint = "certificate thumbprint"

function Base64UrlEncode {
    param (
        [byte[]]$bytes
    )
    [System.Convert]::ToBase64String($bytes) -replace '\+', '-' -replace '/', '_' -replace '='
}

function HexStringToByteArray {
    param (
        [string]$hex
    )
    [byte[]]$bytes = @()
    for ($i = 0; $i -lt $hex.Length; $i += 2) {
        $bytes += [Convert]::ToByte($hex.Substring($i, 2), 16)
    }
    return $bytes
}

function Get-JwtToken {
    param (
        [string]$tenantId,
        [string]$clientId,
        [string]$thumbprint
    )

    $header = @{
        alg = "RS256"
        typ = "JWT"
        x5t = Base64UrlEncode(HexStringToByteArray($thumbprint))
    }

    $certificate = Get-ChildItem -Path Cert:\CurrentUser\My | Where-Object { $_.Thumbprint -eq $thumbprint } #change according to your path \LocalMachine ect.. 
    if (-not $certificate) {
        Write-Error "Certificate with thumbprint $thumbprint not found."
        exit
    }

    $rsa = [System.Security.Cryptography.X509Certificates.RSACertificateExtensions]::GetRSAPrivateKey($certificate)

    $now = [DateTimeOffset]::UtcNow
    $expiration = $now.AddMinutes(60)
    
    $payload = @{
        aud = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
        iss = $clientId
        sub = $clientId
        jti = [Guid]::NewGuid().ToString()
        iat = [int]($now.ToUnixTimeSeconds())
        nbf = [int]($now.ToUnixTimeSeconds())
        exp = [int]($expiration.ToUnixTimeSeconds())
    }

    $headerJson = Base64UrlEncode([System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json $header -Compress)))
    $payloadJson = Base64UrlEncode([System.Text.Encoding]::UTF8.GetBytes((ConvertTo-Json $payload -Compress)))
    $stringToSign = "$headerJson.$payloadJson"
    $bytesToSign = [System.Text.Encoding]::UTF8.GetBytes($stringToSign)
    $signedBytes = $rsa.SignData($bytesToSign, [System.Security.Cryptography.HashAlgorithmName]::SHA256, [System.Security.Cryptography.RSASignaturePadding]::Pkcs1)

    $signatureEncoded = Base64UrlEncode($signedBytes)
    return "$headerJson.$payloadJson.$signatureEncoded"
}

$jwtToken = Get-JwtToken -tenantId $tenantId -clientId $clientId -thumbprint $thumbprint

$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -Method Post -ContentType "application/x-www-form-urlencoded" -Body @{
    client_id = $clientId
    scope = "https://graph.microsoft.com/.default"
    client_assertion_type = "urn:ietf:params:oauth:client-assertion-type:jwt-bearer"
    client_assertion = $jwtToken
    grant_type = "client_credentials"
}

$accessToken = $tokenResponse.access_token

$headers = @{
    Authorization = "Bearer $accessToken"
    "Content-type" = "application/json"
}

# Here is function to fetch users by object.id
function Get-UserIdByEmail {
    param (
        [string]$email
    )
    $userUrl = "https://graph.microsoft.com/v1.0/users/?`$filter=userPrincipalName eq '$email'"
    Write-Host "Fetching user ID for email: $email"
    Write-Host "Request URL: $userUrl"
    try {
        $user = Invoke-RestMethod -Uri $userUrl -Headers $headers -Method Get
        Write-Host "Response: $(ConvertTo-Json $user)"
        if ($user.value.Count -gt 0) {
            return $user.value[0].id
        } else {
            Write-Error "No user found for ${email}"
            return $null
        }
    } catch {
        Write-Error "Failed to retrieve user ID for ${email}: $($_.Exception.Message)"
        return $null
    }
}

$ownerIds = @()
$creatorId = Get-UserIdByEmail $Creator
$memberIds = @()

$OwnersArray | ForEach-Object {
    $ownerId = Get-UserIdByEmail $_
    if ($null -ne $ownerId) {
        $ownerIds += $ownerId
    }
}

$MembersArray | ForEach-Object {
    $memberId = Get-UserIdByEmail $_
    if ($null -ne $memberId) {
        $memberIds += $memberId
    }
}

if ($null -eq $creatorId -or $ownerIds.Count -eq 0 -or $memberIds.Count -eq 0) {
    Write-Error "One or more user IDs could not be retrieved. Please check the provided email addresses."
    Stop-Transcript
    exit
}

$allOwnerIds = @()
$allOwnerIds += $ownerIds
$allOwnerIds += $creatorId

$ownerBindings = @($allOwnerIds | ForEach-Object { "https://graph.microsoft.com/v1.0/users/$_" })
$memberBindings = @($memberIds | ForEach-Object { "https://graph.microsoft.com/v1.0/users/$_" })

# you can change below settings or add more values
$groupBody = @{
    displayName     = $Name
    mailNickname    = $Name
    description     = $Description
    'owners@odata.bind' = $ownerBindings
    'members@odata.bind' = $memberBindings
    groupTypes      = @("Unified")
    mailEnabled     = $true
    securityEnabled = $false
    visibility      = "Private"
} | ConvertTo-Json -Depth 5

try {
    $groupResponse = Invoke-RestMethod -Uri "https://graph.microsoft.com/v1.0/groups" -Headers $headers -Method Post -Body $groupBody
    $groupId = $groupResponse.id
    Write-Host "Group created with ID: $groupId"

    start-sleep 45
    #teamssettings
    $teamBody = @{
        'memberSettings' = @{
            'allowCreateUpdateChannels' = $true
        }
        'messagingSettings' = @{
            'allowUserEditMessages' = $true
            'allowUserDeleteMessages' = $true
        }
        'funSettings' = @{
            'allowGiphy' = $true
            'giphyContentRating' = "strict"
        }
    } | ConvertTo-Json

    $addTeamUrl = "https://graph.microsoft.com/v1.0/groups/$groupId/team"
    Invoke-RestMethod -Uri $addTeamUrl -Headers $headers -Method Put -Body $teamBody
    Write-Host "Microsoft Teams team created and associated with the group."
} catch {
    Write-Error "Failed to create group or Microsoft Teams team: $($_.Exception.Message)"
}
