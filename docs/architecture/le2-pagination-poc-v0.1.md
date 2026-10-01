# LE2 pagination POC 0.1

## Scope and controls

The first LE2 implementation tests the same basic milestone as LE3's initial empty-page experiment: keep the controller power wheel open while switching content. Open on native page 0; R3 toggles an empty page 1 and back. Closing from either page resets to page 0. L3 retains the original behavior. This checkpoint does not implement ordering, save variables, added power capacity, fades or combo outlines.

## Implementation

Four existing functions in `SFXGame.pcc` are replaced: `HandleInputEvent`, `SelectCurrentWheelItem`, `HoverPowerIcon` and `WheelVisibilityChanged`. There are no added class members, class recompilations, native hooks or asset edits. LE3 sources and the validated checkpoint are untouched.

While in controller `PWM_Powers`, the first icon's existing `sID` temporarily stores `EPW1`, one visibility character per physical power icon, and its original ID. Entering page 1 captures all visibility flags, removes hover, and hides each power icon, mapping icon and mapping background. It retains the power/pawn references and original combat data. This uses a console-only marker because the PC wheel uses icon IDs; it does not enter pagination in `PWM_PC` or `PWM_Weapons`.

Page 1 consumes A/X/B, suppresses hover, and blocks `SelectCurrentWheelItem` before its native power activation call. On return, the script reads the snapshot before native setup, restores the original ID/visibility, refreshes native states and mapping artwork, and resets the processed stick angle. The existing visibility callback restores the snapshot before its original open/close handling, including closing from page 1. Native mapping actions on page 0 remain unchanged; no input assignments or quickslots are rewritten by pagination.

The temporary marker and native hide/setup behavior are experimental; compilation alone cannot confirm that native updates retain them. Runtime checks must establish that the snapshot survives and that cooldown/state/badge rendering restores correctly. No compatibility guarantee is made for mods replacing the same functions.

## Build and export

With the verified paths configured as described in `docs/research/toolchain.md`:

```powershell
./scripts/Build-ResearchTool.ps1
./scripts/Inspect-Le2.ps1
./scripts/Build-Le2.ps1
./scripts/Export-Le2Folder.ps1
```

Build validates UnrealScript in memory against installed LE2, verifies the pinned Mod Manager version, serializes M3M v1, compares all four embedded scripts/targets to the sources and verifies that the installed package hash is unchanged. Export refuses an existing destination, checks the copied merge hash and includes `INSTALL.txt`. Neither operation installs anything.

Export: `dist/EnhancedPowerWheel-LE2-PaginationPOC-v0.1-410EB521F405`.

M3M SHA256: `410EB521F4054E03DF387CBC4670CD3608ACF7C4227812C4E256ABF81417F22C`.

## Validation status and deployment

All four functions compile and decompile successfully against the installed target; class export data remains unchanged. The serialized artifact's game/package/function targets and script text exactly match source. Installed package SHA256 remains `BB99E7A8882EC2D1562E5276FEABC5E7AF64548A6B5E1F93BC52BC00F1C937E7`. The owner subsequently confirmed basic pagination works, while noting no icons/placeholders or ordering on the empty second page. Other edge cases were not separately reported. The next milestone is [functional ordering 0.2](le2-ordering-poc-v0.2.md).

The owner installs through Mod Manager. The only planned installed-file change is LE2 `Game/ME2/BioGame/CookedPCConsole/SFXGame.pcc`. Before installation, verify a restorable Mod Manager LE2 basegame backup, record the current package hash and installed mods, and copy the test save. Uninstall by restoring that backup through Mod Manager and reapplying other desired basegame mods. The exported `INSTALL.txt` supplies the changed functions and test sequence.

Test first native opening, repeated R3 toggles, no A activation or X/B assignment on page 1, no hidden hover, restored player/squad icons and badges, cooldowns/blocked states, close/reopen from both pages, and unchanged weapon/PC wheel behavior. Retest with no squadmates and a deflected stick. Only after this milestone is owner-confirmed should ordering/content be expanded.
