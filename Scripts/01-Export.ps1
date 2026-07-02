# =============================================================================
# 01-Export.ps1 — Export de la configuration Teams actuelle du tenant
# =============================================================================

param(
    [string]$SnapshotDir = "$PSScriptRoot\..\Data\Snapshots"
)

$ErrorActionPreference = "Stop"

# --- Chargement de la configuration -------------------------------------------
. "$PSScriptRoot\..\Config\Settings.ps1"

# --- Connexion au tenant -------------------------------------------------------
Write-Host "[Export] Connexion au tenant $Environment..." -ForegroundColor Cyan

# Chargement du certificat depuis le magasin Windows
$Certificate = Get-ChildItem -Path "Cert:\CurrentUser\My\$($ActiveConfig.Thumbprint)" -ErrorAction SilentlyContinue
if (-not $Certificate) {
    $Certificate = Get-ChildItem -Path "Cert:\LocalMachine\My\$($ActiveConfig.Thumbprint)" -ErrorAction SilentlyContinue
}
if (-not $Certificate) {
    Write-Error "[Export] Certificat introuvable (thumbprint : $($ActiveConfig.Thumbprint)). Vérifier Cert:\CurrentUser\My ou Cert:\LocalMachine\My."
    exit 1
}

# Méthode alternative : secret (décommenter si nécessaire)
# $SecureSecret = ConvertTo-SecureString $ActiveConfig.AppSecret -AsPlainText -Force
# $Credential   = New-Object System.Management.Automation.PSCredential($ActiveConfig.AppId, $SecureSecret)

try {
    Connect-MicrosoftTeams -TenantId $ActiveConfig.TenantId -ApplicationId $ActiveConfig.AppId -Certificate $Certificate
    # Alternative secret : Connect-MicrosoftTeams -TenantId $ActiveConfig.TenantId -Credential $Credential
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
    Environment              = $Environment
    TeamsClientConfiguration = (Get-CsTeamsClientConfiguration   -Identity Global | Select-Object * | ConvertTo-Json -Depth 5 | ConvertFrom-Json)
    TeamsMeetingPolicy       = (Get-CsTeamsMeetingPolicy          -Identity Global | Select-Object * | ConvertTo-Json -Depth 5 | ConvertFrom-Json)
    TeamsMessagingPolicy     = (Get-CsTeamsMessagingPolicy         -Identity Global | Select-Object * | ConvertTo-Json -Depth 5 | ConvertFrom-Json)
    TeamsCallingPolicy       = (Get-CsTeamsCallingPolicy           -Identity Global | Select-Object * | ConvertTo-Json -Depth 5 | ConvertFrom-Json)
    TeamsChannelsPolicy      = (Get-CsTeamsChannelsPolicy          -Identity Global | Select-Object * | ConvertTo-Json -Depth 5 | ConvertFrom-Json)
    TeamsFeedbackPolicy      = (Get-CsTeamsFeedbackPolicy          -Identity Global | Select-Object * | ConvertTo-Json -Depth 5 | ConvertFrom-Json)
}

# --- Sauvegarde du snapshot ---------------------------------------------------
if (-not (Test-Path $SnapshotDir)) {
    New-Item -ItemType Directory -Path $SnapshotDir -Force | Out-Null
}

$timestamp    = Get-Date -Format "yyyyMMdd_HHmmss"
$snapshotFile = Join-Path $SnapshotDir "snapshot_${Environment}_$timestamp.json"

$snapshot | ConvertTo-Json -Depth 10 | Set-Content -Path $snapshotFile -Encoding UTF8

Write-Host "[Export] Snapshot sauvegardé : $snapshotFile" -ForegroundColor Green

Disconnect-MicrosoftTeams | Out-Null

return $snapshotFile
