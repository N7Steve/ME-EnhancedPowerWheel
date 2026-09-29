# Toolchain research

## Confirmed local baseline

- The repository started empty on `main`, with `origin` set to the public GitHub repository.
- LE3 `SFXGame.pcc` exists in the installed game's `Game/ME3/BioGame/CookedPCConsole` directory. Research must not modify it.
- Git, .NET, PowerShell, and Python are available. `gh`, `7z`, and `ffdec` are not on `PATH`.

## Verified local workflow

`tools/toolchain.lock.json` pins LegendaryExplorerCore source commit `43bf73a0c5920a1b27ddcf2a7b35a53336274086`, .NET build SDK 10.0.401, and ME3Tweaks Mod Manager 9.2.1.137. The .NET 8 host runs the helper. The Core source checkout and Mod Manager were verified locally; neither is committed. The helper uses Core APIs to open packages, build a `FileLib`, decompile selected exports, and compile replacement functions in memory. It never saves a PCC.

```powershell
Copy-Item local.settings.example.ps1 local.settings.ps1
# Set the five verified paths in the ignored copy, then:
. ./local.settings.ps1
./scripts/Build-ResearchTool.ps1
./scripts/Inspect-Le3.ps1
./scripts/Build-Le3.ps1
./scripts/Export-Le3Folder.ps1
```

`Inspect-Le3.ps1` writes bulk decompiled source and package metadata to ignored `research/local/`. `Build-Le3.ps1` validates four authored function replacements and the `Update` class addition against the installed `SFXGame.pcc`, checks that only explicitly changed class export data changes, and asks Mod Manager to serialize the M3M. The owner-confirmed ordering checkpoint is version 0.7, with M3M v1 SHA256 `43BE9E7783774FDD70D812712882A5D2291AB3422B4BD287C3F17B185C722991`. Build and serialization establish syntax and format; the owner separately confirmed the wheel behavior in game.

The installed target's SHA256 at initial inspection was `D9322946E03355D12C4934A3CC67A6AE47E74E644856E9D4B22F7F0EAF4`. It contained Dynamic Time Wheels code and class additions, so it was not a pristine LE3 baseline. The current ordering POC replaces four existing functions and adds an `Update` override to the wheel class. It introduces no class fields or native hooks. The build workflow does not deploy to the game; the owner installed and tested the exported mod separately.

For deployment, Mod Manager merges into the LE3 basegame `SFXGame.pcc`. Before doing so, identify its managed backup and all existing installed mods, record the target hash, and verify Mod Manager's restoration path. Uninstall/revert by restoring the manager's basegame backup and reapplying desired mods. Do not copy a PCC from an unrelated version or overwrite the game directly. This repository's build and export commands do not deploy; the owner installed the exported checkpoint for the reported gameplay test.

`Export-Le3Folder.ps1` writes only `moddesc.ini` and `MergeMods/EnhancedPowerWheel.m3m` to an ignored import folder named with the merge hash. It refuses to overwrite an existing export and compares the exported merge hash to the build.

## Sources

- [LegendaryExplorerCore](https://github.com/ME3Tweaks/LegendaryExplorer) package and UnrealScript APIs.
- [ME3Tweaks Merge Mod format](https://github.com/ME3Tweaks/ME3TweaksModManager/blob/staticfiles/documentation/merge_mods.md).
- [Mod Manager command-line compiler announcement](https://github.com/ME3Tweaks/ME3TweaksModManager/issues/413).
