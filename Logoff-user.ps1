#Log off user remotely

function Logoff-user ($Name, $Server) {

$users = quser /server:$Server | select -Skip 1

if ($Name){
    $user = $users | ? {$_ -match $Name}
    } else {
        $user = $users | Out-Menu
    }
    $id =($user.split() | ? {$_})[2]
    if ($id -match 'disc'){
        $id =($user.split() | ? {$_})[1]
        }
        logoff $id /server:$server
 }