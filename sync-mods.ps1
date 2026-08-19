<#
Sincroniza os mods (.jar) da pasta de perfil do Modrinth para a pasta mods/ deste repo.
Uso:
    .\sync-mods.ps1
#>

$ErrorActionPreference = "Stop"

$Source = "C:\Users\joaoc\AppData\Roaming\ModrinthApp\profiles\modpack cobblemon server\mods"
$Dest   = Join-Path $PSScriptRoot "mods"

if (-not (Test-Path -LiteralPath $Source)) {
    throw "Pasta de origem nao encontrada: $Source"
}
if (-not (Test-Path -LiteralPath $Dest)) {
    New-Item -ItemType Directory -Path $Dest | Out-Null
}

$sourceJars = Get-ChildItem -LiteralPath $Source -Filter *.jar -File
$destJars   = Get-ChildItem -LiteralPath $Dest -Filter *.jar -File

$sourceNames = $sourceJars.Name
$destNames   = $destJars.Name

$added   = @()
$updated = @()
$removed = @()

foreach ($jar in $sourceJars) {
    $destPath = Join-Path $Dest $jar.Name
    if (-not (Test-Path -LiteralPath $destPath)) {
        Copy-Item -LiteralPath $jar.FullName -Destination $destPath
        $added += $jar.Name
    }
    else {
        $destItem = Get-Item -LiteralPath $destPath
        if ($jar.Length -ne $destItem.Length -or $jar.LastWriteTimeUtc -ne $destItem.LastWriteTimeUtc) {
            Copy-Item -LiteralPath $jar.FullName -Destination $destPath -Force
            $updated += $jar.Name
        }
    }
}

foreach ($name in $destNames) {
    if ($sourceNames -notcontains $name) {
        Remove-Item -LiteralPath (Join-Path $Dest $name) -Force
        $removed += $name
    }
}

Write-Host ""
Write-Host "Sincronizacao concluida: $($added.Count) adicionados, $($updated.Count) atualizados, $($removed.Count) removidos." -ForegroundColor Cyan

if ($added.Count)   { Write-Host "`nAdicionados:";  $added   | ForEach-Object { Write-Host "  + $_" -ForegroundColor Green } }
if ($updated.Count) { Write-Host "`nAtualizados:";  $updated | ForEach-Object { Write-Host "  ~ $_" -ForegroundColor Yellow } }
if ($removed.Count) { Write-Host "`nRemovidos:";    $removed | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red } }

if (-not $added.Count -and -not $updated.Count -and -not $removed.Count) {
    Write-Host "Nada mudou, mods ja estao sincronizados." -ForegroundColor DarkGray
}
else {
    Write-Host "`nPara subir para o servidor:" -ForegroundColor Cyan
    Write-Host "  git add mods"
    Write-Host "  git commit -m `"Sync mods`""
    Write-Host "  git push"
}
