# =============================================================================
# Run-All.ps1 — Point d'entrée principal
# Lance l'export, la comparaison, la notification et la génération du rapport.
# A planifier via le Planificateur de tâches Windows.
# =============================================================================

$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Surveillance Teams DSC — Démarrage : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# 1. Export de la configuration actuelle
Write-Host "`n[ETAPE 1/4] Export du tenant..." -ForegroundColor White
$snapshotFile = & "$Root\Scripts\01-Export.ps1"

if (-not $snapshotFile -or -not (Test-Path $snapshotFile)) {
    Write-Error "L'export a échoué ou le fichier snapshot est introuvable."
    exit 1
}

# 2. Comparaison avec la baseline
Write-Host "`n[ETAPE 2/4] Comparaison avec la configuration souhaitée..." -ForegroundColor White
$diffResult = & "$Root\Scripts\02-Compare.ps1" -SnapshotFile $snapshotFile

# 3. Notification par email si dérive
Write-Host "`n[ETAPE 3/4] Notification..." -ForegroundColor White
& "$Root\Scripts\03-Notify.ps1" -DiffResult $diffResult

# 4. Génération du rapport HTML
Write-Host "`n[ETAPE 4/4] Génération du rapport HTML..." -ForegroundColor White
& "$Root\Scripts\04-Report.ps1" -DiffResult $diffResult

Write-Host "`n============================================================" -ForegroundColor Green
Write-Host "  Terminé : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Green
