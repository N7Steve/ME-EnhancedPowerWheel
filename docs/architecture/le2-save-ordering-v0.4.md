# LE2 save-specific ordering 0.4

## Accepted baseline and scope

The owner confirms 0.3.4 works very well and requests persistent ordering/settings. They explicitly confirm the layout should survive saving/loading/restarting separately for each save/character, as in LE3. The accepted hover, warning suppression, badge cleanup, help layout and fade are retained. Native LB/RB/Y assignment persistence remains owned by the game; visual defaults remain mod code, since there is no runtime configuration menu. Page index, in-progress pick, hover and animation remain transient; opening still starts on page 0.

## Confirmed LE2 evidence

Read-only installed-package inspection identifies `BioWorldInfo.GetGlobalVariables()` and `BioGlobalVariableTable.IntVariables` as an integer array. LE2 exposes `SetInt(int nIndex, int nValue)` with two arguments; LE3's third sparse-allocation argument cannot be copied. The inspected SFXGame SHA256 is `9E31EAA7F5879910E10DBD0407C6E5BEAC9D1A8A040BE9C60F7A822E55556E2A`.

The [Trilogy Save Editor PlotTable implementation](https://github.com/KarlitosVII/trilogy-save-editor/blob/main/src/save_data/shared/plot.rs) serializes integers as a vector, and its [ME2 save implementation](https://github.com/KarlitosVII/trilogy-save-editor/blob/main/src/save_data/mass_effect_2/mod.rs) includes this plot table. Its [ME2 raw plot database](https://github.com/KarlitosVII/trilogy-save-editor/blob/main/databases/me2_raw_plot_db.ron) lists known native integers up to 855. This supports using a bounded low project block rather than LE3's 740200-range integers. The database is evidence of known native IDs, not proof against every installed mod allocation.

LE2 SFXPower exposes BaseName and PowerName. The native wheel uses BaseName for tutorial identity. BaseName is therefore used as the stable identity, falling back to PowerName when absent; persistence across evolved variants is source-based inference pending a gameplay check. No proprietary extracted source/assets are tracked.

## Record and integration

LE2 project plot integers 7400–7416 contain one marker and sixteen power-identity keys. The marker is decimal 1162893105 (`EPW1`); zero denotes an empty position. Keys use the existing LE3 rolling-hash approach, applied to uppercase LE2 BaseName/PowerName. The integer array grows to at least 7417 entries, about 29 KiB total; the additional amount depends on its prior length. This block is independent of LE3's allocation and has not been registered as a universal mod namespace.

`EPWSaveMap` refuses to overwrite a nonzero foreign block whose marker is not EPW1, and refuses a native setup containing no real powers. It uses LE2's SetInt after explicitly extending IntVariables, writes the marker last, and skips writes when keys already match. No forced autosave or direct save-file editing occurs. The modified table is expected to be serialized by the game's ordinary save path, as supported by the save-format source; actual gameplay round-trip remains unverified.

`EPWLoadMap` restores recognized identities to their saved slots, deduplicates current source entries, inserts newly available powers into the first holes, and fills missing native empty-source tokens afterward to retain the eight-source map invariant. It does not depend on mutable native source positions. Unknown/removed powers leave holes; the next normalized record contains the currently available powers. Hash collisions or duplicate BaseNames among modded powers are a remaining identity limitation.

The existing redraw reads the current loaded save every time. Only a synchronous LB placement uses its freshly edited Flash map, via `EPWLE2SavePending`. That flag is cleared after persistence and on opening/closing. The saved map is canonicalized immediately after a successful write, so movement of internal empty tokens cannot cancel a later cross-page pick. Cached map/source strings are refreshed after reconstruction; they do not override a different loaded save. A changed reconstructed layout/source signature clears a stale pick. If a foreign plot block prevents writes, saved persistence is unavailable and later reconstruction falls back to native order; no foreign data is altered.

Three final helpers are added before their callers in the manifest. Native wheel fields/struct layouts, cleanup, visual helpers and inherited Update behavior remain unchanged. Ordering still relocates the native eight player entries into sixteen positions, rather than collecting additional powers beyond that limit.

## Validation and artifact

All members/replacements compile and round-trip against installed LE2 SFXGame and the registered vanilla backup. Class/struct property declarations remain unchanged and all EPW helpers are final. The build checks the installed SFXGame hash remains unchanged and compares embedded M3M scripts to the manifest. `git diff --check` passes. These checks establish compilation and merge structure, not runtime serialization.

Export: `dist/EnhancedPowerWheel-LE2-SaveOrdering-v0.4-7E845E587E6E`.

M3M SHA256: `7E845E587E6E44E39A5094DC8D67CBE178F702D7EEBFF5D9CED573B52FA4FC37`.

Build/export do not install or modify saves. Deployment changes only `Game/ME2/BioGame/CookedPCConsole/SFXGame.pcc`; INSTALL.txt retains the restorable Mod Manager backup, test-save copy, historical Startup recovery and uninstall by restoring SFXGame/reapplying desired mods. The extra plot data is inert after uninstall; existing saves need no deletion or direct editing. Other mods editing the handler or using this block need separate compatibility checks.

## Required owner validation

Reorder across both pages, save A, quit LE2 completely, restart and load A. Both pages should retain their layout. Change the layout and save B, then load A/B in the same process: each must restore its own arrangement. Load another character or a save without an EPW record and check default order. Check power evolution, source-order changes, newly acquired/removed powers, and repeated cross-page picks after reload. Verify retained hover, First Aid counter, badge rendering/close cleanup, warning suppression and compact help. Unsaved changes should be lost when loading an older save. Save/quit/reload results have not yet been reported.
