#Script to add default printer

Set-ExecutionPolicy RemoteSigned -Force

$server = "servername"
$printer = "printername"

$DefaultPrinter = Get-WmiObject -Query " SELECT * FROM Win32_Printer WHERE Default=$true" | Select-Object systemName, shareName
$printername = $DefaultPrinter.ShareName
$AllPrinters = get-WmiObject -Query "select * From Win32_Printer Where Network = 'True'" | Select-Object systemName, shareName

$Choco = $AllPrinters.shareName
if ($printer -like $printername -or $choco -contains $printer){
    (Get-WmiObject -class win32_printer -Filter "ShareName='printername'").SetDefaultPrinter()
    
    
}
elseif ($printername -notcontains $printer){
    $Connection = "\\" + $server + "\" + $printer
    Add-Printer -ConnectionName $Connection
    (Get-WmiObject -class win32_printer -Filter "ShareName='printername'").SetDefaultPrinter()
}