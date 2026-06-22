# =============================================================================
# 03-Notify.ps1 — Envoi d'un email si des dérives sont détectées
# =============================================================================

param(
    [Parameter(Mandatory)]
    [hashtable]$DiffResult
)

if (-not $DiffResult.HasDrift) {
    Write-Host "[Notify] Aucune dérive, pas d'email envoyé." -ForegroundColor Green
    return
}

# --- Paramètres SMTP ----------------------------------------------------------
$SmtpServer = "PLACEHOLDER_SMTP_SERVER"       # <-- Ex : smtp.office365.com
$SmtpPort   = 587                              # <-- Port SMTP (587 pour TLS)
$SmtpUser   = "PLACEHOLDER_SMTP_USER"         # <-- Compte expéditeur
$SmtpPass   = "PLACEHOLDER_SMTP_PASSWORD"     # <-- Mot de passe expéditeur
$MailFrom   = "PLACEHOLDER_MAIL_FROM"         # <-- Adresse expéditeur
$MailTo     = @("PLACEHOLDER_MAIL_TO")        # <-- Destinataire(s), tableau

# --- Construction du corps HTML -----------------------------------------------
$driftRows = $DiffResult.Diffs | ForEach-Object {
    $statusColor = if ($_.Status -eq "MANQUANT") { "#e67e22" } else { "#e74c3c" }
    @"
    <tr>
        <td style='padding:6px 10px; border:1px solid #ddd;'>$($_.Section)</td>
        <td style='padding:6px 10px; border:1px solid #ddd;'>$($_.Property)</td>
        <td style='padding:6px 10px; border:1px solid #ddd; color:#27ae60;'>$($_.Desired)</td>
        <td style='padding:6px 10px; border:1px solid #ddd; color:$statusColor;'>$($_.Current)</td>
        <td style='padding:6px 10px; border:1px solid #ddd; font-weight:bold; color:$statusColor;'>$($_.Status)</td>
    </tr>
"@
}

$bodyHtml = @"
<!DOCTYPE html>
<html>
<head><meta charset='UTF-8'></head>
<body style='font-family: Segoe UI, Arial, sans-serif; color: #333;'>

<h2 style='color:#c0392b;'>Dérive de configuration Teams détectée</h2>
<p>Date du contrôle : <strong>$($DiffResult.CompareDate)</strong></p>
<p>Nombre de dérives : <strong>$($DiffResult.DriftCount)</strong></p>

<table style='border-collapse:collapse; width:100%; margin-top:16px;'>
    <thead>
        <tr style='background:#2c3e50; color:white;'>
            <th style='padding:8px 10px; text-align:left;'>Section</th>
            <th style='padding:8px 10px; text-align:left;'>Propriété</th>
            <th style='padding:8px 10px; text-align:left;'>Valeur souhaitée</th>
            <th style='padding:8px 10px; text-align:left;'>Valeur actuelle</th>
            <th style='padding:8px 10px; text-align:left;'>Statut</th>
        </tr>
    </thead>
    <tbody>
        $($driftRows -join "`n")
    </tbody>
</table>

<p style='margin-top:20px; font-size:12px; color:#888;'>
    Ce message est généré automatiquement par le système de surveillance Teams DSC.
</p>

</body>
</html>
"@

# --- Envoi --------------------------------------------------------------------
Write-Host "[Notify] Envoi de l'email de dérive..." -ForegroundColor Cyan

try {
    $SecureSmtpPass = ConvertTo-SecureString $SmtpPass -AsPlainText -Force
    $SmtpCredential = New-Object System.Management.Automation.PSCredential($SmtpUser, $SecureSmtpPass)

    Send-MailMessage `
        -SmtpServer   $SmtpServer `
        -Port         $SmtpPort `
        -UseSsl `
        -Credential   $SmtpCredential `
        -From         $MailFrom `
        -To           $MailTo `
        -Subject      "[ALERTE] Dérive Teams détectée — $($DiffResult.DriftCount) écart(s) le $($DiffResult.CompareDate)" `
        -Body         $bodyHtml `
        -BodyAsHtml `
        -Encoding     UTF8

    Write-Host "[Notify] Email envoyé avec succès." -ForegroundColor Green
}
catch {
    Write-Error "[Notify] Echec d'envoi de l'email : $_"
}
