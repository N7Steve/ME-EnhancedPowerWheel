param(
    [string]$MeleRoot = $env:MELE_ROOT,
    [string]$ValidationPackagePath,
    [string]$ModManagerPath = $env:MOD_MANAGER_EXE,
    [string]$DotnetRuntimeExe = $(if ($env:DOTNET_RUNTIME_EXE) { $env:DOTNET_RUNTIME_EXE } else { 'dotnet' }),
    [ValidateRange(1,180)][int]$TimeoutSeconds = 60
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
if (!$MeleRoot) { throw 'Set MELE_ROOT.' }
if (!$ModManagerPath -or !(Test-Path -LiteralPath $ModManagerPath -PathType Leaf)) { throw 'Set MOD_MANAGER_EXE to ME3TweaksModManager.exe.' }
$lock = Get-Content -Raw (Join-Path $repo 'tools/toolchain.lock.json') | ConvertFrom-Json
if ((Get-Item -LiteralPath $ModManagerPath).VersionInfo.FileVersion -ne $lock.modManagerVersion) { throw "Expected Mod Manager $($lock.modManagerVersion)." }
$package = Join-Path $MeleRoot 'Game/ME2/BioGame/CookedPCConsole/SFXGame.pcc'
if (!(Test-Path -LiteralPath $package -PathType Leaf)) { throw "Missing $package" }
$helper = Join-Path $repo 'tools/PackageResearch/bin/WinRelease/net8.0/PackageResearch.dll'
if (!(Test-Path -LiteralPath $helper -PathType Leaf)) { throw 'Run scripts/Build-ResearchTool.ps1 first.' }
$packageHash = (Get-FileHash -LiteralPath $package -Algorithm SHA256).Hash
if (!$ValidationPackagePath) { $ValidationPackagePath = $package }
if (!(Test-Path -LiteralPath $ValidationPackagePath -PathType Leaf)) { throw "Missing validation package: $ValidationPackagePath" }
$source = Join-Path $repo 'src/LE2/MergeMods'
$manifest = Join-Path $source 'EnhancedPowerWheel.json'
& $DotnetRuntimeExe $helper validate $ValidationPackagePath $manifest (Join-Path $repo 'research/local/LE2/Validation')
if ($LASTEXITCODE -ne 0) { throw 'UnrealScript validation failed.' }
$build = Join-Path $repo 'build/LE2'
$merge = Join-Path $build 'MergeMods'
New-Item -ItemType Directory -Force -Path $merge | Out-Null
Copy-Item -LiteralPath (Join-Path $repo 'src/LE2/moddesc.ini') -Destination $build
Get-ChildItem -LiteralPath $source -File | Where-Object Extension -In '.json','.uc' | Copy-Item -Destination $merge
$buildManifest = Join-Path $merge 'EnhancedPowerWheel.json'
$artifact = Join-Path $merge 'EnhancedPowerWheel.m3m'
if (Test-Path -LiteralPath $artifact) { Remove-Item -LiteralPath $artifact }
$started = Get-Date
Start-Process -FilePath $ModManagerPath -ArgumentList @('--compilemergemod', ('"' + $buildManifest + '"'), '--featurelevel', '8.0') -WindowStyle Hidden | Out-Null
while (!(Test-Path -LiteralPath $artifact)) {
    if (((Get-Date) - $started).TotalSeconds -ge $TimeoutSeconds) { throw 'No merge artifact produced. Check Mod Manager logs; the game was not changed.' }
    Start-Sleep -Milliseconds 500
}
. (Join-Path $PSScriptRoot 'Assert-Le2Merge.ps1')
Assert-Le2Merge -Artifact $artifact -SourceManifest $manifest
$bytes = [IO.File]::ReadAllBytes($artifact)
if ($bytes.Length -lt 9 -or [Text.Encoding]::ASCII.GetString($bytes,0,4) -ne 'M3MM' -or $bytes[4] -ne 1) { throw 'Unexpected M3M output.' }
if ((Get-FileHash -LiteralPath $package -Algorithm SHA256).Hash -ne $packageHash) { throw "Installed package changed during build." }
Write-Output "Built $artifact without modifying the game."
Get-FileHash -LiteralPath $artifact -Algorithm SHA256
