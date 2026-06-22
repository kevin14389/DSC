# =============================================================================
# 01-Export.ps1 — Export de la configuration Teams actuelle du tenant
# =============================================================================

param(
    [string]$SnapshotDir = "$PSScriptRoot\..\Data\Snapshots"
)

$ErrorActionPreference = "Stop"

# --- Connexion au tenant -------------------------------------------------------
Write-Host "[Export] Connexion au tenant..." -ForegroundColor Cyan

$AppId     = "PLACEHOLDER_APP_ID"          # <-- Ton AppId (GUID)
$AppSecret = "PLACEHOLDER_APP_SECRET"      # <-- Ton secret (ou chemin vers le certificat)
$TenantId  = "PLACEHOLDER_TENANT_ID"       # <-- Ton TenantId (GUID ou domaine)

$SecureSecret = ConvertTo-SecureString $AppSecret -AsPlainText -Force
$Credential   = New-Object System.Management.Automation.PSCredential($AppId, $SecureSecret)

try {
    Connect-MicrosoftTeams -TenantId $TenantId -Credential $Credential
}
catch {
    Write-Error "[Export] Echec de connexion : $_"
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
