#get ost file 

function Get-OST {
    param (
        [string]$Computer
    )

 

    $OSTFiles = Get-ChildItem "\\$Computer\C$\Users\*\AppData\Local\Microsoft\Outlook\*.ost" -ErrorAction SilentlyContinue

 

    if ($OSTFiles.Count -eq 0) {
        Write-Host "No OST files found on $Computer."
        return
    }

 

    $OSTFilesList = @()

 

    foreach ($OSTFile in $OSTFiles) {
        $OSTFilesList += [PSCustomObject]@{
            FilePath = $OSTFile.FullName
            FileName = $OSTFile.Name
            FileSize = [math]::Round(($OSTFile.Length / 1MB), 2)
        }
    }

 

    Write-Host "OST files found on $Computer"

 

    $i = 0
    foreach ($OST in $OSTFilesList) {
        Write-Host "$i. $($OST.FileName) - $($OST.FileSize) MB"
        $i++
    }

 

    $selection = Read-Host "Enter the number of the OST file to remove"

 

    if ($selection -ge 0 -and $selection -lt $OSTFilesList.Count) {
        $OSTFileToRemove = $OSTFilesList[$selection]
        Write-Host "Removing $($OSTFileToRemove.FileName)..."
        Remove-Item -Path $OSTFileToRemove.FilePath -Force
        Write-Host "OST file $($OSTFileToRemove.FileName) has been removed."
    } else {
        Write-Host "Invalid selection."
    }
}