# Paramètres à configurer avant utilisation

## Scripts\01-Export.ps1

| Placeholder | Description |
|---|---|
| `PLACEHOLDER_APP_ID` | GUID de ton App Registration Azure AD |
| `PLACEHOLDER_APP_SECRET` | Secret client de l'App Registration |
| `PLACEHOLDER_TENANT_ID` | GUID ou domaine de ton tenant (ex: contoso.onmicrosoft.com) |

## Scripts\03-Notify.ps1

| Placeholder | Description |
|---|---|
| `PLACEHOLDER_SMTP_SERVER` | Serveur SMTP (ex: smtp.office365.com) |
| `PLACEHOLDER_SMTP_USER` | Compte utilisé pour l'authentification SMTP |
| `PLACEHOLDER_SMTP_PASSWORD` | Mot de passe du compte SMTP |
| `PLACEHOLDER_MAIL_FROM` | Adresse expéditeur |
| `PLACEHOLDER_MAIL_TO` | Adresse(s) destinataire(s) — modifier le tableau si plusieurs |

## Config\Teams.Desired.ps1

Remplacer les valeurs par ta configuration cible réelle.
Il est conseillé de faire un premier export avec 01-Export.ps1,
puis de copier les valeurs souhaitées dans ce fichier comme baseline.

## Planificateur de tâches Windows

Commande à planifier :
```
powershell.exe -NonInteractive -ExecutionPolicy Bypass -File "C:\CHEMIN\DSC\Run-All.ps1"
```
Remplacer `C:\CHEMIN\DSC\` par le chemin réel du projet sur le serveur.
