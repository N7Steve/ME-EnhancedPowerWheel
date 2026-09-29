param(
    [string]$LegendaryExplorerSource = $env:LEC_SOURCE,
    [string]$DotnetBuildExe = $env:DOTNET_BUILD_EXE
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
if (!$LegendaryExplorerSource) { throw 'Set LEC_SOURCE to the LegendaryExplorer source checkout.' }
if (!$DotnetBuildExe) { throw 'Set DOTNET_BUILD_EXE to the .NET 10.0.401 host.' }
$lock = Get-Content -Raw (Join-Path $repo 'tools/toolchain.lock.json') | ConvertFrom-Json
$revision = & git -C $LegendaryExplorerSource rev-parse HEAD
if ($LASTEXITCODE -ne 0 -or $revision -ne $lock.legendaryExplorerCommit) { throw "LEC_SOURCE must be at $($lock.legendaryExplorerCommit)." }
$dirty = & git -C $LegendaryExplorerSource status --porcelain --untracked-files=no
if ($LASTEXITCODE -ne 0 -or $dirty) { throw 'LegendaryExplorer source has tracked changes.' }
$version = & $DotnetBuildExe --version
if ($LASTEXITCODE -ne 0 -or $version -ne $lock.buildSdk) { throw "Expected SDK $($lock.buildSdk)." }
$oldPath = $env:PATH
try {
    $env:PATH = (Split-Path $DotnetBuildExe -Parent) + [IO.Path]::PathSeparator + $oldPath
    & $DotnetBuildExe build (Join-Path $repo 'tools/PackageResearch') -c WinRelease "-p:LegendaryExplorerSource=$LegendaryExplorerSource" -v minimal
    if ($LASTEXITCODE -ne 0) { throw 'Research tool build failed.' }
} finally { $env:PATH = $oldPath }
