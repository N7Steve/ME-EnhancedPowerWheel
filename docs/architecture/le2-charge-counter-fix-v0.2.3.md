# LE2 First Aid charge counter correction 0.2.3

## Owner-confirmed checkpoint

On 2026-10-01 the owner confirmed that 0.2.2 works, then reported that moving First Aid leaves its charge number in emptied or previous slots. This confirms the startup recovery and working wheel in that test. Save persistence, zero-charge behavior and all other edge cases have not been independently reported.

Preserved export: `dist/EnhancedPowerWheel-LE2-PanelLifetimeFix-v0.2.2-D7D02E9E0888`. M3M SHA256: `D7D02E9E08887A65B8A64BCA6E5E64B18D7F59E65392E8D13645E8298408000B`.

## Confirmed local evidence and explanation

The installed LE2 wheel SWF has a shared `txtInfo` field in sprite 203, separate from the state/artwork clips. Its initialization styles `mainContent.Icon001.powerIconMC.sub.txtInfo` and equivalent player/squad fields. Static inspection of the matching LE2 native executable shows a string-writing routine at RVA `0xbe59e0–0xbe5c86` using `.powerIconMC.sub.txtInfo` for the controller path (and `.txtInfo` for the alternate path), returning when the relevant power/pawn pointers are absent. These are ignored local research assets, not redistributed source or SWFs.

The 0.2.2 redraw moves the power struct and artwork to destination paths but does not reset this separate text field. A leftover counter therefore survives reassignment to an empty slot. Native source setup can also leave text at its original physical position during a redraw. This explains the reported artifacts; precise live call timing has not been traced.

## Minimal correction

Only `HandleInputEvent` changes from the owner-confirmed 0.2.2 wheel sources. Its internal player-page redraw now:

1. Clears all eight physical player counter fields before native source setup.
2. Captures the resulting source text beside each native power struct.
3. Writes the source text into its mapped destination, or an empty string for a destination without a power.

The source text is copied rather than calculating or modifying Medi-Gel charges. Page changes, moves and swaps use the same redraw. Native counter updates continue to use the reassigned power references and destination paths. No native class addition, Update override, cleanup panel access, quickslot edit or save write is introduced.

## Validation and artifact

All five existing-function replacements compile and round-trip against the registered vanilla LE2 package. All original class export hashes remain unchanged. The four other wheel function sources match the preserved 0.2.2 export sources, including vanilla `CleanupReferences`. The generated M3M is checked against the manifest and embedded scripts. Build/export leave the installed game unchanged.

Export: `dist/EnhancedPowerWheel-LE2-ChargeCounterFix-v0.2.3-F71CC5FCF6BC`.

M3M SHA256: `F71CC5FCF6BCDBD43F1A353EEB5DBE9D230652987B067C9BF0D3D9E224CB7762`.

## Owner test and deployment

With LE2 closed, import/install the export through Mod Manager. It may be installed over working 0.2.2; failing 0.2/0.2.1 installations still require restoration first. Keep the verified registered vanilla backup and the installed-mod order. The only game file changed is `Game/ME2/BioGame/CookedPCConsole/SFXGame.pcc`. The exported `INSTALL.txt` lists all five replacement functions and the backup/removal procedure. Uninstall by restoring the LE2 basegame backup through Mod Manager and reapplying desired mods.

Retest repeated First Aid moves into empty positions and swaps with occupied positions on both pages, including changing page while selected. Its previous positions and positions containing other powers must have no stale charge text. Check close/reopen, using First Aid and its updated count, and zero charges. This correction is compiled but not yet owner-confirmed in game.
