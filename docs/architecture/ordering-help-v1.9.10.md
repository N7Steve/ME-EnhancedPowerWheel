# LE3 ordering help and spacing, version 1.9.10

## Confirmed evidence

The owner requested the LB ordering tooltip already present in LE2 and a small rightward shift of the LE3 help block. LE3's existing input handler uses LB to pick, move/swap and cancel a player power. Its runtime state stores the selected slot at character 16 (`A`–`P`, with `X` meaning no selection). Read-only inspection of the installed LE3 `Startup.pcc` confirms the LB texture at export 293, `BIOA_ControllerIcons_XBOX.xbox_LB`; existing local controller defaults associate it with LB.

## Change and source-based expectations

`EPWUpdateSwitchHint` appends a second custom row after Switch wheel: LB with `Reorder power` / `Reordenar poder`, changing to `Place / Swap` / `Colocar / Intercambiar` while a power is selected. It shares the existing language detection, embedded AeroLight font, blue color and outline. Both custom rows hide on close and outside controller power mode. Native action order, empty-row compaction and the 28-pixel baseline interval remain.

All visible native help text/buttons and both custom rows move 24 Flash pixels to the right. Native X and Y are cached once using `GetDisplayInfo`; the update writes an absolute cached X plus 24 using `SetDisplayInfo`, avoiding the runtime `_x` feedback implicated in the 1.9.4 drift. Close and other wheel modes restore cached native coordinates. Actual spacing, clipping and absence of drift remain game checks. Input, ordering persistence, opening redraw, fade, quickslots and gameplay code are unchanged.

## Validation and export

All 14 manifest functions compile against the installed LE3 package. Virtual inheritance passes (base/PC 110/110), all eight EPW helpers remain final and nonvirtual, and only explicitly listed classes change class export data. `git diff --check` passes. Installed `SFXGame.pcc` SHA256 is unchanged before/after build and export: `81902BA09B78AA4EF425211F195287653277C8BC8A518B3FCB84761CE313147E`.

Reproduce using the pinned toolchain with `scripts/Build-Le3.ps1`, followed by `scripts/Export-Le3Folder.ps1`. Export: `dist/EnhancedPowerWheel-LE3-OrderingHelp-v1.9.10-D3A5D9DDBCE6/`. Contents: `moddesc.ini` and `MergeMods/EnhancedPowerWheel.m3m`. M3M SHA256: `D3A5D9DDBCE6DD1340C9E7E64EB88FEBE8E1F0E73F30ABB06FBFFF9E6CB877B2`. No installation performed.

Owner installation merges only `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc`. Verify Mod Manager's managed basegame backup and record existing installed mods before installation; uninstall by restoring that backup and reapplying desired mods. See [toolchain research](../research/toolchain.md).

Pending owner checks: both languages; no hover, empty and occupied slots, squad hover and varying action counts; LB pick, cancel, move/swap across pages with the label following selection; leave help visible for at least 30 seconds to check stable X; close/reopen and weapon/PC modes; confirm the longer Spanish label fits. Opening and fade should retain previous behavior. Save/quit/reload remains separately unconfirmed.
