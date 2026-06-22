# =============================================================================
# 04-Report.ps1 — Génération du rapport HTML cumulatif
# =============================================================================

param(
    [Parameter(Mandatory)]
    [hashtable]$DiffResult,

    [string]$HistoryFile = "$PSScriptRoot\..\Data\history.json",
    [string]$ReportFile  = "$PSScriptRoot\..\Reports\rapport.html"
)

$ErrorActionPreference = "Stop"

# --- Mise à jour de l'historique ----------------------------------------------
Write-Host "[Report] Mise à jour de l'historique..." -ForegroundColor Cyan

if (Test-Path $HistoryFile) {
    $history = Get-Content $HistoryFile -Raw -Encoding UTF8 | ConvertFrom-Json
    $dscUpdates  = [System.Collections.Generic.List[object]]($history.DscModuleUpdates)
    $driftEvents = [System.Collections.Generic.List[object]]($history.DriftEvents)
} else {
    $dscUpdates  = [System.Collections.Generic.List[object]]::new()
    $driftEvents = [System.Collections.Generic.List[object]]::new()
}

$teamsModule = Get-Module -ListAvailable -Name MicrosoftTeams | Sort-Object Version -Descending | Select-Object -First 1
$currentDscVersion = if ($teamsModule) { $teamsModule.Version.ToString() } else { "Inconnue" }

$lastDscVersion = if ($dscUpdates.Count -gt 0) { $dscUpdates[-1].Version } else { "" }

if ($currentDscVersion -ne $lastDscVersion) {
    $dscUpdates.Add([PSCustomObject]@{
        Date    = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
        Version = $currentDscVersion
    }) | Out-Null
    Write-Host "[Report] Nouvelle version du module détectée : $currentDscVersion" -ForegroundColor Yellow
}

if ($DiffResult.HasDrift) {
    $driftEvents.Add([PSCustomObject]@{
        Date       = $DiffResult.CompareDate
        DriftCount = $DiffResult.DriftCount
        Diffs      = $DiffResult.Diffs
    }) | Out-Null
}

$updatedHistory = @{
    DscModuleUpdates = $dscUpdates
    DriftEvents      = $driftEvents
}

if (-not (Test-Path (Split-Path $HistoryFile))) {
    New-Item -ItemType Directory -Path (Split-Path $HistoryFile) -Force | Out-Null
}
$updatedHistory | ConvertTo-Json -Depth 15 | Set-Content -Path $HistoryFile -Encoding UTF8

# --- Génération du HTML -------------------------------------------------------
Write-Host "[Report] Génération du rapport HTML..." -ForegroundColor Cyan

$dscRows = if ($dscUpdates.Count -gt 0) {
    ($dscUpdates | Sort-Object Date -Descending | ForEach-Object {
        "<tr><td>$($_.Date)</td><td>$($_.Version)</td></tr>"
    }) -join "`n"
} else {
    "<tr><td colspan='2' style='text-align:center; color:#888;'>Aucune mise à jour enregistrée</td></tr>"
}

$driftRows = if ($driftEvents.Count -gt 0) {
    ($driftEvents | Sort-Object Date -Descending | ForEach-Object {
        $event = $_
        $details = ($event.Diffs | ForEach-Object {
            "<li><strong>[$($_.Section)] $($_.Property)</strong> — Souhaité : <span style='color:#27ae60'>$($_.Desired)</span> / Actuel : <span style='color:#e74c3c'>$($_.Current)</span></li>"
        }) -join "`n"
        @"
        <tr>
            <td style='vertical-align:top; padding:8px 10px; border:1px solid #ddd;'>$($event.Date)</td>
            <td style='padding:8px 10px; border:1px solid #ddd; text-align:center;'>$($event.DriftCount)</td>
            <td style='padding:8px 10px; border:1px solid #ddd;'><ul style='margin:0; padding-left:16px;'>$details</ul></td>
        </tr>
"@
    }) -join "`n"
} else {
    "<tr><td colspan='3' style='text-align:center; color:#888;'>Aucune dérive enregistrée</td></tr>"
}

