# Static empty-slot hover v1.9.27

The owner reports that leaving a hovered empty slot briefly enlarges and shrinks
it, resembling a deselection animation. Empty slots should have no hover animation.

## Evidence and minimal change

Read-only inspection of installed LE3 SFXGame.pcc confirms bSelected, eState and
eDesiredState on SFXGUIValue_PowerIcon and native SetHover/SetSelected/SetState
methods. Installed LeavePowerIcon still unconditionally calls SetHover(FALSE,
bSkipTransition) and SetSelected(FALSE), even though EPW's empty-slot entry
bypasses their matching TRUE calls. Their engine implementations are native and
not recovered here: attributing the reported flicker to this asymmetric exit
is source-based inference, not a confirmed animation-engine trace.

LeavePowerIcon now invokes native hover/selection setters only for EPWHasPower
slots, using the same occupied-slot predicate as HoverPowerIcon. Empty slots
clear bSelected directly and retain PWPS_EmptySelectable as eDesiredState.
Both entry and exit call SetState only if the slot is not already in that empty
state, avoiding redundant forced state refreshes on each hover. The normal empty
path consequently calls none of these three native transition/state methods.
The conditional correction handles an unexpected EmptySelected state.

Text metadata clearing on empty entry, current-hover tracking for LB placement,
Use/Map/activation guards, native occupied-slot animation and combo exit fades
remain intact. No gameplay, quickslot, save-layout, Update or opening code changes.
Existing local LE2/README and squad changes are preserved.

## Validation and artifact

All 18 manifest functions compile/decompile against installed LE3. Decompiled
entry/exit confirm occupied-only native hover/selection calls, bSelected FALSE,
and conditional SetState(5, TRUE), where installed enum value 5 is EmptySelectable.
Inheritance passes 110/110, all eleven helpers remain final/nonvirtual, and only
explicitly listed class exports change. git diff --check passes. Visual flicker
resolution remains pending owner in-game verification.

Installed SFXGame.pcc SHA256 before/after inspection/build/export:
`C25632A04B920EBD5ACEF4C8E61FDA182EA72530B8D2D8FBC35DE795C784B28A`.
No installation performed. Package research remains ignored under
research/local/LE3/EmptySlot-v1.9.27 and research/local/LE3/Validation.

Export: `dist/EnhancedPowerWheel-LE3-EmptySlot-v1.9.27-CEEB5749B20F/`.
M3M SHA256:
`CEEB5749B20F5633618632BD2467702EFBFB21471800223656B0533320B89F25`.
Reproduce using scripts/Build-Le3.ps1 with installed LE3/pinned Mod Manager
paths, then scripts/Export-Le3Folder.ps1.

Check occupied -> empty -> occupied and empty -> empty repeatedly on both
pages and both squad sections. Empty slots should retain size on entry/exit,
no description or Use/Map actions, and remain valid LB placement destinations.
Check LB move into the hole, swap/cancel, R3, close/reopen, occupied hover and
retained combo fades. These are runtime checks, not established by compilation.

Deployment merges only Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc through
Mod Manager. Retain its managed basegame backup, record installed mods and keep
a pre-test save. Uninstall by restoring the backup and reapplying desired mods
or the prior checkpoint; restore the save copy to undo ordering. Exported
INSTALL.txt contains the changed file, backup and uninstall instructions.
