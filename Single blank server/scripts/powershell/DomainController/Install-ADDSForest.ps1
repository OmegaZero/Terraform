param
(
    [string]$domainName = "example.local",
    [string]$domainNetbiosName = "EXAMPLE",
    [string]$safeModePass = "Admin123#"
)

Install-ADDSForest `
-DomainMode "7" `
-DomainName "$domainName" `
-DomainNetbiosName "$domainNetbiosName" `
-ForestMode "7" `
-InstallDns `
-SafeModeAdministratorPassword (ConvertTo-SecureString "$safeModePass" -AsPlainText -Force) `
-Force