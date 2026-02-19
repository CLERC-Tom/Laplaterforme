Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
Import-Module ADDSDeployment
$p = ConvertTo-SecureString "Azerty_2025!" -AsPlainText -Force
Install-ADDSForest -DomainName "laplateforme.io" -SafeModeAdministratorPassword $p -Force:$true