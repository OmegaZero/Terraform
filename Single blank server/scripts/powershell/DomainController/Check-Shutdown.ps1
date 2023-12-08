while ($true)
{
    Write-Host "Checking if server has a shutdown in progress..."
    shutdown -r -t 600000 2>$null #Attempt a shutdown, if a shutdown is already in progress it will error
    if ($LastExitCode -eq 1190){
        Write-Host "A shutdown is in progress, waiting 60 seconds..."
        Start-Sleep -Seconds 60
    } else {            
        shutdown -a #Abort
        Write-Host "No shutdown in progress, continuing..."
        break
    }
}  