$statusBadge = if ($DiffResult.HasDrift) {
    "<span style='background:#e74c3c; color:white; padding:4px 12px; border-radius:12px; font-weight:bold;'>DERIVE DETECTEE</span>"
} else {
    "<span style='background:#27ae60; color:white; padding:4px 12px; border-radius:12px; font-weight:bold;'>CONFORME</span>"
}

$reportDate  = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
$moduleLabel = if ($teamsModule) { "MicrosoftTeams v$currentDscVersion" } else { "Module introuvable" }

$html = @"
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Rapport Teams DSC</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Segoe UI', Arial, sans-serif; background: #f4f6f9; color: #333; padding: 20px; }
        .container { max-width: 1100px; margin: 0 auto; }
        header { background: #1a3a5c; color: white; padding: 24px 32px; border-radius: 8px 8px 0 0; }
        header h1 { font-size: 22px; font-weight: 600; }
        header p { font-size: 13px; opacity: 0.75; margin-top: 4px; }
        .card { background: white; border-radius: 8px; box-shadow: 0 2px 6px rgba(0,0,0,0.08); margin-top: 20px; overflow: hidden; }
        .card-header { background: #2c3e50; color: white; padding: 12px 20px; font-size: 14px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; }
        .card-body { padding: 20px; }
        table { width: 100%; border-collapse: collapse; font-size: 13px; }
        th { background: #ecf0f1; padding: 10px 12px; text-align: left; font-weight: 600; border-bottom: 2px solid #bdc3c7; }
        td { padding: 9px 12px; border-bottom: 1px solid #ecf0f1; vertical-align: top; }
        tr:last-child td { border-bottom: none; }
        tr:hover td { background: #f9fafb; }
        .status-bar { display: flex; align-items: center; gap: 16px; padding: 16px 20px; background: white; border-radius: 8px; box-shadow: 0 2px 6px rgba(0,0,0,0.08); margin-top: 20px; }
        .status-bar .label { font-size: 13px; color: #888; }
        .status-bar .value { font-size: 14px; font-weight: 600; }
        footer { text-align: center; font-size: 11px; color: #aaa; margin-top: 30px; padding-bottom: 20px; }
    </style>
</head>
<body>
<div class="container">

    <header>
        <h1>Rapport de surveillance — Configuration Teams</h1>
        <p>Généré le $reportDate &nbsp;|&nbsp; Module : $moduleLabel</p>
    </header>

    <div class="status-bar">
        <div>
            <div class="label">Statut du dernier contrôle</div>
            <div class="value">$statusBadge</div>
        </div>
        <div style="margin-left:auto;">
            <div class="label">Dernier contrôle</div>
            <div class="value">$($DiffResult.CompareDate)</div>
        </div>
        <div>
            <div class="label">Dérives détectées</div>
            <div class="value">$($DiffResult.DriftCount)</div>
        </div>
    </div>

    <div class="card">
        <div class="card-header">Historique des mises à jour du module Teams</div>
        <div class="card-body">
            <table>
                <thead>
                    <tr><th>Date de détection</th><th>Version</th></tr>
                </thead>
                <tbody>
                    $dscRows
                </tbody>
            </table>
        </div>
    </div>

    <div class="card">
        <div class="card-header">Historique des dérives de configuration</div>
        <div class="card-body">
            <table>
                <thead>
                    <tr><th style="width:170px;">Date</th><th style="width:80px; text-align:center;">Nb écarts</th><th>Détail</th></tr>
                </thead>
                <tbody>
                    $driftRows
                </tbody>
            </table>
        </div>
    </div>

    <footer>Surveillance automatique Teams DSC — Rapport généré automatiquement</footer>

</div>
</body>
</html>
"@

if (-not (Test-Path (Split-Path $ReportFile))) {
    New-Item -ItemType Directory -Path (Split-Path $ReportFile) -Force | Out-Null
}

$html | Set-Content -Path $ReportFile -Encoding UTF8

Write-Host "[Report] Rapport HTML généré : $ReportFile" -ForegroundColor Green
