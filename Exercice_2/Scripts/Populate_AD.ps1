Import-Module ActiveDirectory

$csvPath  = "C:\Users\Administrator\Desktop\users.csv"
$domain   = "DC=laplateforme,DC=io"
$password = ConvertTo-SecureString "Azerty_2025!" -AsPlainText -Force

if (-not (Test-Path $csvPath)) {
    Write-Host "CSV introuvable : $csvPath" -ForegroundColor Red
    exit
}

$users = Import-Csv -Path $csvPath -Delimiter ","

foreach ($user in $users) {

    $nom    = ($user.nom.Trim()) -replace "^\d+", ""
    $prenom = $user.prenom.Trim()
    $username = (($prenom.Substring(0,1) + $nom).ToLower()) -replace "[^a-z0-9]", ""

    # Création de l'utilisateur dans l'AD
    if (-not (Get-ADUser -Filter { SamAccountName -eq $username } -ErrorAction SilentlyContinue)) {
        New-ADUser `
            -Name                 "$prenom $nom" `
            -GivenName            $prenom `
            -Surname              $nom `
            -SamAccountName       $username `
            -UserPrincipalName    "$username@laplateforme.io" `
            -AccountPassword      $password `
            -ChangePasswordAtLogon $true `
            -Enabled              $true
        Write-Host "Utilisateur cree : $username" -ForegroundColor Green
    } else {
        Write-Host "Utilisateur existant : $username" -ForegroundColor Yellow
    }

    # Ajout aux groupes correspondant au csv
    $groupes = @(
        $user.groupe1,
        $user.groupe2,
        $user.groupe3,
        $user.groupe4,
        $user.groupe5,
        $user.groupe6
    )

    foreach ($g in $groupes) {
        if ($g -and $g.Trim() -ne "") {
            $g = $g.Trim()

            if (-not (Get-ADGroup -Filter { Name -eq $g } -ErrorAction SilentlyContinue)) {
                New-ADGroup `
                    -Name          $g `
                    -GroupScope    Global `
                    -GroupCategory Security `
                    -Path          "CN=Users,$domain"
                Write-Host "  Groupe cree : $g" -ForegroundColor Cyan
            }

            Add-ADGroupMember -Identity $g -Members $username
            Write-Host "  -> $username ajout groupe $g" -ForegroundColor White
        }
    }
}

Write-Host "`nTermine ! Tous les utilisateurs ont ete crees." -ForegroundColor Green