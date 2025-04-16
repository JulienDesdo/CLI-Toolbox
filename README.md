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
├── python/
│   └── *.py
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

- [`Get-Directory.ps1`](./powershell/Get-Directory.ps1)
  Affiche le contenu d’un ou plusieurs fichiers en format lisible, permet de filtrer par **profondeur**,
  **extension** ou **fichiers spécifiques**. Le résutat de la commande est copié dans le clipboard.
  
  ```
  .\Get-Directory.ps1 [-l <profondeur>] [-ext ext1,ext2,...] [-f @(file1, file2, ...)]
  ```
  
  **Exemples :**
  
  Afficher tous les fichiers du répertoire courant :
  ```
  .\Get-Directory.ps1
  ```
  Afficher les fichiers .ps1 et .txt jusqu’à 2 niveaux :
  ```
  .\Get-Directory.ps1 -ext ps1,txt -l 2
  ```
  Afficher deux fichiers précis (y compris avec espaces) :
  ```
  .\Get-Directory.ps1 -f @("README.md", "I WSL NAND WINDOWS.txt")
  ```
  Affichage (rendu terminal) : 
  ```
  ===== Fichier: fichier1.extension1 =====
  Contenu
  ===== Fichier: fichier2.extension2 =====
  Contenu
  ...
  Output copied to clipboard!
  ```
  
  🔤 Encodage vérifié : UTF-8

---

### 🐍 Python (`python/`)

- [`random-pypi.py`](./python/random-pypi.py)
  Tire un paquet aléatoire depuis le registre PyPI. Idéal pour découvrir des bibliothèques insolites, explorer l’écosystème Python ou juste rigoler un coup.
  
  Exemple d’utilisation :
  ```
  > python random-pypi.py  
  🎲 Paquet aléatoire : automate3chapter3
  🔗 https://pypi.org/project/automate3chapter3/
  📖 Description : This is a placeholder package that installs nothing, but prevents typo squatting.
  ```

- [`AV-Check.py`](./python/AV-Check.py)
  Liste les processus système en cours et les compare contre une liste d'exécutables d'antivirus connus. Permet de savoir si un AV est actif ou non.

  Dépendance :
  ```
  pip install psutil
  ```

  Exemple d’utilisation :
  ```
  > python AV-Check.py  
  [+] Antivirus check is running ..

  -- AV Found: MsMpEng.exe
  ```
---


