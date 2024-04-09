#not very useful, just window with ping information

function BetterPing {
    param (
        [string]$Device
    )
    Add-Type -AssemblyName System.Windows.Forms
    $form = New-Object Windows.Forms.Form
    $form.Text = "Device Status"
    $form.Size = New-Object Drawing.Size(300, 100)
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $label = New-Object Windows.Forms.Label
    $label.Text = "Loading..."
    $label.Location = New-Object Drawing.Point(10, 10)
    $label.AutoSize = $true
    $form.Controls.Add($label)
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 5000
    $timer.Add_Tick({
        try {
            $pingResult = Test-Connection -ComputerName $Device -Count 1 -ErrorAction Stop
            if ($pingResult.StatusCode -eq 0) {
                $label.Text = "Online"
                $label.ForeColor = [System.Drawing.Color]::Green
            } else {
                $label.Text = "Offline"
                $label.ForeColor = [System.Drawing.Color]::Red
            }
        } catch {
            $label.Text = "Offline"
            $label.ForeColor = [System.Drawing.Color]::Red
        }
    }) 
    $timer.Start()

    $form.ShowDialog()
}