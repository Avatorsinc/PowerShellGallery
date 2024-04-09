#Remove local profile from remote PC

Function Remove-LocalProfile
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory=$true,Position=0)]$Computer,
		[parameter(Mandatory=$true,Position=1)]$SamAccountName
	)
	try
	{
		$Sid = Get-ADUser $SamAccountName | select -expand sid | select -expand value
	}
	Catch
	{
		Write-Warning "$SamAccountName not found in AD"
		Break
	}
	if (Test-Connection $computer -Count 1 -Quiet)
	{
		$Profile = Get-WmiObject Win32_UserProfile -ComputerName $Computer | where {$_.SID -eq $Sid}
		if ($Profile)
		{
			Try
			{
				Write-Verbose "Removing $SamAccountName from $Computer"
				$Profile.delete()
			}
			catch
			{
				Write-Warning "The Profile of $SamAccountName is locked. Please restart $Computer and try again."
			}
		}
		else
		{
			Write-Warning "$SamAccountName not found on $Computer"
		}
	}
	else {Write-Warning "$Computer is not online"}
}