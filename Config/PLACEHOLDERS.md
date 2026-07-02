# Paramètres à configurer avant utilisation

## Config\Settings.ps1  ← fichier central à éditer

| Placeholder | Description |
|---|---|
| `$Environment` | `"Test"` ou `"Production"` — bascule entre les deux tenants |
| `PLACEHOLDER_APP_ID_TEST` | AppId de l'App Registration du tenant de test |
| `PLACEHOLDER_TENANT_ID_TEST` | TenantId du tenant de test |
| `PLACEHOLDER_CERT_THUMBPRINT_TEST` | Thumbprint du certificat pour le tenant de test |
| `PLACEHOLDER_APP_ID_PROD` | AppId de l'App Registration du tenant de production |
| `PLACEHOLDER_TENANT_ID_PROD` | TenantId du tenant de production |
| `PLACEHOLDER_CERT_THUMBPRINT_PROD` | Thumbprint du certificat pour le tenant de production |
| `PLACEHOLDER_SMTP_SERVER` | Serveur SMTP (ex: smtp.office365.com) |
| `PLACEHOLDER_SMTP_USER` | Compte utilisé pour l'authentification SMTP |
| `PLACEHOLDER_SMTP_PASSWORD` | Mot de passe du compte SMTP |
| `PLACEHOLDER_MAIL_FROM` | Adresse expéditeur |
| `PLACEHOLDER_MAIL_TO` | Adresse(s) destinataire(s) — modifier le tableau si plusieurs |

> Les certificats doivent être déclarés dans chaque App Registration Azure AD (section **Certificates & secrets**).
> Pour trouver un Thumbprint : `Get-ChildItem Cert:\LocalMachine\My` ou `Cert:\CurrentUser\My`

## Config\Teams.Desired.ps1

Remplacer les valeurs par ta configuration cible réelle.
Il est conseillé de faire un premier export avec 01-Export.ps1,
puis de copier les valeurs souhaitées dans ce fichier comme baseline.

## Fichiers générés par environnement

| Fichier | Environnement |
|---|---|
| `Data\Snapshots\snapshot_Test_*.json` | Tenant de test |
| `Data\Snapshots\snapshot_Production_*.json` | Tenant de production |
| `Data\history_Test.json` | Historique tenant de test |
| `Data\history_Production.json` | Historique tenant de production |
| `Reports\rapport_Test.html` | Rapport tenant de test |
| `Reports\rapport_Production.html` | Rapport tenant de production |

## Planificateur de tâches Windows

Commande à planifier (une tâche par environnement si souhaité) :
```
powershell.exe -NonInteractive -ExecutionPolicy Bypass -File "C:\CHEMIN\DSC\Run-All.ps1"
```
Changer `$Environment` dans `Settings.ps1` avant d'exécuter, ou créer deux tâches pointant sur deux copies du projet.
