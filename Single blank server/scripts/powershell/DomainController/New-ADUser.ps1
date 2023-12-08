param
(
    [string]$domainName,
    [string]$user,
    [string]$password,
    [string]$server
)

Write-Host "Adding User..."
$pass = ConvertTo-SecureString $Password -AsPlainText -Force
$domain = (Get-WmiObject win32_computersystem).Domain

$retry = 0
while ($domain -ne $domainName -and $retry -lt 3){
  Write-Host "Domain is not available yet, waiting 60 seconds..."
  Start-Sleep -Seconds 60
  $domain = (Get-WmiObject win32_computersystem).Domain
  $retry += 1
}

if ($domain -eq $domainName) {
    New-ADUser -Name $user -AccountPassword $pass -Enabled $true -Server $server
    Write-Host "Added user successfully!"
} else {
    Write-Host "Error adding user as domain could not be contacted"
}