param(
    [Parameter(Mandatory)][string]$BuildDirectory,
    [string]$Destination
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$buildPath = [IO.Path]::GetFullPath($BuildDirectory)
$evidence = Get-Content -Raw -LiteralPath (Join-Path $buildPath 'build-evidence.json') | ConvertFrom-Json
$startupEntry = $evidence.files | Where-Object path -Like '*Startup_MOD_EPWHUDCompat_INT.pcc'
if (!$startupEntry) { throw 'Build evidence has no compatibility startup.' }
if (!$Destination) { $Destination = Join-Path $repo ('dist/EPW-HUDEnhancements-Compatibility-v' + $evidence.version + '-' + $startupEntry.sha256.Substring(0, 12)) }
$destinationPath = [IO.Path]::GetFullPath($Destination)
if (Test-Path -LiteralPath $destinationPath) { throw "Destination already exists: $destinationPath" }
foreach ($entry in $evidence.files) {
    $inputPath = [IO.Path]::GetFullPath((Join-Path $buildPath $entry.path))
    $exportPath = [IO.Path]::GetFullPath((Join-Path $destinationPath $entry.path))
    if (!$inputPath.StartsWith($buildPath + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase) -or
        !$exportPath.StartsWith($destinationPath + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { throw 'Invalid relative file in build evidence.' }
    if ((Get-FileHash -LiteralPath $inputPath).Hash -ne $entry.sha256) { throw "Build file changed: $($entry.path)" }
}
New-Item -ItemType Directory -Path $destinationPath | Out-Null
foreach ($entry in $evidence.files) {
    $exportPath = Join-Path $destinationPath $entry.path
    New-Item -ItemType Directory -Force -Path (Split-Path $exportPath -Parent) | Out-Null
    Copy-Item -LiteralPath (Join-Path $buildPath $entry.path) -Destination $exportPath
    if ((Get-FileHash -LiteralPath $exportPath).Hash -ne $entry.sha256) { throw "Export hash mismatch: $($entry.path)" }
}
Copy-Item -LiteralPath (Join-Path $repo 'src/LE3/HUDCompatibility/INSTALL.txt') -Destination $destinationPath
Copy-Item -LiteralPath (Join-Path $buildPath 'build-evidence.json') -Destination $destinationPath
Write-Output "Exported Mod Manager import folder: $destinationPath. No installation performed."
