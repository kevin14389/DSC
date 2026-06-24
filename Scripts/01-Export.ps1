# =============================================================================
# 01-Export.ps1 — Export de la configuration Teams actuelle du tenant
# =============================================================================

param(
    [string]$SnapshotDir = "$PSScriptRoot\..\Data\Snapshots"
)

$ErrorActionPreference = "Stop"

# --- Connexion au tenant -------------------------------------------------------
Write-Host "[Export] Connexion au tenant..." -ForegroundColor Cyan

# Méthode recommandée : certificat (plus sécurisé, pas d'expiration de secret)
$AppId       = "PLACEHOLDER_APP_ID"          # <-- Ton AppId (GUID de l'App Registration)
$TenantId    = "PLACEHOLDER_TENANT_ID"       # <-- Ton TenantId (GUID ou domaine)
$Thumbprint  = "PLACEHOLDER_CERT_THUMBPRINT" # <-- Thumbprint du certificat (40 caractères hex)

# Méthode alternative : secret (décommenter et commenter le bloc certificat si nécessaire)
# $AppSecret    = "PLACEHOLDER_APP_SECRET"
# $SecureSecret = ConvertTo-SecureString $AppSecret -AsPlainText -Force
# $Credential   = New-Object System.Management.Automation.PSCredential($AppId, $SecureSecret)

# Chargement explicite du certificat depuis le magasin Windows
# Le module MicrosoftTeams attend un objet X509Certificate2, pas juste le thumbprint
$Certificate = Get-ChildItem -Path "Cert:\CurrentUser\My\$Thumbprint" -ErrorAction SilentlyContinue
if (-not $Certificate) {
    $Certificate = Get-ChildItem -Path "Cert:\LocalMachine\My\$Thumbprint" -ErrorAction SilentlyContinue
}
if (-not $Certificate) {
    Write-Error "[Export] Certificat introuvable (thumbprint : $Thumbprint). Vérifier qu'il est bien importé dans Cert:\CurrentUser\My ou Cert:\LocalMachine\My."
    exit 1
}

try {
    Connect-MicrosoftTeams -TenantId $TenantId -ApplicationId $AppId -Certificate $Certificate
    # Alternative secret : Connect-MicrosoftTeams -TenantId $TenantId -Credential $Credential
}
catch {
    $ex = $_.Exception
    Write-Host "[Export] Echec de connexion : $ex" -ForegroundColor Red
    while ($ex.InnerException) {
        $ex = $ex.InnerException
        Write-Host "  --> Cause : $ex" -ForegroundColor Red
    }
    exit 1
}

# --- Export des politiques ----------------------------------------------------
Write-Host "[Export] Récupération des configurations Teams..." -ForegroundColor Cyan

$snapshot = @{
    ExportDate               = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    TeamsClientConfiguration = (Get-CsTeamsClientConfiguration   -Identity Global | Select-Object * | ConvertTo-Json -Depth 5 | ConvertFrom-Json)
    TeamsMeetingPolicy       = (Get-CsTeamsMeetingPolicy          -Identity Global | Select-Object * | ConvertTo-Json -Depth 5 | ConvertFrom-Json)
    TeamsMessagingPolicy     = (Get-CsTeamsMessagingPolicy         -Identity Global | Select-Object * | ConvertTo-Json -Depth 5 | ConvertFrom-Json)
    TeamsCallingPolicy       = (Get-CsTeamsCallingPolicy           -Identity Global | Select-Object * | ConvertTo-Json -Depth 5 | ConvertFrom-Json)
    TeamsChannelsPolicy      = (Get-CsTeamsChannelsPolicy          -Identity Global | Select-Object * | ConvertTo-Json -Depth 5 | ConvertFrom-Json)
    TeamsFeedbackPolicy      = (Get-CsTeamsFeedbackPolicy          -Identity Global | Select-Object * | ConvertTo-Json -Depth 5 | ConvertFrom-Json)
}

# --- Sauvegarde du snapshot ----------------------------------------------------
if (-not (Test-Path $SnapshotDir)) {
    New-Item -ItemType Directory -Path $SnapshotDir -Force | Out-Null
}

$timestamp    = Get-Date -Format "yyyyMMdd_HHmmss"
$snapshotFile = Join-Path $SnapshotDir "snapshot_$timestamp.json"

$snapshot | ConvertTo-Json -Depth 10 | Set-Content -Path $snapshotFile -Encoding UTF8

Write-Host "[Export] Snapshot sauvegardé : $snapshotFile" -ForegroundColor Green

Disconnect-MicrosoftTeams | Out-Null

return $snapshotFile
