# Independent tooltip text rendering, version 1.9.15

## Confirmed evidence

The owner tested 1.9.14 and reports that destination icons appear briefly after every new power hover, then disappear; font flicker occurs during those frames. This invalidates the previous persistence fix. Read-only inspection confirms the installed package contains 1.9.14's helper and `SetMapText` snapshot replacement. Installed SFXGame SHA256: `01A8AE1F8361F886E7EF8C724EFFCE0C2214EBA5C41C8454FA828365FBEEA7E8`.

The 1.9.14 source edits the native map/use text fields from `Update`, then compares their serialized `htmlText` to decide whether to edit again. `SetMapText` additionally reads those same fields immediately after the native adapter writes them. Native adapter/parser implementation and frame timing are not exposed by UnrealScript decompilation. The owner report confirms a runtime failure; it does not prove which native operation invalidates the immediate snapshots or processed-text comparison.

## Change and source-based expectation

`EPWUpdateSwitchHint` now treats the native map/use fields as read-only content sources. Four persistent `EPWHelpText0`–`3` fields render their visible text, using the same dynamic TextField creation, embedded AeroLight Shared font, size 18 and glow outline as Reorder/Switch. Native text is hidden while this controller power-help presentation is active. Its HTML and scale are never changed by EPW. Native leading action buttons retain the accepted repositioning.

The renderer compares each native source's HTML to the corresponding proxy's cached source. A source change generates normalized proxy text and extracts its destination image. The comparison never reads the renderer's output back as input. Destination fields keep their texture until the next source change; empty sources hide their proxy/target. Close and weapon/PC modes hide proxies/targets and restore the native field visibility and button coordinates. A failed proxy creation leaves native presentation available.

The `SetMapText` replacement is retained in the manifest to restore vanilla-equivalent writes and button visibility when merging over installed 1.9.14. It no longer captures HTML. No `UpdateTextDisplayForIcon` replacement, new class member, memory reader, input assignment change or SWF modification is introduced. Opening redraw, inherited `Super.Update`, pagination, fades and save-specific ordering remain unchanged.

This removes a concrete read/modify/read feedback path and applies uniform fonts through independent fields. Runtime persistence and appearance remain an owner check; no in-game confirmation is claimed.

## Validation and export

All 15 manifest functions compile against installed LE3. Base/PC virtual inheritance passes (110/110); all eight EPW helpers remain final/nonvirtual; only explicitly listed class exports change. `git diff --check` passes. The installed SFXGame hash is unchanged after inspection, compilation and export. Existing local LE2 and earlier LE3 work is preserved.

Reproduce with the pinned toolchain using `scripts/Build-Le3.ps1`, then `scripts/Export-Le3Folder.ps1`. Export: `dist/EnhancedPowerWheel-LE3-StableHelp-v1.9.15-518E3698F019/`. M3M SHA256: `518E3698F019C708BC9F25F3BE97B3BC6C2B5C4D039F358FDB4CACC2D0658067`. No installation performed.

Owner installation merges only `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc`. Use Mod Manager's managed basegame backup and record existing mods first. Uninstall by restoring the backup and reapplying desired mods; see [toolchain research](../research/toolchain.md).

Pending game checks: keep one power hovered for at least 30 seconds; repeatedly change powers; verify steady destination icons and text, including Use/Reorder/Switch; check empty/squad slots, changed mapping availability, page transitions, closing/reopening, contextual Place/Swap, both languages, shoulder/trigger variants and weapon/PC restoration. Save/quit/reload remains separately unconfirmed.
