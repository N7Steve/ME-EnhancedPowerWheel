# Opening flash correction, version 1.9.9

## Evidence and change

The owner reported old power icons briefly appearing on opening, estimated at one or two frames. Current installed LE3 decompilation confirms `WheelVisibilityChanged` restores power/mapping alpha to 100 and shows the wheel, while the `P` marker requests the personalized page rebuild from the next `Update`. A visible interval between those operations is the source-based explanation; its precise render/native timing is not confirmed.

The opening callback now sets only power icons, mapping icons and mapping backgrounds to alpha 0 in controller power mode. `Update` retains `Super.Update(fDeltaT)` and the existing `P` rebuild, then restores alpha 100 once an initialized layout is present. A transient `EPWOpeningPending` Boolean on the GFx icon survives input consuming the `P` marker before `Update`; close clears it and restores alpha, including close during a page fade. This adds no UnrealScript class fields or virtual helpers. Portraits, overlay, wheel ring, vignette, weapon/PC mode, mapping assignments and saved ordering logic remain unchanged.

Installed `SetupPlayerPowers` and power-icon display methods are native declarations. Their internals cannot establish whether they reset alpha, so compilation alone does not prove the flash is removed. The existing icon-only page fade already uses these same root clips and alpha setters.

## Validation and export

All manifest functions compiled against the installed LE3 package. Virtual inheritance validation passed (base/PC 110/110; no missing inherited functions), with existing helpers final/nonvirtual. `git diff --check` passed. Installed `SFXGame.pcc` SHA256 before/after build/export: `B6D2A3AF6A8B1CFFC6E7CE6B88F2910EEE1ECC015DACC214DC048DD27EE26A61`. No installation occurred; pre-existing local changes were preserved.

Reproduce with `scripts/Build-Le3.ps1` and `scripts/Export-Le3Folder.ps1` using the pinned local toolchain. Export: `dist/EnhancedPowerWheel-LE3-OpeningFlashFix-v1.9.9-B9ABAAAE98B1/`, containing `moddesc.ini` and `MergeMods/EnhancedPowerWheel.m3m`. M3M SHA256: `B9ABAAAE98B196E769110DD2C07A3DE89FEB5E6B1681680EE8E11D42388808BE`.

Owner installation merges only `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc`. Use Mod Manager's managed basegame backup and record existing installed mods before installation. Uninstall by restoring that backup and reapplying desired mods; see [toolchain research](../research/toolchain.md).

Pending game checks: first opening and repeated close/reopen must show personalized page 0 with no old-icon flash; verify occupied/empty slots and mapping badges without hover, open while moving the stick, switch pages, and close/reopen mid-fade. Check weapon wheel still renders normally. Save/quit/reload remains separately unconfirmed.
