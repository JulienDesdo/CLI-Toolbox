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
├── R/
│   └── *.R
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

- [`launch-vhdl.ps1`](./powershell/launch-vhdl.ps1)  
  Script générique pour **compiler, simuler et visualiser un projet VHDL** avec [GHDL](https://ghdl.github.io/ghdl/) et [GTKWave](http://gtkwave.sourceforge.net/).
  ```
  .\launch-vhdl.ps1 -Design <design.vhd> -Testbench <tb_design.vhd> [-StopTime <temps>]
  ```
  Exemples :
  Simulation d’un latch avec 500 ns par défaut :
  ```
  .\launch-vhdl.ps1 -Design d_latch.vhd -Testbench tb_xcomp.vhd
  ```
  Simulation d’un XOR avec une durée de 1 µs :
  ```
  .\launch-vhdl.ps1 -Design xor_gate.vhd -Testbench tb_xor.vhd -StopTime 1us
  ```
  👉 Si un fichier .gtkw portant le même nom que le testbench est présent (ex: tb_xcomp.gtkw), il est utilisé automatiquement pour afficher les signaux dans GTKWave.


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
- [`find-obsolete-packages.py`](./python/find-obsolete-packages.py)
  Vérifie quels paquets Python installés localement n'ont pas été mis à jour depuis un certain nombre d’années.

  Dépendances :
  ```
  pip install tqdm
  ```
  Exemple d’utilisation :
  ```
  python find-obsolete-packages.py
  ```

  ```
  python find-obsolete-packages.py --years 3
  ```

  ```
  python .\find-obsolete-packages.py --years 5
  Analyzing 198 installed packages (threshold: 5 year(s))...
  
  Checking packages: 100%|█████████████████████████████████████████████████████████████| 198/198 [00:49<00:00,  4.02it/s]
  
  --- Results ---
  Found 5 obsolete package(s) (not updated in 5+ years):
  
  - webencodings (last updated 8 years ago)
  - astunparse (last updated 5 years ago)
  - plotly-express (last updated 5 years ago)
  - google-pasta (last updated 5 years ago)
  - rfc3986-validator (last updated 5 years ago)
  ```
  
  **⚠️ Remarque :** Ce script interroge l'API de PyPI pour chaque paquet installé. Sur de très grosses installations, cela peut entraîner un ralentissement ou un blocage temporaire dû aux limites de requêtes (rate limiting).

- [`csv-to-markdown.py`](./python/find-obsolete-packages.py)
  Affiche un fichier CSV sous forme de tableau Markdown dans le terminal.

  Exemple :
  ```
  python csv-to-markdown.py data.csv
  ```
  Dépendance :
  ```
  pip install pandas
  ```
💡 Petite commande toute simple… mais avec plein de pistes d’évolution possibles : support d'autres formats (Excel, TSV), aperçu, export JSON, copie auto, etc. Une bonne base pour une vraie mini-toolbox dédiée aux tableaux.

- [`explore-module.py`](./python/explore_module.py)  
  Explore n’importe quel module Python installé localement pour en extraire les **fonctions, classes et objets publics**.  
  Peut trier les fonctions soit **alphabétiquement** (par défaut), soit par **pertinence estimée** (`--scored`).  
  Très utile pour obtenir un **résumé rapide** d’un module sans aller lire la documentation.

  Exemple d’utilisation :
  ```
  # Exploration simple, tri alphabétique
  python explore-module.py math

  # Exploration avec tri par pertinence heuristique
  python explore-module.py numpy --scored
  ```

- [`path-doctor.py`](./python/path-doctor.py)

  Analyse la variable d'environnement `PATH` et permet de diagnostiquer rapidement les problèmes liés à la résolution des commandes.

  Sans argument, le script :

  * affiche les différents répertoires présents dans le `PATH`,
  * détecte les répertoires inexistants,
  * détecte les entrées dupliquées.

  Exemple d'utilisation :

  ```bash
  python path-doctor.py
  ```

  Il est également possible de rechercher une commande précise afin de voir toutes les occurrences correspondantes présentes dans le `PATH` :

  ```bash
  python path-doctor.py python
  ```

  Exemple de sortie :

  ```text
  +----------------------------------+
  |           PATH DOCTOR            |
  +----------------------------------+

  Command: python

    1. C:\Python312\python.exe <- ACTIVE
       Python 3.12.5

    2. C:\Python311\python.exe
       Python 3.11.9

    3. C:\Users\User\AppData\Local\Microsoft\WindowsApps\python.exe
       unknown
  ```

  L'exécutable marqué `ACTIVE` correspond à celui qui sera réellement lancé lorsque la commande est saisie dans le terminal.

  Plusieurs commandes peuvent être vérifiées en une seule fois :

  ```bash
  python path-doctor.py python java gcc git
  ```

  Pour CUDA, par exemple, il faut rechercher le nom réel de la commande concernée :

  ```bash
  python path-doctor.py nvcc
  ```

  Le script utilise l'ordre réel du `PATH` pour retrouver les différentes occurrences d'une commande et utilise la résolution du système pour identifier celle qui est effectivement active.

  Aucune dépendance externe n'est nécessaire.

  
---

### ®️ R (`R/`)

- [`dsa.R`](./R/dsa.R)
  Analyse un fichier CSV et affiche un résumé du dataset (dimensions, colonnes, types, valeurs manquantes, stats générales).

  Exemple :
  ```
  Rscript dsa.R data.csv
  Rscript dsa.R data.csv --deep
  ```
  💡 En mode --deep, le script identifie aussi :
    - les colonnes constantes ou uniques,
    - les top valeurs des colonnes textuelles,
    - les valeurs aberrantes (z-score > 3),
    - les corrélations entre variables numériques.

  📍 Pense à ajouter Rscript.exe au PATH si R est installé dans Program Files\R\R-x.x.x\bin

