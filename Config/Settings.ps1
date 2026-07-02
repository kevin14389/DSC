# =============================================================================
# Settings.ps1 — Configuration des tenants et paramètres globaux
# =============================================================================
# Modifie $Environment pour basculer entre les tenants.
# =============================================================================

$Environment = "Test"   # "Test" ou "Production"

# --- Configuration des tenants -----------------------------------------------

$TenantConfig = @{

    Test = @{
        AppId       = "PLACEHOLDER_APP_ID_TEST"          # <-- AppId du tenant de test
        TenantId    = "PLACEHOLDER_TENANT_ID_TEST"       # <-- TenantId du tenant de test
        Thumbprint  = "PLACEHOLDER_CERT_THUMBPRINT_TEST" # <-- Thumbprint cert du tenant de test
    }

    Production = @{
        AppId       = "PLACEHOLDER_APP_ID_PROD"          # <-- AppId du tenant de production
        TenantId    = "PLACEHOLDER_TENANT_ID_PROD"       # <-- TenantId du tenant de production
        Thumbprint  = "PLACEHOLDER_CERT_THUMBPRINT_PROD" # <-- Thumbprint cert du tenant de production
    }
}

# --- Paramètres SMTP ---------------------------------------------------------

$SmtpConfig = @{
    Server   = "PLACEHOLDER_SMTP_SERVER"    # <-- Ex : smtp.office365.com
    Port     = 587
    User     = "PLACEHOLDER_SMTP_USER"
    Password = "PLACEHOLDER_SMTP_PASSWORD"
    From     = "PLACEHOLDER_MAIL_FROM"
    To       = @("PLACEHOLDER_MAIL_TO")     # <-- Tableau, ajouter des adresses si besoin
}

# --- Résolution de la config active ------------------------------------------

if (-not $TenantConfig.ContainsKey($Environment)) {
    Write-Error "[Settings] Environnement inconnu : '$Environment'. Valeurs acceptées : $($TenantConfig.Keys -join ', ')"
    exit 1
}

$ActiveConfig = $TenantConfig[$Environment]

Write-Host "[Settings] Environnement actif : $Environment (TenantId: $($ActiveConfig.TenantId))" -ForegroundColor Magenta
