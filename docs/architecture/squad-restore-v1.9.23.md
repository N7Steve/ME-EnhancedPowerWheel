# LE3 squad restoration after native reconstruction v1.9.23

Owner follow-up confirms the reported ordering reset is fixed. No separate
save/quit/reload report was supplied. The remaining first-opening image bug
for Garrus ArmorPiercingAmmo is addressed in
[v1.9.24](squad-icon-v1.9.24.md).

## Confirmed live evidence

The owner reports v1.9.22 still resets squad positions even on wheel close/reopen.
Read-only installed-package inspection confirms v1.9.22, including explicit
`SetInt(..., TRUE)` and the readback diagnostics. Installed SFXGame SHA256:
`1C649FC764BA7493B75E3BF7B7BF0FE0B80A017DDFBCC3AE0CAA31ECBCC996AF`.

The owner opened LE3, reordered, closed/reopened and left the wheel visible
for a read-only process scan. It returned scoped strings with zero read
failures. Captures stay ignored in
`research/local/LE3/SquadPersistenceFailureMemory/`; no process writes,
injection or game/save edits were performed.

Garrus's diagnostic reports bank 0, marker 1, and saved/resolved keys:

| Slot | Saved key | Resolved key |
| --- | --- | --- |
| 0 | 1837324 (ConcussiveShot) | 1837324 |
| 1 | 451992 (Overload) | 451992 |
| 2 | 0 (empty) | 0 |
| 3 | 9584136 (ArmorPiercingAmmo) | 0 |
| 4 | 2265462 (ProximityMine) | 2265462 |

Tali reports bank 1, marker 0, and one native EnergyDrain source. Companion
tags are recognized. The Garrus marker and saved keys establish that writes
survive wheel closing; they do not establish a save/quit/reload round-trip.
The immediate failure is in restoration, not absence of a saved plot layout.
The previous omitted-SetInt-flag diagnosis did not resolve the reported failure.

## Source-based diagnosis and change

The old restore ran at the start of pending-P handling, before every native
`SetupPlayerPowers` call and before restoring Shepard's full manager roster.
It also filtered source identities through visual state, rejecting real power
references when native setup left an empty state. This transient-state pattern
is already handled by the validated Shepard rebuild. The live record confirms
the ammo identity is unresolved at that early point; it does not expose native
internals or prove which individual native call changes squad presentation.

Restore now runs after all native player setup, after roster/display-index
restoration and player population, before final mapping/text refresh and the
existing opening reveal. It runs for each page-0 rebuild, including R3 return.
There is no second restoration at the old early point.

Source identity now accepts an actual `pPower` even when its visual state is
empty. Occupied sources normalize selected/empty states as Shepard's rebuild
does, then execute the native hover/select/leave cycle to recompute availability.
Public empty activation/hover guards are unchanged. Name-only squad content
still uses the existing guard. No manager or gameplay power data is modified.

Saved schema, bank IDs, controls, quickslot assignments, Super.Update, P marker,
opening reveal and fades are preserved. Bounded latest write/load diagnostic
records are now separate for each side, so reopening does not overwrite the
last write readback.

## Verification and deployment

All 18 manifest functions compile/decompile against installed LE3. The compiled
restore calls occur after full-roster restoration and final player population.
Only listed class exports change; inheritance passes 110/110; all eleven helpers
are final/nonvirtual. `git diff --check` passes. Existing LE2/README work remains.

Export: `dist/EnhancedPowerWheel-LE3-SquadRestore-v1.9.23-F895BCC306EE/`.
M3M v1 SHA256:
`F895BCC306EE82D32E9E240EA1725C88A28885320140ABAADDA838014668A440`.
Installed SFXGame hash stayed unchanged during research/build/export.
No installation performed; runtime correction remains to be confirmed.

Retest the current Garrus layout on opening, move/swap then close/reopen,
R3 away/back, save/quit/reload, ammo cooldown and native use/mapping. Existing
plot keys are reused; no reset or new save is required. The saved hole must
remain at slot 2 and ArmorPiercingAmmo must restore to slot 3 in this capture's
case. If still failing, compare separate write/load diagnostic records.

Only `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc` is merged through Mod Manager.
Keep its verified managed basegame backup, record installed mods and retain a
pre-test save. Uninstall by restoring that backup and reapplying desired mods;
restore the save copy to undo ordering. The export includes `INSTALL.txt`.
