$Logfile = "C:\Windows\Temp\Install-DomainServices.log"
function WriteLog
{
    Param ([string]$LogString)
    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $LogMessage = "$Stamp $LogString"
    Add-content $LogFile -value $LogMessage
}

try {
    Write-Host "Installing AD Domain Services..."
    install-windowsfeature -name 'ad-domain-services' -includemanagementtools -LogPath 'C:\windows\temp\Install-DomainServices-Command.log'
    Write-Host "Successfully installed AD Domain Services!"
}
catch {
    Write-Host "Unable to install ad-domain-services Error: "
    Write-Host $_.Exception.Message

    WriteLog $_Exception.Message 

    throw
}