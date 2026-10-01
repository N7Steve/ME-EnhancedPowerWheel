# Combo outline exit fade v1.9.26

The owner requested that red outlines fade away when hover moves to a power
without a combo. This extends v1.9.25's entry fade with a 0.2-second real-time
smoothstep exit from each departing outline's actual displayed alpha.

Confirmed source behavior: HoverPowerIcon invokes LeavePowerIcon on a different
hover. Page reconstruction and wheel closing also invoke LeavePowerIcon, so
bSkipTransition alone cannot reliably distinguish hover from cleanup. Hover now
sets a one-use transient GFx EPWComboSoftLeave marker on the previous icon;
Leave consumes it before performing the native hover/selection cleanup.

A soft leave snapshots alpha/time on active red clips and marks them fading
out. Already departing clips keep their original timer during further hover
changes. Update advances exit fades in its existing all-icon/all-state traversal,
even when the new hover is empty or has no primer mask. At zero alpha it hides
the clip and clears its active/fading flags. A currently compatible red outline
cancels its exit and follows the existing entry/pulse behavior. Violet outlines
remain disabled. Each snapshot is per state clip; native state visibility remains
in control, so actual visible continuity during native state changes still needs
in-game confirmation.

Hard Leave calls clear active/fading flags immediately, including when there is
no current hover, to prevent pending fades surviving close/page reconstruction.
Only hover switches request the soft exit; direct native leave remains immediate.
No new class properties, save variables, gameplay or quickslot changes. The
existing Super.Update, P redraw, opening reveal and page fade remain intact.
Previous local LE2, README and squad changes are preserved.

Validation: all 18 manifest functions compile against installed LE3. Decompiled
output retains the soft marker, alpha snapshot and exit alpha multiplication.
Virtual inheritance passes 110/110; all eleven EPW helpers are final/nonvirtual;
only explicitly listed class exports change. git diff --check passes. These
checks do not confirm runtime appearance; owner in-game verification is pending.

Installed SFXGame.pcc SHA256 before and after this build/export:
`E249D208882730656F6C90B04338825DB4958AA85190E11D0FB32370152BBEF2`.
No game installation or package writes were performed. Compiler/decompilation
output remains ignored under research/local/LE3/Validation.

Export: `dist/EnhancedPowerWheel-LE3-ComboFade-v1.9.26-F71D033BB613/`.
M3M SHA256:
`F71D033BB613FEAD7FE7EDED65079CB922F022DF9307C766DF65F410BD2D7F81`.
Reproduce with scripts/Build-Le3.ps1 then scripts/Export-Le3Folder.ps1, supplying
the installed LE3 and pinned Mod Manager paths to Build-Le3.

Check a primer then an unrelated power: old red borders should fade down over
0.2 seconds without a new pulse jump. Repeat during entry fade, over an empty
slot, across squad/Shepard icons, with rapid unrelated hovers and by returning
to a primer. Close and R3 during exit, reopen, and check no stale borders. Verify
the retained green LB selection outline. Native state-switch continuity and
existing squad image/cooldown/save-reload checks require separate runtime testing.

Deployment merges only Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc through
Mod Manager. Retain its managed LE3 basegame backup, record installed mods and
keep a pre-test save. Uninstall by restoring the backup and reapplying desired
mods/the prior checkpoint; restore the save copy to undo saved ordering. The
export includes INSTALL.txt with the file, backup and uninstall instructions.
