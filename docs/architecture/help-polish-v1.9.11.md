# Contextual help and icon spacing, version 1.9.11

## Evidence

The owner accepted 1.9.10 and supplied a game screenshot showing the help rows. They requested hiding Reorder power on empty-slot hover, separate Place/Swap labels, more icon/text spacing, aligned icon/text centers, the same Y artwork at both ends of the mapping row, and slightly larger row spacing.

Existing LE3 input/hover source confirms `m_nCurrentPowerIconIndex` tracks empty player slots too; `aPlayer.Find` identifies player slots and `pPower` identifies occupied destinations. Selection remains character 16 of the existing runtime layout state. No input or save logic changes are needed.

Local wheel SWF inspection confirms `mcButtonMap3` imports `xboxBtnY` from `Xbox_ControllerIcons.swf`. The trailing native mapping text instead uses the `[XBoxB_Btn_Y]` token, whose installed controller defaults resolve to `BIOA_ControllerIcons_XBOX.xbox_Y`. These are different artwork sources. The movie's authored text uses a 20-pixel font and native buttons have a centered origin with approximately 78.125% scale. The installed Startup package also contains `GUI_SF_Xbox_ControllerIcons.Xbox_ControllerIcons_YBtn` (export 951). Extracted assets remain ignored and are not redistributed.

## Changes and source-based expectations

Only `EPWUpdateSwitchHint` changes behavior:

- Without a selection, the ordering row appears only over an occupied player slot. Empty slots, no player hover and squad slots hide it.
- With a selection, player-slot hover shows Place/Colocar on an empty slot or Swap/Intercambiar on an occupied slot. Existing same-slot cancellation behavior is unchanged.
- Text columns move another 8 Flash pixels right while leading button columns retain the 24-pixel block displacement from 1.9.10. Row spacing increases from 28 to 30 pixels.
- Native leading icons use one center offset, 13 pixels below the text field origin. Custom HTML icons move 4 pixels down from their previous position. These are modest alignment adjustments inferred from the screenshot and authored layout; actual visual alignment remains an owner check.
- The trailing Y uses `GFxValue.AttachMovie` with the exact imported `xboxBtnY` symbol used by the leading icon. When that attachment is available, the Y image tag is removed from that row's HTML and the replacement clip follows the text's measured width, with the same native icon scale and vertical position. Native HTML is cached and restored on close/outside power mode when still applicable. Other mapping targets and all assignments retain native behavior.

Native positions remain cached absolute coordinates, avoiding cumulative X movement. The existing language fallback, font, color, outline and hide-on-close behavior remain. Opening redraw, page fade, gameplay and persistence code are unchanged.

## Validation and export

All 14 manifest functions compile against installed LE3. Virtual inheritance passes (base/PC 110/110), all eight helpers remain final/nonvirtual, and class export changes remain limited to explicitly listed classes. `git diff --check` passes. Installed `SFXGame.pcc` SHA256 is unchanged before/after build/export: `7F20B61C2DB132573A5BEAE67F06BEC0494B1744B67F1525F471C5C8DC2C3D85`.

Reproduce with the pinned toolchain using `scripts/Build-Le3.ps1`, then `scripts/Export-Le3Folder.ps1`. Export: `dist/EnhancedPowerWheel-LE3-HelpPolish-v1.9.11-64A212E55D3E/`, containing `moddesc.ini` and `MergeMods/EnhancedPowerWheel.m3m`. M3M SHA256: `64A212E55D3E4A9EA5F893E3BF0840F1756ACE762D11C093ED3A73BA56BFDC5A`. No installation performed.

Owner installation merges only `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc`. Verify Mod Manager's managed basegame backup and record existing installed mods first; uninstall by restoring that backup and reapplying desired mods. See [toolchain research](../research/toolchain.md).

Pending owner checks: empty/occupied player hover with and without selection, squad hover, same-slot cancellation, both pages and languages; identical leading/trailing Y artwork and scale; stable Y placement through hover changes and repeated open/close; centered icons and adequate horizontal/vertical spacing with the maximum action count; weapon/PC mode restoration, no cumulative drift and no clipping. Save/quit/reload remains separately unconfirmed.
