# LE3 squad ordering and empty activation guard v1.9.21

Owner follow-up: ordering works in game, but resets on wheel close/reopen
and loading a save. Persistence is not validated. See
[v1.9.22 persistence fix](squad-persistence-v1.9.22.md).

## Confirmed package evidence

Read-only inspection of installed LE3 `SFXGame.pcc` on 2026-10-01: SHA256
`ED1A7E301F43D263211E7ACFD053F9C72D9F5620665C00FCCBB25D98FB0A3C08`.
This is the owner's modded installation, not a pristine vanilla baseline.
124 selected exports decompiled without failures; output remains ignored in
`research/local/LE3/SquadOrderingResearch/`.

The power wheel declares five indices per companion: `aHench1` is
`(13,14,15,16,17)` and `aHench2` is `(4,3,2,1,0)`. Native power icon objects
hold pawn, power/name identity, text, icon resource, cooldown and state;
physical paths/boundaries belong to slots. `GetHenchmanMappedPower` reads
`SFXPawn_Henchman.m_nmMappedPower`. The script hover path has a name-only
fallback when `pPower` is null. Native selection and icon operations cannot
be verified internally from UnrealScript decompilation.

`SFXPawn_Henchman` uses `Tag` to find engine henchman records, and
`GetUIAppearanceTag` returns `Tag`. Its configured companion list contains
garrus, tali, liara, ashley, kaidan, edi, prothean, marine and anderson with
the `hench_` prefix. This supports using these tags for persistent banks;
behavior across mission/squad changes remains a runtime test.

## Authored behavior and inference

`EPWHasPower` rejects both native empty states and requires a power reference
or a squad pawn plus nonempty power name. Keeping the pawn/name fallback
preserves the installed script's representation; its use by native code is
an inference, not a confirmed runtime observation. `SelectCurrentWheelItem`
uses this guard before native activation, also covering the PC mouse-up path.
Hover normalizes an empty slot's state/text/references, leaves it without a
selected power visual, and clears native Use/Map through the existing text
update. A destination remains hoverable for LB, matching Shepard's design.

On page 0, LB picks/places/swaps within the hovered companion's five slots.
Selecting on another character starts selection there; no power can move
between characters. The source has the existing green move outline and the
help uses the existing localized Reorder/Place/Swap rows. Same-slot LB,
closing, or R3 cancels a squad pick. Shepard's page/selection string retains
its existing format and behavior; selecting one character clears the other
pending reorder operation.

`EPWSquadLayout` snapshots native GUI content, transfers it to destination
slots, clears all text/identity/cooldown metadata for holes, and uses native
display and hover/leave operations to refresh availability. Pawn managers,
`WheelDisplayIndex`, quickslot assignments and gameplay data are untouched.
The mapping display reads the native assignment each update so its D-pad
badge follows the moved power. Reordering does not assign a quickslot.

Saved layout uses plot integers **740300-740353**, nine fixed banks of six:
version 1 followed by five power-name keys (zero for empty). Bank order is
the tag list above, independent of squad side. Keys use the same bounded
hash algorithm as Shepard's identity keys, without altering Shepard's
save block. Writes occur only on a completed squad move/swap. Opening
matches saved identities against native visible content and puts new powers
into remaining holes. Unknown custom tags reorder for the current opening
without persistent storage. Hash collisions and other mods claiming this
plot range are not covered by compilation. A scoped search found no other
use in this repository or the local BBP, Dynamic Time Wheels and Gameplay
Tuner source directories; that is not a general compatibility guarantee.

Restoration runs on the pending `P` opening redraw, after native population.
`Super.Update`, opening reveal, fades, Shepard rebuilding and cooldown rules
are preserved. No new class fields or native hooks are introduced.

## Build and pending runtime validation

All 18 manifest functions compile against the installed package. Only listed
class exports change; base/PC virtual inheritance passes 110/110; all eleven
EPW helpers are final/nonvirtual. Compilation includes decompilation of the
result. `git diff --check` passes. Existing LE2/README changes are preserved.

Export: `dist/EnhancedPowerWheel-LE3-SquadOrdering-v1.9.21-C0F95517BFB5/`.
M3M v1 SHA256:
`C0F95517BFB59C8D9F8A719AE7BF02AD87102F0EDF4DBA4770E87B8B8960C5AD`.
The installed package hash stayed unchanged before/after research/build/export.
Build/export did not install anything; this is not an owner-validated checkpoint.

Pending game checks: both companion sections, empty A/no Use text, move to
empty, occupied swap, same-slot cancel, no cross-character transfer, native
activation and mapping after moves, cooldown/dead companion states,
close/reopen, R3 away/back, companion side changes, learned powers and
save/quit/reload. Retest Shepard's first opening, ordering, both pages and
usable cooldown icons. Detailed checklist ships in `src/LE3/INSTALL.txt`.

## Deployment and uninstall

Only `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc` is a merge target.
The owner installs through Mod Manager after verifying its managed basegame
backup/restoration path, recording installed mods and keeping a pre-test save.
Uninstall by restoring that backup and reapplying desired mods/the prior wheel.
Extra squad plot integers are inert after uninstall; restore the test-save
copy to revert saved ordering. Do not overwrite installed PCCs manually.
