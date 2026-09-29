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

## Owner feedback and 1.1 revision

The owner confirmed the 1.0 colors work in game. Hovering Flare showed strong red and blue. Hovering Pull showed both colors much darker, although both powers remained selectable. This is an unintended visual difference, not a signal about combo order. The exact native/Scaleform dimming step has not been isolated; both colors changing together suggests an icon state or hover transition rather than the hard-coded role mapping.

Version 1.1 applies a small additive color component after `Super.Update` on each frame, so a dark state gets extra light. Its intensity follows a sine wave using `WorldInfo.RealTimeSeconds`, which continues through wheel time dilation. Both icons share the same pulse phase and color strength regardless of which is hovered. Only their current and desired state clips are updated per frame; `LeavePowerIcon` still restores all eight named states. The pulse uses color only and does not change power state, cooldown, hit testing, or save data.

Visual parity, smoothness, and the effect of the additive color on the glyph and background require another in-game check. Outline-only tint remains unimplemented because the SWF outline shape is unnamed.

The 1.1 UnrealScript validation passed against the installed LE3 package, and Mod Manager produced M3M v1 SHA256 `13969062759A067A2C4974D4DFC965B63B0E2812E8CA90B15F888FC9B0912AA7`. Export: `dist/EnhancedPowerWheel-LE3-PullFlarePulse-POC-13969062759A/`. The installed `SFXGame.pcc` hash after this export was `A392FA7379C2C4CCACCF5ED4FC3C40B925E265F5E3719CEAF36CEFA88F08C8B6`. The build/export scripts did not install the mod.

## 1.1 result and 1.2 diagnosis

The owner installed 1.1 and reported no visible change. A read-only decompilation of the installed `SFXGame.pcc` (SHA256 `8D8603274E11329320F4CD5E3D5FBD7B283BA6179C917E8D68CE6B9C470494B0`) confirmed that its `Update` contains the pulse code and its `HoverPowerIcon` no longer contains the 1.0 static tint. This rules out installing the old Merge Mod as the cause. The local SWF's `CXFORMWITHALPHA` additive color terms use values such as 50, 79, 113, 154 and 201; 1.1 used only 0.14–0.55 in `ASColorTransform.Add`, which is too small on a 0–255 color scale to be visible. This is a source-based diagnosis, not yet a runtime measurement of the native GFx conversion.

Version 1.2 sets RGB multiplication to zero and adds a blue or red color at 190–230 units, with both icons sharing the same sine wave. This is intended to make the output largely independent of the selected/available state's original darkness while preserving pixel alpha and shape. The icon contents will have a flatter color. It is still a visual experiment requiring in-game confirmation of equal brightness and a visible pulse.

The 1.2 script validation passed against the installed LE3 package. Mod Manager produced M3M v1 SHA256 `77DF3DB4C1FCA6817EC55549F09DDC7F7BB6B48812BBEA358BD78EDF692389E4`. Export: `dist/EnhancedPowerWheel-LE3-PullFlarePulse-v1.2-77DF3DB4C1FC/`. The installed `SFXGame.pcc` hash remained `8D8603274E11329320F4CD5E3D5FBD7B283BA6179C917E8D68CE6B9C470494B0` after build/export.

## Owner-confirmed 1.2 and directional outline 1.3

The owner confirmed that 1.2's bright pulse works, but coloring the entire icons is too conspicuous. For this visual POC only, Pull is treated as the primer and Flare as the detonator. Hovering Pull draws a thin red border on Flare; hovering Flare draws a dimmer blue-violet border on Pull. The hovered icon is not tinted. This is an illustration of direction, not a gameplay combo check.

The controller SWF's `selected`, `selectable`, and `inactive` states use the same border path. Its shape records give a top curve and six straight segments within roughly `x=-44.25..16.65`, `y=-11.25..33.55` Flash pixels. The border shape has no instance name, so 1.3 creates one empty child movie clip in the currently shown state and draws a `0.85` pixel line over that path with ActionScript movie clip drawing calls. It changes only this clip's alpha each frame: red `38–54%`, blue violet `18–28%`, both on the same sine wave. `LeavePowerIcon` hides those clips across all states; page changes and wheel closure already call it. It also restores any color transforms left by the earlier POC. No extracted SWF is shipped.

The UnrealScript validator and Mod Manager compiler passed for 1.3. M3M v1 SHA256: `FF56088D29302892C39D1FB8AD6B8FFC432F12E6205FEC0263EFF3CD494444EE`. Export: `dist/EnhancedPowerWheel-LE3-ComboOutline-v1.3-FF56088D2930/`. The installed `SFXGame.pcc` hash after export was `EC0FABAAF9AD4180EDB8E4187C44504F66CF81D280AEA004354BD4F845B5BB19`; the build/export scripts did not install the mod.

In-game validation must confirm that the GFx runtime supports creating and drawing into the child clip, that its line matches the border at both icon positions and visual states, that the pulse is subtle, and that switching hover/page or closing leaves no lingering line. Compilation alone cannot confirm those visual behaviors.
