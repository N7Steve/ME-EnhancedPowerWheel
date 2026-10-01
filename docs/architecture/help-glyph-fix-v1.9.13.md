# Persistent help glyphs and HTML size correction, version 1.9.13

## Evidence and diagnosis

The owner reports that 1.9.12's right-hand mapping icons appear for one frame and then disappear, while LB and R3 are oversized. Their screenshot confirms missing target glyphs and oversized custom action glyphs. Read-only decompilation confirms the installed LE3 helper contains the 1.9.12 implementation.

The source clears `sTexture` whenever the native row's serialized HTML differs from the cached processed HTML. After removal of the original image tag, a serialization change can enter that branch with no image tag, erase the cached target and prevent its display. This is a concrete source path matching the reported persistence failure. GFx serialization timing itself has not been traced in game. Additionally, 1.9.12 hides every custom target at the start of every update, so losing its reference immediately leaves it hidden.

The 50-pixel size came from native movie-clip bounds. The owner's rendered screenshot disproves treating those bounds as the matching HTML image dimension. The shared texture and HTML rendering paths do not have a confirmed one-to-one relationship between their visible extents.

## Changes

Only the existing `EPWUpdateSwitchHint` helper changes:

- Cached target texture and original token-bearing HTML survive reserialization of processed text without an image tag. A fresh native image tag can replace the target; unknown fresh image markup keeps native rendering.
- Target fields are hidden on close/outside power mode, empty rows or missing recognized targets. The unconditional hide at the start of every visible update is removed.
- All custom HTML images, including the mapping targets, LB and R3, use 32 pixels instead of the previous 50-pixel assumption. Custom field sizes and horizontal center offsets are adjusted accordingly. This smaller size is an evidence-based visual correction from the screenshot; exact parity with native icons remains an owner check.

Font size 18, the accepted block position, 30-pixel row interval, text-height alignment, contextual Place/Swap labels and Switch wheel as the last row remain. Opening, fade, gameplay, assignments and saved ordering code are unchanged.

## Validation and export

All 14 manifest functions compile against installed LE3. Base/PC virtual inheritance passes (110/110), all eight EPW helpers remain final/nonvirtual, and class export changes remain limited to explicitly listed classes. `git diff --check` passes. Installed `SFXGame.pcc` SHA256 is unchanged before/after read-only inspection, build and export: `138DE37BF797A42B3FD99819959E835F67F0B93D0F61EE62EDEF9D92522009A8`.

Reproduce with the pinned toolchain using `scripts/Build-Le3.ps1`, then `scripts/Export-Le3Folder.ps1`. Export: `dist/EnhancedPowerWheel-LE3-HelpGlyphFix-v1.9.13-9CF69462042E/`, containing `moddesc.ini` and `MergeMods/EnhancedPowerWheel.m3m`. M3M SHA256: `9CF69462042E27484814E550F9AD7449F5949B2417C4FD947A08DCB55FE0E5B4`. No installation performed.

Owner installation merges only `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc`. Verify Mod Manager's managed basegame backup and record existing installed mods first; uninstall by restoring that backup and reapplying desired mods. See [toolchain research](../research/toolchain.md).

Pending owner checks: leave an occupied slot hovered for at least 30 seconds to verify persistent right-side Y/LB/RB targets; move between powers with different mapping options, empty slots and squad powers; switch pages and close/reopen repeatedly; confirm target cleanup when rows disappear and native HTML restoration outside power mode; compare LB/R3 and target sizes with the native leading icons; check both languages and shoulder/trigger variants. The fixes are compiler-validated, not in-game-validated. Save/quit/reload remains separately unconfirmed.
