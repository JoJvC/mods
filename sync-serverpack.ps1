<#
Sincroniza mods/config/kubejs/tacz/defaultconfigs a partir de um novo
"Server Pack.zip" exportado (CurseForge/similar) para este branch do repo.

Uso:
    .\sync-serverpack.ps1 -ZipPath "C:\Downloads\Cursed Walking - 1.20.1 - v3.4 Server Pack.zip"
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ZipPath
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $ZipPath)) {
    throw "Zip nao encontrado: $ZipPath"
}

$RepoRoot = $PSScriptRoot
$Temp = Join-Path ([System.IO.Path]::GetTempPath()) ("serverpack-" + [guid]::NewGuid())
New-Item -ItemType Directory -Path $Temp | Out-Null

try {
    Expand-Archive -LiteralPath $ZipPath -DestinationPath $Temp

    $inner = Get-ChildItem -LiteralPath $Temp -Directory | Select-Object -First 1
    if (-not $inner) { throw "Estrutura inesperada dentro do zip." }

    $folders = "mods", "config", "kubejs", "tacz", "defaultconfigs"
    foreach ($folder in $folders) {
        $src = Join-Path $inner.FullName $folder
        $dest = Join-Path $RepoRoot $folder
        if (-not (Test-Path -LiteralPath $src)) {
            Write-Host "Aviso: pasta '$folder' nao existe no novo pack, pulando." -ForegroundColor Yellow
            continue
        }
        if (Test-Path -LiteralPath $dest) {
            Remove-Item -LiteralPath $dest -Recurse -Force
        }
        Copy-Item -LiteralPath $src -Destination $dest -Recurse
        Write-Host "Sincronizado: $folder" -ForegroundColor Green
    }
}
finally {
    Remove-Item -LiteralPath $Temp -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "`nPara subir para o servidor:" -ForegroundColor Cyan
Write-Host "  git add mods config kubejs tacz defaultconfigs"
Write-Host "  git commit -m `"Sync server pack`""
Write-Host "  git push"
