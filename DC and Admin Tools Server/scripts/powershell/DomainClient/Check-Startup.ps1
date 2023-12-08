while ($true) {
    Write-Host "Checking that server has finished booting..."
    $systemStarted = Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\AutoLogonChecked' # This reg key only appears when the login screen appears
    if ($systemStarted -ne $true){
        Write-Host "System is still booting, waiting 30 seconds...."
        Start-Sleep -Seconds 30
    } else {            
        Write-Host "System has finished booting, continuing..."
        break
    }    
}
