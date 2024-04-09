#Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force

#Define servers
$OldServer = "Oldserver.domain.com"
$NewServer = "Newserver.domain.com"

#Read network printers
$printers = get-WmiObject -Query "select * From Win32_Printer Where Network = 'True'" | Select-Object systemName, shareName, location

#Loop to check printers
foreach ($printer in $printers){
    $printerName = $printers.shareName
    $server = $printers.systemName
    $loc = $printers.location.Substring(0,4)
    $location = [int]$loc

    if ($server -like "\\$oldserver"){         # if ($printerName -like "\\$oldserver\*" -and $loc % 2 -eq 1) if you need based on numbers change on own needs
        $printers.Delete()
        $newPrinterConnection = "\\" + $newserver + "\" + $printerName
        Add-Printer -ConnectionName $newPrinterConnection
}
else{
    write-host "x"
}}