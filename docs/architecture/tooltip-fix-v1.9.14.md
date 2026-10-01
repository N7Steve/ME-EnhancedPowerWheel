# Tooltip persistence and font normalization, version 1.9.14

## Confirmed evidence

The owner reports that right-hand mapping destinations still disappear shortly after hover, and that Map/Use/Switch text does not match Reorder power. The supplied screenshot shows missing destination glyphs. Read-only inspection of installed LE3 confirms the 1.9.13 helper is installed; its serialization-cache workaround did not resolve the reported behavior.

Installed `SetMapText` writes through `oPanel.SetTextFieldText` and controls leading button visibility. Installed `UpdateTextDisplayForIcon` builds localized mapping strings using native player/squad tokens, including shoulder/trigger configuration and already-mapped exclusions. Both the string parser and text adapter are native. Their internal timing has not been traced. The source uses config tokens such as `[XBoxB_Btn_LB]`, so raw UI strings must not bypass the adapter.

## Changes and source-based expectations

Add a replacement for `SetMapText` that preserves the existing text writes and visibility behavior, then captures the resulting native `htmlText` into three properties on the wheel. `EPWUpdateSwitchHint` derives destinations from that snapshot on subsequent frames, rather than trying to reconstruct them from text whose image has already been removed. Each native tooltip write replaces the snapshot, including changes of power and unavailable mapping rows. Target parsing, texture resources and 32-pixel images retain the existing implementation. This removes dependence on processed-text serialization for target recovery; persistent rendering still requires an owner game check.

Replace the specific `size="20"` substitution with case-independent scanning of every quoted SIZE attribute, and add an explicit 18-pixel font for fields with no size markup. Normalize native help text display scale to 100%, matching the dynamically created Reorder/Switch labels. Cache and restore authored scales outside controller power help. Reorder and Switch remain at size 18. Accepted block coordinates, row interval and contextual labels remain.

Only tooltip presentation changes. The opening override, inherited `Super.Update`, pagination, fade, ordering persistence and quickslot assignment logic are untouched. Existing local LE2 work is preserved.

## Validation and reproducible export

All 15 manifest functions compile against installed LE3. Base/PC virtual inheritance passes (110/110), the eight EPW helpers remain final/nonvirtual, and only explicitly listed class exports change. `git diff --check` passes. Installed `SFXGame.pcc` SHA256 before/after inspection, build and export: `82E07572670E39E97296096E23B77A5260803CACDAD2F6DA7FA1BCAEF52F4CB2`. No installation performed.

Reproduce with the pinned toolchain using `scripts/Build-Le3.ps1`, then `scripts/Export-Le3Folder.ps1`. Export: `dist/EnhancedPowerWheel-LE3-TooltipFix-v1.9.14-0C7F8CEEB948/`. M3M SHA256: `0C7F8CEEB9483F03AF80D5565175AAFD06BA204500A1BA0F7B2C10C2C7E23068`.

Owner installation merges only `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc`. Use Mod Manager's managed basegame backup and record existing mods before installation. Uninstall by restoring that backup and reapplying desired mods. See [toolchain research](../research/toolchain.md).

Pending game checks: hover an occupied power for 30 seconds; compare all six help rows with Reorder power; move between powers with different assignments, squad powers and empty slots; switch pages and close/reopen; check shoulder/trigger variants and both languages; confirm cleanup of hidden targets and restoration in weapon/PC mode. Compilation does not validate Scaleform runtime timing or visual appearance. Save/quit/reload remains separately unconfirmed.
