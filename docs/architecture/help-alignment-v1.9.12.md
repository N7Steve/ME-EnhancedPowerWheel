# Help icon consistency and layout, version 1.9.12

## Confirmed evidence

The owner reports improved help in 1.9.11 but supplied a screenshot showing that its trailing Y still has different artwork/size, the right-side glyphs are larger, and Use power is vertically inconsistent with mapping rows. They requested matching glyph sizes and gaps, Switch wheel last, an 18–19 pixel font, and another 24-pixel right/up shift.

Read-only decompilation of installed LE3 confirms the 1.9.11 helper is present. The screenshot establishes that the previous Y replacement did not achieve its intended visual result; it does not establish whether attachment, resource matching or another runtime detail prevented replacement.

Read-only extraction/inspection of the installed Startup controller library confirms the native `xboxBtnY` sprite uses `Xbox_ControllerIcons_YBtn`, with a 64-pixel square shape, including transparent texture margins. A/B/X, LB/RB and RStickPress have the same square extent (RB has a 0.5-pixel vertical origin difference). The wheel scales its leading face buttons to approximately 78.125%, yielding a 50-pixel image extent, much larger than the visibly colored glyph inside it. Startup contains all shared texture resources referenced by this change. Extracted SWFs/XML and decompiled vanilla code remain ignored local research.

## Implementation and source-based expectations

Only `EPWUpdateSwitchHint` changes behavior. Native help text/buttons retain their cached original coordinates; text is at native X + 56, buttons at native X + 48, and the top text baseline at native Y - 24. Relative to 1.9.11 this moves the complete block another 24 pixels right and up, retaining the extra 8 pixels of icon/text separation. The 30-pixel row interval remains.

Native HTML font size 20 is changed to 18, matching both custom labels. Recognized mapping image tags are removed from the text and rendered in separate HTML fields using the shared controller library textures. The image extent follows the native leading icon's width (normally 50 pixels); this preserves the transparent margins of the actual native artwork. The previous `AttachMovie` Y attempt is removed. Right glyph centers follow measured text width and the same text-origin-to-left-icon-center distance, with the text-field inset accounted for. Y uses the same texture as the native leading Y; the right shoulders use the corresponding shared bumper textures. Target recognition retains native shoulder/trigger/squad targets when recognized; unknown markup keeps its native image.

Separating images from text removes their contribution to the mapping line box. Each native row's icon center is calculated from its text height and the text-field inset, rather than a constant offset. Custom icon-only HTML fields use the same center calculation. Switch/order icons also reference the shared controller textures at the native image extent. These layout calculations are source-based expectations; pixel-level appearance and HTML resource rendering require a game check.

Ordering remains contextual: hidden for empty player slots without selection, Place/Colocar for an empty destination with selection, and Swap/Intercambiar for an occupied destination. Its row now precedes Switch wheel. When ordering is hidden, Switch wheel follows the native actions without a blank row. Close/outside controller power mode hides custom glyphs and restores native coordinates and the original HTML when still applicable.

Opening redraw, page fade, gameplay, input assignments and persistence code are unchanged. Same-slot cancellation retains the existing behavior.

## Validation and export

All 14 manifest functions compile against the installed LE3 package. Base/PC virtual inheritance passes (110/110), all eight helpers remain final/nonvirtual, and class export changes remain limited to explicitly listed classes. `git diff --check` passes. Installed `SFXGame.pcc` SHA256 remains unchanged before/after research, build and export: `937C76EFAF624F9FE6420056364330E74E178A9BB87AB724669679B0BF0399F0`.

Reproduce using the pinned toolchain with `scripts/Build-Le3.ps1`, then `scripts/Export-Le3Folder.ps1`. Export: `dist/EnhancedPowerWheel-LE3-HelpAlignment-v1.9.12-C1024EC8000A/`, containing `moddesc.ini` and `MergeMods/EnhancedPowerWheel.m3m`. M3M SHA256: `C1024EC8000AAA9239ADDD7E67A57275179BBAB1F36BBB4988681BE2BAB45629`. No installation performed.

Owner installation merges only `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc`. Verify Mod Manager's managed basegame backup and record existing installed mods first; uninstall by restoring that backup and reapplying desired mods. See [toolchain research](../research/toolchain.md).

Pending game checks: matching Y artwork and left/right glyph sizes/gaps; native and custom text at 18 pixels; consistent vertical centers, including A Use power; no icon/text clipping; Switch wheel last with and without ordering; both languages and pages, differing mapping row counts, shoulder/trigger swaps and squad targets; close/reopen and weapon/PC restoration; stable positions without cumulative drift. Save/quit/reload remains separately unconfirmed.
