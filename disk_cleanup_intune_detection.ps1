#percentage of C drive, if total size is less than 10% it will execute disk_cleanup_intune.ps1
$threshold = 10

$drive = Get-PSDrive -Name C
$freeSpaceGB = $drive.Free / 1GB
$totalSpaceGB = $drive.Used / 1GB + $freeSpaceGB
$freeSpacePercentage = ($freeSpaceGB / $totalSpaceGB) * 100

if ($freeSpacePercentage -lt $threshold) {
    Write-Output "Free space is below $threshold%. Exiting with code 1."
    exit 1
} else {
    Write-Output "Free space is above $threshold%. Exiting with code 0."
    exit 0
}
