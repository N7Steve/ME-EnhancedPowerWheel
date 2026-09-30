# Mapping on both pages, version 1.9.8

## Evidence and change

The owner confirmed 1.9.7 restores mapping indicators, then reported that assignment only works on the first page. Source inspection confirmed an explicit `nPage == 0` guard in each X/B/Y assignment case. Those three guards are removed; power-mode and nonempty-slot checks remain.

Assignment still uses LE3's native `MapCurrentPower` with the existing button values (5, 6, 1). The installed-package declaration identifies this as a native function; its internal implementation is not available in the UnrealScript decompilation. No replacement assignment implementation is introduced. `EPWRefreshMappingIcons` already reads actual assignments for all eight displayed player slots without a page condition, after each rebuild and during updates. Page 1 uses the same physical icon slots populated with its real powers.

There are still three global controller assignments, shared across pages. Mapping a power on page 1 replaces the corresponding global assignment, just like page 0. No separate per-page bindings or changes to PC quickslots are included. All earlier local changes are preserved.

## Validation and export

All manifest functions compiled against the installed LE3 package. Virtual inheritance passed with base/PC 110/110 and no missing inherited functions. Helpers remain final/nonvirtual. `git diff --check` passed. Installed `SFXGame.pcc` SHA256 remained `74574736F97C2B06744B33E283C18C023B1B1B392235FF505E7E58E8C9BEFF33` before/after build and export; no installation occurred.

Reproduce with `scripts/Build-Le3.ps1` and `scripts/Export-Le3Folder.ps1`. Export: `dist/EnhancedPowerWheel-LE3-MappingBothPages-v1.9.8-9A888402AC55/`, containing `moddesc.ini` and `MergeMods/EnhancedPowerWheel.m3m`. M3M SHA256: `9A888402AC554AA00E9B89B4152DD763B66CD4C89858B2B3B2BE7D44C270A503`.

Owner installation changes only merge target `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc`. Use Mod Manager's basegame backup and record installed mods before installation. To uninstall, restore that backup and reapply desired mods; see [toolchain research](../research/toolchain.md).

Pending game check: assign powers on page 1 using X/B/Y, verify LB/RB/Y badges immediately and after page switches and close/reopen, confirm old badges clear after reassignment, and activate each assigned power using its actual gameplay button. Save/quit/reload remains a separate check.
