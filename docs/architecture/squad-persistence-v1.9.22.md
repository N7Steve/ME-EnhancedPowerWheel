# LE3 squad persistence correction v1.9.22

Superseded after the owner reported the same reopen failure. Live read-only
diagnostics confirm writes do persist in the current plot table and implicate
opening reconstruction. See [v1.9.23](squad-restore-v1.9.23.md).

## Confirmed evidence

The owner reports v1.9.21 squad ordering works, but resets on closing/reopening
the wheel and loading a save. This confirms the interaction, not persistence.

Read-only inspection of the current installed `SFXGame.pcc` confirms the
v1.9.21 squad helper writes its custom integers with two-argument `SetInt`.
The installed native signature is:
`SetInt(int nIndex, int nValue, optional bool bSkipAllAdditionalProcessing = FALSE)`.
Shepard's existing `EPWSaveMap` passes `TRUE` to every custom plot write.
The third argument's documented name means bypassing additional processing;
it does not by itself prove sparse allocation behavior. Native setter internals
remain unverified. Bulk output stays in ignored
`research/local/LE3/SquadPersistenceResearch/`.

Installed package SHA256 before/after research, build and export:
`F75D7D5E007943F7877E7A2FFD44C7D19C7424E5928FD46BEF7E27F2DC1B2395`.
The game was not running during this investigation, so live plot readback
was unavailable.

## Change and diagnosis limits

Every squad layout write now uses `SetInt(..., TRUE)`, matching Shepard's
working path for project-allocated integers. The version marker is cleared
before the five keys and committed last. No schema, companion bank, power
identity, controls, page rebuild or quickslot assignment changes.

The omitted flag is a source-based explanation for why custom squad plot
values do not survive even wheel reopening; the fix needs in-game confirmation.
On each write/load the helper keeps one bounded latest diagnostic per squad
side, beginning `EPW16 INPUT squad`. It includes pawn tag, bank, write/load
mode, readback marker, and saved/resolved keys per slot. This lets the existing
read-only memory reader distinguish an unsupported tag, failed plot write or
opening reconstruction mismatch if the failure persists. No process writes
or save-file edits are used.

## Verification and export

All 18 functions compile against the installed package and decompile back.
Base/PC virtual inheritance passes 110/110; all eleven helpers are final and
nonvirtual; only listed class exports change. Compiled squad writes retain
the explicit `TRUE` argument. `git diff --check` passes. Previous local
LE2/README changes are preserved.

Export: `dist/EnhancedPowerWheel-LE3-SquadPersistence-v1.9.22-7653340C6744/`.
M3M v1 SHA256:
`7653340C67441916DB2A0FD5C165A5B45AA4137796D1929B8D850F5E1CF6A52F`.
No installation performed. This is a test build, not a validated checkpoint.

After installing, reorder again; failed v1.9.21 writes may not have retained
the previous layout. Check close/reopen first, then save/quit/reload and
changing a companion's side. If it still resets, capture the wheel after
reordering and after reopening with `scripts/Read-Le3WheelMemory.ps1`;
captures remain ignored under `research/local/`.

Installation merges only `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc` through
Mod Manager. Verify its managed basegame backup and restore path, record
installed mods, and keep a pre-test save. Uninstall by restoring that backup
and reapplying desired mods/the previous wheel; restore the pre-test save
to revert ordering. Plot data is inert after uninstall. The export includes
the updated `INSTALL.txt`.
