param(
    [string]$HudModRoot = 'D:\Modding\M3Tweaks Mod Manager\LE3\HUD Enhancements',
    [string]$MeleRoot = $env:MELE_ROOT,
    [string]$Destination,
    [string]$DotnetRuntimeExe = $(if ($env:DOTNET_RUNTIME_EXE) { $env:DOTNET_RUNTIME_EXE } else { 'dotnet' })
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
if (!$MeleRoot) { throw 'Set MELE_ROOT or pass -MeleRoot.' }
if (!$Destination) { $Destination = Join-Path $repo ('build/HUDCompatibility-v0.4-' + (Get-Date -Format 'yyyyMMdd-HHmmss')) }
$destinationPath = [IO.Path]::GetFullPath($Destination)
$source = Join-Path $repo 'src/LE3/HUDCompatibility'
$helper = Join-Path $repo 'tools/PackageResearch/bin/WinRelease/net8.0/PackageResearch.dll'
$package = Join-Path $MeleRoot 'Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc'
if (Test-Path -LiteralPath $destinationPath) { throw "Destination already exists: $destinationPath" }
& $DotnetRuntimeExe $helper buildhudcompat $HudModRoot $package $source $destinationPath
if ($LASTEXITCODE -ne 0) { throw 'Compatibility build failed. Inputs were not saved; inspect the incomplete build folder.' }
Write-Output "Validated compatibility build: $destinationPath. No installation performed."
