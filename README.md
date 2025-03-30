# 🧰 CLI-Toolbox

**CLI-Toolbox** est ma collection personnelle de **scripts et utilitaires en ligne de commande**.

Ce dépôt rassemble des scripts que j’ai :
– écrits moi-même au gré de mes besoins,
– adaptés ou améliorés,
– ou simplement collectés pour leur utilité.

L’objectif est d’avoir une **boîte à outils simple, rapide à utiliser**, multiplateforme (Linux & Windows), évolutive et documentée.

---

## 📁 Structure

```
CLI-Toolbox/
├── README.md
├── bash/
│   └── *.sh
├── powershell/
│   └── *.ps1
```

---

## 🧩 Contenu du dépôt

### 🐧 Bash (`bash/`)

- [`install_docker.sh`](./bash/install_docker.sh)  
  Script d’installation automatisée de Docker sur un serveur Ubuntu.  
  Basé sur la documentation officielle Docker.

- [`system-report.sh`](./bash/system-report.sh)  
  Génére un rapport système dans `/var/log/system_reports`, contenant l’usage disque, mémoire, et l’uptime.

---

### 🪟 PowerShell (`powershell/`)

- [`Check-DotNetVersion.ps1`](./powershell/Check-DotNetVersion.ps1)  
  Script issu de la documentation officielle Microsoft pour vérifier la version de .NET installée.  
  Utilisé initialement pour diagnostiquer un souci d’installation avec **IAshell**, qui nécessite .NET Framework.

- [`Get-Softwares.ps1`](./powershell/Get-Softwares.ps1)  
  Liste tous les logiciels installés, y compris ceux **non enregistrés dans le panneau de configuration** (ex: exécutables sans installeur).

- [`Check-Ports.ps1`](./powershell/Check-Ports.ps1)  
  Affiche les ports réseau actifs et les processus associés à chaque port (PID et nom).

  

