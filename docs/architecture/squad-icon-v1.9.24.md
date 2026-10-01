# Squad state image initialization v1.9.24

## Owner observation and package evidence

The owner confirms v1.9.23 resolves the reported squad order reset. Garrus
ArmorPiercingAmmo has a separate rendering defect: on first opening its slot
has no power image; hover reveals it, and moving the power makes it remain
visible. The supplied screenshots show an empty image in the occupied upper
middle slot, then the armor-piercing image in its selected state. Other squad
powers were not separately reported to exhibit this defect.

Read-only installed-package inspection target SHA256:
`082C209A7FEB67B67FA54F6203808F421E26FD4E6DBBF3BD82EB3659BA0F3A33`.
The package stayed unchanged through inspection/build/export. Research is
local and ignored. Existing local wheel SWF research confirms per-state
`powerIconMC.sub.<state>.iconMC` loaders, the authored `SetIcon(resource,index)`
API and the IconResourceLoader resource/frame caching behavior. The existing
NotSuggested presentation already calls this API to initialize a substitute
state's loader without changing the power's gameplay state.

## Source-based explanation and change

Squad reconstruction calls native SetIcon before assigning the final state;
the destination can still have its prior empty state then. State switching
can subsequently expose a different loader. The symptom suggests one such
uninitialized loader, but native internals and exact initial loader contents
were not measured; this is an inference, not confirmed native implementation.

After native display setup and hover/leave availability refresh, each occupied
squad slot now initializes the six occupied state image loaders with its
current icon resource and frame. Missing loader objects are skipped. The
two empty states are excluded. No state, availability, alpha or visibility
is forced by this extra step, and it runs once per squad reconstruction,
not per frame. It also prepares cached loaders when a different power moves
into the same physical slot. The existing proxy state can use the initialized
loader without any change to the NotSuggested presentation option.

One bounded latest `EPW16 INPUT squad image` record per physical occupied
slot captures name, current/desired state, frame and resource for the existing
read-only memory reader if the failure continues. This does not change input,
saved layout, cooldowns, manager rosters or quickslot assignments. Empty-slot
guards, late restoration, P redraw, Super.Update and reveal are retained.

## Verification and export

All 18 functions compile/decompile against installed LE3. Inheritance passes
110/110, all eleven helpers remain final/nonvirtual and only listed class
exports change. Compiled output retains both SetIcon arguments and excludes
empty states. `git diff --check` passes. Prior LE2/README changes are preserved.

Export: `dist/EnhancedPowerWheel-LE3-SquadIcon-v1.9.24-B3E3DA641410/`.
M3M v1 SHA256:
`B3E3DA641410888872E9BD03DB7AE65FD25AF3FE823F16A2DD073C6C4E0120E0`.
No installation performed. Owner runtime verification is still pending.

Check ArmorPiercingAmmo on first opening before touching the stick, then
hover/leave without moving it, close/reopen, R3 away/back and cooldown/ammo
activation. Check other squad powers and empty slots, and retained ordering.
Save/quit/reload remains a separate unreported check.

Installation merges only `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc` through
Mod Manager. Retain its managed basegame backup, record installed mods and
keep a pre-test save. Uninstall by restoring the backup and reapplying desired
mods/the previous checkpoint; restore the save copy to undo ordering. The
export contains the updated INSTALL.txt with these instructions.
