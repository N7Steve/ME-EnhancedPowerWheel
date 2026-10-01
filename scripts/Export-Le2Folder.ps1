param([string]$Destination)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$build = Join-Path $repo 'build/LE2'
$descriptor = Join-Path $build 'moddesc.ini'
$merge = Join-Path $build 'MergeMods/EnhancedPowerWheel.m3m'
if (!(Test-Path -LiteralPath $descriptor -PathType Leaf) -or !(Test-Path -LiteralPath $merge -PathType Leaf)) {
    throw 'Run scripts/Build-Le2.ps1 first.'
}
$mergeHash = (Get-FileHash -LiteralPath $merge).Hash
if (!$Destination) { $Destination = Join-Path $repo ('dist/EnhancedPowerWheel-LE2-SaveOrdering-v0.4-' + $mergeHash.Substring(0, 12)) }
$destinationPath = [IO.Path]::GetFullPath($Destination)
if (Test-Path -LiteralPath $destinationPath) { throw "Destination already exists: $destinationPath" }
New-Item -ItemType Directory -Path (Join-Path $destinationPath 'MergeMods') -Force | Out-Null
Copy-Item -LiteralPath $descriptor -Destination $destinationPath
Copy-Item -LiteralPath $merge -Destination (Join-Path $destinationPath 'MergeMods')
if ($mergeHash -ne (Get-FileHash -LiteralPath (Join-Path $destinationPath 'MergeMods/EnhancedPowerWheel.m3m')).Hash) {
    throw 'Exported merge hash differs from the build.'
}
Copy-Item -LiteralPath (Join-Path $repo 'src/LE2/INSTALL.txt') -Destination $destinationPath
Write-Output "Exported import folder to $destinationPath. No installation performed."
