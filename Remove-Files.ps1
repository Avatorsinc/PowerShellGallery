#Remove files remotely

function Remove-Files {
    param (
        [string]$Computer,
        [string]$Dir
    )

 
    net use \\$Computer /user:"$($env:USERDOMAIN)\$($env:USERNAME)"

    $remotePath = "\\$Computer\$Dir"
    $directoryContents = Get-ChildItem -Path $remotePath

 

    Write-Host "Contents of directory '$remotePath':"


    for ($i = 0; $i -lt $directoryContents.Count; $i++) {
        Write-Host "$i. $($directoryContents[$i].Name)"
    }
    Write-Host ""

    $selection = Read-Host "Enter the number of the file to delete"

    if ($selection -ge 0 -and $selection -lt $directoryContents.Count) {
        $fileToDelete = $directoryContents[$selection]

        Remove-Item -Path (Join-Path -Path $remotePath -ChildPath $fileToDelete.Name) -Force
        Write-Host "File '$($fileToDelete.Name)' has been deleted."
    } else {
        Write-Host "Invalid selection."
    }

    net use /delete \\$Computer\$shareName
}