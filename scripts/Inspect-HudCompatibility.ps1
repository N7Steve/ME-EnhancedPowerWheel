param(
    [string]$HudModRoot = 'D:\Modding\M3Tweaks Mod Manager\LE3\HUD Enhancements',
    [string]$MeleRoot = $env:MELE_ROOT,
    [string]$DotnetRuntimeExe = $(if ($env:DOTNET_RUNTIME_EXE) { $env:DOTNET_RUNTIME_EXE } else { 'dotnet' })
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
if (!$MeleRoot) { throw 'Set MELE_ROOT or pass -MeleRoot.' }
$helper = Join-Path $repo 'tools/PackageResearch/bin/WinRelease/net8.0/PackageResearch.dll'
$hudPackage = Join-Path $HudModRoot 'DLC_MOD_HUDEnhance/CookedPCConsole/Startup_MOD_HUDEnhance_INT.pcc'
$hudConfig = Join-Path $HudModRoot 'DLC_MOD_HUDEnhance/CookedPCConsole/Default_DLC_MOD_HUDEnhance.bin'
$gamePackage = Join-Path $MeleRoot 'Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc'
foreach ($file in @($helper, $hudPackage, $hudConfig, $gamePackage)) {
    if (!(Test-Path -LiteralPath $file -PathType Leaf)) { throw "Missing $file" }
}
$output = Join-Path $repo 'research/local/LE3/HUDCompatibility'
New-Item -ItemType Directory -Force -Path $output | Out-Null
$before = @($hudPackage, $hudConfig, $gamePackage) | Get-FileHash -Algorithm SHA256
$before | Select-Object Path, Hash | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $output 'input-hashes.json')

function Invoke-Research([string[]]$ResearchArguments) {
    & $DotnetRuntimeExe $helper @ResearchArguments
    if ($LASTEXITCODE -ne 0) { throw "Research operation failed: $($ResearchArguments[0])" }
}

# M3M v1 starts with M3MM, a version byte, and an Unreal UTF-16 string.
foreach ($merge in @('HudEnhancements', 'dpadTextAlign')) {
    $bytes = [IO.File]::ReadAllBytes((Join-Path $HudModRoot "MergeMods/$merge.m3m"))
    if ($bytes.Length -lt 9 -or [Text.Encoding]::ASCII.GetString($bytes, 0, 4) -ne 'M3MM' -or $bytes[4] -ne 1) {
        throw "Unsupported M3M format: $merge"
    }
    $count = -[BitConverter]::ToInt32($bytes, 5)
    if ($count -le 0 -or 9L + 2L * $count -gt $bytes.Length) { throw "Invalid manifest length: $merge" }
    $manifestText = [Text.Encoding]::Unicode.GetString($bytes, 9, ($count - 1) * 2)
    $null = $manifestText | ConvertFrom-Json
    [IO.File]::WriteAllText((Join-Path $output "$merge.json"), $manifestText)
}
Invoke-Research @('configdump', $hudConfig, (Join-Path $output 'Config'))
Invoke-Research @('classinfo', $hudPackage, (Join-Path $output 'hud-classes.json'), '^HUDEnhanced\.')
Invoke-Research @('classinfo', $gamePackage, (Join-Path $output 'installed-classes.json'), '^SFXSFHandler_(PC)?PowerWheel$')
Invoke-Research @($hudPackage, (Join-Path $output 'Startup'), '^HUDEnhanced\.')
Invoke-Research @($gamePackage, (Join-Path $output 'Installed'), '^SFXSFHandler_PowerWheel\.(Update|HandleInputEvent|WheelVisibilityChanged)$')

# Validation-only manifest: M3's documented merge targets exclude this DLC file.
# The compiler changes an in-memory package and never saves it.
$bridge = Join-Path $output 'Bridge'
New-Item -ItemType Directory -Force -Path $bridge | Out-Null
[IO.File]::WriteAllText((Join-Path $bridge 'Console.Update.uc'), "public event function Update(float fDeltaT)`n{`n    Super.Update(fDeltaT);`n}`n")
$manifest = @{
    game = 'LE3'
    files = @(@{
        filename = 'Startup_MOD_HUDEnhance_INT.pcc'
        changes = @(@{
            entryname = 'HUDEnhanced.SFXModHandler_HybridPowerWheel_Console'
            addtoclassorreplace = @{ scriptfilenames = @('Console.Update.uc') }
        })
    })
}
$manifestPath = Join-Path $bridge 'Bridge.json'
[IO.File]::WriteAllText($manifestPath, ($manifest | ConvertTo-Json -Depth 8))
Invoke-Research @('validate', $hudPackage, $manifestPath, (Join-Path $bridge 'Validation'))
foreach ($original in $before) {
    if ((Get-FileHash -LiteralPath $original.Path -Algorithm SHA256).Hash -ne $original.Hash) {
        throw "Input changed during inspection: $($original.Path)"
    }
}
Write-Output "Research and in-memory bridge validation completed in $output. Input hashes are unchanged; nothing was installed."
