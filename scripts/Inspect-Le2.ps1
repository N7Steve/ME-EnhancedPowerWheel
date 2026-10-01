param(
    [string]$MeleRoot = $env:MELE_ROOT,
    [string]$DotnetRuntimeExe = $(if ($env:DOTNET_RUNTIME_EXE) { $env:DOTNET_RUNTIME_EXE } else { 'dotnet' })
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
if (!$MeleRoot) { throw 'Set MELE_ROOT to the Legendary Edition installation root.' }
$package = Join-Path $MeleRoot 'Game/ME2/BioGame/CookedPCConsole/SFXGame.pcc'
if (!(Test-Path -LiteralPath $package -PathType Leaf)) { throw "Missing $package" }
$helper = Join-Path $repo 'tools/PackageResearch/bin/WinRelease/net8.0/PackageResearch.dll'
if (!(Test-Path -LiteralPath $helper -PathType Leaf)) { throw 'Run scripts/Build-ResearchTool.ps1 first.' }
$output = Join-Path $repo 'research/local/LE2/SFXGame'
& $DotnetRuntimeExe $helper $package $output '^(SFXSFHandler_(PC)?PowerWheel)(\.|$)'
if ($LASTEXITCODE -ne 0) { throw 'LE2 inspection failed.' }
