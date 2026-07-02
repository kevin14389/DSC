# =============================================================================
# 02-Compare.ps1 — Comparaison snapshot actuel vs configuration souhaitée
# =============================================================================

param(
    [Parameter(Mandatory)]
    [string]$SnapshotFile,

    [string]$DesiredConfigFile = "$PSScriptRoot\..\Config\Teams.Desired.ps1",
    [string]$DiffDir           = "$PSScriptRoot\..\Data\Diffs"
)

$ErrorActionPreference = "Stop"

# --- Chargement de la configuration -------------------------------------------
. "$PSScriptRoot\..\Config\Settings.ps1"

# --- Chargement des données ---------------------------------------------------
Write-Host "[Compare] Chargement du snapshot : $SnapshotFile" -ForegroundColor Cyan

$current = Get-Content $SnapshotFile -Raw -Encoding UTF8 | ConvertFrom-Json
$desired = & $DesiredConfigFile

# --- Fonction de comparaison récursive ----------------------------------------
function Compare-Section {
    param(
        [string]$SectionName,
        [hashtable]$Desired,
        [PSCustomObject]$Current
    )

    $diffs = @()

    foreach ($key in $Desired.Keys) {
        $desiredValue = $Desired[$key]
        $currentValue = $Current.$key

        if ($null -eq $currentValue) {
            $diffs += [PSCustomObject]@{
                Section  = $SectionName
                Property = $key
                Desired  = $desiredValue
                Current  = "(propriété absente)"
                Status   = "MANQUANT"
            }
            continue
        }

        $currentStr = if ($currentValue -is [bool]) { $currentValue.ToString().ToLower() } else { "$currentValue" }
        $desiredStr = if ($desiredValue -is [bool]) { $desiredValue.ToString().ToLower() } else { "$desiredValue" }

        if ($currentStr -ne $desiredStr) {
            $diffs += [PSCustomObject]@{
                Section  = $SectionName
                Property = $key
                Desired  = $desiredStr
                Current  = $currentStr
                Status   = "DERIVE"
            }
        }
    }

    return $diffs
}

# --- Comparaison section par section ------------------------------------------
Write-Host "[Compare] Comparaison en cours..." -ForegroundColor Cyan

$allDiffs = @()

foreach ($section in $desired.Keys) {
    $currentSection = $current.$section
    if ($null -eq $currentSection) {
        Write-Warning "[Compare] Section '$section' absente du snapshot, ignorée."
        continue
    }
    $allDiffs += Compare-Section -SectionName $section -Desired $desired[$section] -Current $currentSection
}

# --- Résultat -----------------------------------------------------------------
$hasDrift = $allDiffs.Count -gt 0

if ($hasDrift) {
    Write-Host "[Compare] $($allDiffs.Count) dérive(s) détectée(s)." -ForegroundColor Yellow
} else {
    Write-Host "[Compare] Aucune dérive détectée. Configuration conforme." -ForegroundColor Green
}

# --- Sauvegarde du diff -------------------------------------------------------
if (-not (Test-Path $DiffDir)) {
    New-Item -ItemType Directory -Path $DiffDir -Force | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$diffFile  = Join-Path $DiffDir "diff_$timestamp.json"

$diffResult = @{
    CompareDate  = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    Environment  = $Environment
    SnapshotFile = $SnapshotFile
    HasDrift     = $hasDrift
    DriftCount   = $allDiffs.Count
    Diffs        = $allDiffs
}

$diffResult | ConvertTo-Json -Depth 10 | Set-Content -Path $diffFile -Encoding UTF8

Write-Host "[Compare] Résultat sauvegardé : $diffFile" -ForegroundColor Green

return $diffResult
