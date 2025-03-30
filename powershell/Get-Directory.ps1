param (
    [Alias("l")]
    [int]$Level = 1,

    [Alias("f")]
    [string[]]$Files = @(),

    [Alias("ext")]
    [string[]]$Extensions = @()
)

$OutputBuilder = New-Object System.Text.StringBuilder

function Show-FileContent {
    param($FilePath)

    if (-not (Test-Path $FilePath -PathType Leaf)) {
        return
    }

    $name = Split-Path $FilePath -Leaf
    $header = "===== Fichier: $name ====="

    Write-Host $header -ForegroundColor Cyan
    $OutputBuilder.AppendLine($header) | Out-Null

    Get-Content $FilePath -Encoding UTF8 | ForEach-Object {
        Write-Output $_
        $OutputBuilder.AppendLine($_) | Out-Null
    }

    Write-Output ""
    $OutputBuilder.AppendLine("") | Out-Null
}

# --- Si -f fichiers directs
if ($Files.Count -gt 0) {
    foreach ($file in $Files) {
        Show-FileContent -FilePath $file
    }
}
else {
    # Par défaut → toutes extensions
    if (-not $Extensions -or $Extensions.Count -eq 0) {
        $Extensions = @("*")
    } else {
        $Extensions = $Extensions | ForEach-Object { $_.ToLower().TrimStart('.') }
    }

    function Get-FilesRecursively {
        param (
            [string]$Path,
            [int]$CurrentLevel,
            [int]$MaxLevel
        )

        if ($CurrentLevel -gt $MaxLevel) {
            return
        }

        Get-ChildItem -Path $Path -File | Where-Object {
            $Extensions -contains "*" -or $Extensions -contains $_.Extension.TrimStart('.').ToLower()
        } | ForEach-Object {
            Show-FileContent -FilePath $_.FullName
        }

        if ($CurrentLevel -lt $MaxLevel) {
            Get-ChildItem -Path $Path -Directory | ForEach-Object {
                Get-FilesRecursively -Path $_.FullName -CurrentLevel ($CurrentLevel + 1) -MaxLevel $MaxLevel
            }
        }
    }

    Get-FilesRecursively -Path "." -CurrentLevel 1 -MaxLevel $Level
}

# --- Copier si contenu non vide
if ($OutputBuilder.Length -gt 0) {
    $OutputBuilder.ToString() | Set-Clipboard
    Write-Host "Output copied to clipboard!" -ForegroundColor Green
} else {
    Write-Host "No files found or nothing to display." -ForegroundColor Yellow
}
