# Pull / Flare hover color POC (LE3 1.0)

This POC colors `Pull` (Atracción) blue and `Flare` (Bengala) red whenever either power is hovered on the player wheel. It deliberately does not decide whether they form a combo. It preserves the owner-validated two-page ordering and icon fade behavior.

## Local package findings

- Installed LE3 `SFXPower_Pull.pcc` declares `PowerName = 'Pull'` (SHA256 `AB2EAC68E212419BAB7E6EB25AB29E0625135AB77A4DA82CAC0F837F6254C391`). DLC `DLC_EXP_Pack002/CookedPCConsole/SFXPower_BioticFlare.pcc` declares `PowerName = 'Flare'` (SHA256 `1559E2D61B4BA381A7A0DFB86CBD7F143B279001F627B81834BB941285EF38E1`). The displayed localized names are not used in the code.
- `Startup.pcc` contains the controller `GUI_SF_ME2_PowerWheel.ME2_PowerWheel` movie. A local ignored extraction was inspected with FFDec 26.3. Its XML places each `Icon###` as a sprite with `powerIconMC.sub`, containing named states `selected`, `selectable`, `inactive`, etc. The visible shape at the front of each state is unnamed. There is no verified separately addressable outline clip. The research SWF and XML remain in ignored `research/local/LE3/Startup/` and are not distributed.
- `GFxValue.SetColorTransform` can tint the named state sprites through `Icon###.powerIconMC.sub.<state>`. This affects the whole state, including the icon glyph and other contents. The POC tests whether the outline is visible and attractive with that tint. An outline-only implementation would need more UI investigation or a licensed SWF edit.

## Implementation

`HoverPowerIcon` keeps the existing hover behavior, then checks `pPower.PowerName`. When the hovered power is `Pull` or `Flare`, it applies a blue/red multiplicative color transform to both powers' state sprites on the visible player page. `LeavePowerIcon` restores the identity transform before clearing vanilla hover state. Closing the wheel and changing pages already call `LeavePowerIcon`. No fields, save variables, power data, quickslots, or SWF assets are changed.

The Merge Mod replaces `HoverPowerIcon` and `LeavePowerIcon` in addition to the existing wheel changes. `addtoclassorreplace` still recompiles `SFXSFHandler_PowerWheel` for the existing `Update` override, so interactions with other mods editing that class remain to be checked in game.

## Build and test

UnrealScript validation passed against the installed `SFXGame.pcc`; Mod Manager 9.2.1.137 produced M3M v1 SHA256 `3271102CAB9C5A859D0BACF3494C60838CCCF203AE2E2F77819D27F008C4A04A`. Import folder: `dist/EnhancedPowerWheel-LE3-PullFlare-POC-3271102CAB9C/`. The build/export did not install the mod. The installed `SFXGame.pcc` hash after export was `E27BEEE0163629CE40DB9EEA9E4FB0709E1A20882ADD07AAFAF13CF872881599`; it contains installed mods and is not a pristine baseline.

Owner's in-game checks:

1. Put Pull and Flare on the same visible player page. Hover Pull: Pull should be blue and Flare red. Hover Flare: the same two colors should remain. Hover an unrelated power and close/reopen: the colors should return to normal.
2. Check `selected`, `selectable`, and cooldown/inactive visuals, then switch page and back. Confirm the colors do not linger on reused slots and page fade and LT ordering still work.
3. Judge whether the outline is clear and whether tinting the glyph/text is acceptable. This cannot be established by compilation alone.

Before importing, use Mod Manager's managed LE3 backup and record its current modified files. This experiment targets the basegame `SFXGame.pcc` through Mod Manager's Merge Mod; uninstall by reverting to the manager backup and reapplying desired mods, rather than manually overwriting the package. No game files were altered by this repository's scripts.
