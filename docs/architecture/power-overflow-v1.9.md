# Shepard power overflow v1.9

## v1.9.1 startup correction

The owner reported that v1.9 closes LE3 before reaching the main menu. The installed failing package has SHA256 `428EBD50DD19CAF9EB4B72AB5740A07B666EDF264687F3F5B06F4705B35ADA2D`. No LE3 crash dump/stack was found in the inspected game and document directories; the available loader log does not identify the exception. The exact crash cause is therefore not stack-confirmed.

A binary inspection found a concrete structural defect: the base wheel's virtual table contains 113 entries, while its native `SFXSFHandler_PCPowerWheel` subclass has 110. The three absent inherited functions are `EPWPlayerPowers`, `EPWPowerKey`, and `EPWSaveMap`, which v1.9 incorrectly declared non-final. Existing EPW combo helpers are final. This is the leading source-based explanation for a load-time failure, before opening the wheel executes the collection code.

Version 1.9.1 changes only those three helpers to `public final function`, plus version/export metadata. In-memory validation against the failing installed package now gives 110 entries in each class, no missing inherited functions, and all five EPW helpers final and absent from the virtual table. No subclass code, quickslots, or collection behavior is changed. Tables are class-specific; this check compares inherited membership/count, not positional ordering between different classes.

`PackageResearch auditwheel <SFXGame.pcc>` performs this read-only check. Merge validation now runs it after compilation and rejects the missing-member/non-final-helper condition that v1.9 passed. The audit fails on the installed v1.9 package and passes on the corrected in-memory merge. Compilation alone previously missed this defect.

The corrected export is `dist/EnhancedPowerWheel-LE3-PowerOverflow-v1.9.1-AD9735003E14`; M3M SHA256 `AD9735003E14DABF174986958A391703CAF4F04F5A63FA0C957882F6A9B75C53`. Build/export do not install it. Startup recovery is not yet owner-confirmed. Install the corrected merge through Mod Manager using its documented backup/restoration path below, then check reaching the menu before testing a save or overflow. Keep the prior known-working 1.8 export for rollback.

## Confirmed local findings

The supplied Bonus Bonus Powers 2.0 folder contains six M3M merges. Their manifest entry lists do not modify `SFXSFHandler_PowerWheel` or `SFXGUIValue_PowerIcon`. `handle-power-falloff.m3m` replaces `SFXPowerManager.GetPowerWheelPowers` and `SFXGameModeDefault.TryUsePower`. The getter returns every enabled, HUD-visible power with positive rank; it assigns active powers their manager-array index, Unity an index after active powers, and ammunition powers still higher indices. BBP's descriptor explicitly describes ammunition/Unity disappearing with Loose Power Limits and overflow with No Power Limits. Extracted third-party manifests remain ignored in `research/local/LE3/BonusBonusPowers`.

The installed LE3 getter has the same eligibility and index assignment. Its `SetupPlayerPowers` and `SFXGUIValue_PowerIcon.SetPower` are native: a package decompilation cannot prove their internal overflow algorithm. The exact native overwrite mechanism remains an inference from the owner's report and the supplied mod's descriptor. Our previous redraw demonstrably captured only the eight physical player icons after native setup, so it could never recover powers already excluded at that stage.

Installed validation target: `SFXGame.pcc`, SHA256 `46B7B271BB55D9D4911EA29D6675274D0115E6BD493C31933041A5D599D01178`. This is a modded installation, not a pristine LE3 baseline.

## Implementation

`EPWPlayerPowers` asks the installed power manager for its eligible list, deduplicates by `PowerName`, and retains the first 16 entries in manager order. No power-manager functions are replaced. The page map supports source characters `0-F` plus `-` for empty. New powers occupy the first empty absolute slot, covering page 0 before page 1. Existing saved identities stay in place, including intentional holes. Powers beyond 16 are not represented; there is no wraparound or replacement of another displayed source. This changes Shepard's capacity only; squad overflow and additional pages are outside this checkpoint.

Native setup remains responsible for icon metadata and state. During a redraw, the handler saves the manager's `Powers` array and display indices, temporarily presents one eligible power at a time to `SetupPlayerPowers`, locates the resulting icon by its power reference, and snapshots the same fields used by the previous checkpoint. It restores the complete array and indices synchronously before repopulating the visible page. A source that native setup fails to provide becomes empty rather than borrowing another icon. This is a POC to reuse BioWare's native initializer without inventing its private icon setup. It involves up to 16 native setup calls per redraw, not per frame. Native callbacks, Unity, ammo, cooldowns, mappings, and redraw cost need gameplay verification. Temporary roster isolation must not be advertised as proven compatible with arbitrary mods.

The first-open `P` marker and `Super.Update(fDeltaT)` remain intact. Existing LB selection, page fade, combo outlines, and hover feedback are preserved from the pre-existing working tree. No quickslot logic is edited. `HandleInputEvent` now uses `addtoclassorreplace` alongside its helpers, because the local compiler's standalone `CompileFunction` path did not resolve newly added class members. The wheel class was already recompiled by previous checkpoints; other mods editing it still require compatibility checks.

## Save format and migration

Marker 740200 is now 3. Plot ints 740201-740204 pack four base-17 source values each (0-15 source, 16 empty). Additional project allocations 740210-740225 store the power identity at each visible slot: a case-normalized `PowerName` rolling hash, modulo 10000019, plus one; zero denotes empty. These IDs have not been checked against every other mod. Hash collisions are theoretically possible; tested locally available names did not collide. The packed source map is retained for inspection; version 3 restores positions from identity keys, rather than trusting changing native indices.

On reopening, identities that are still eligible retain their slots; removed or disabled powers free their slots; previously unseen powers fill the first hole. Updated identities are written on opening and after LB placement. The game must save to persist them to disk.

Version 2 maps retain their original validation (eight distinct source positions). Migration resolves each old native source position to its current real power, then records identities. It cannot recover the historical identity of a position that BBP had already overwritten before migration, because version 2 never stored that identity. For a fresh layout with at most eight powers, native positions seed the initial arrangement; remaining powers fill holes. A fresh overflow layout starts in manager order.

## Validation and export

LegendaryExplorerCore successfully compiled seven class member additions/replacements and four standalone replacements against the installed package in memory. The package tool verified that only the explicitly listed wheel class changed class export data. Local algorithm checks cover distinct sources at capacities 0-16, no wraparound with 17 powers, page-crossing swaps, identity restoration with roster changes, all 83521 four-value base-17 groups, and 49 locally recovered power names without key collisions. The serialized M3M manifest was also checked to contain only wheel-class changes. These checks model the save/allocation algorithms, not execution inside LE3.

Mod Manager 9.2.1.137 serialized the merge; export verified identical build/export hashes. M3M SHA256: `CFC19803CB76AF6FF8229C2FE87DC3D07316BA88CF97BD0803B9E31427F3E137`.

Import folder: `dist/EnhancedPowerWheel-LE3-PowerOverflow-v1.9-CFC19803CB76`. Build/export did not install anything. The installed package hash remained unchanged.

For owner installation, the basegame file changed by this merge is `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc`; the export contains only `moddesc.ini` and `MergeMods/EnhancedPowerWheel.m3m`. Before installation, verify the Mod Manager managed backup/restoration path for the current installation and retain the test save separately. Revert by restoring the managed basegame backup and reapplying desired mods/the prior wheel checkpoint. Version 3 plot data remains in saves already written; an older wheel does not understand this format. Keep a pre-test save to restore its previous ordering.

Gameplay checks still required:

1. With BBP, verify 8, 9, and 16 eligible Shepard powers: page 0 renders immediately, the ninth is on page 1, and every power appears exactly once.
2. Verify Unity and every available ammunition power, activation, cooldowns, and existing mappings on both pages.
3. Move/swap powers across pages using LB, reopen, add another BBP power, and verify old positions stay fixed. Remove a power and verify the hole is reused without duplicates.
4. Save, quit, reload, and check the same layout. Test another save and migration from a version 2 layout.
5. Confirm squad display, page fades, closing mid-fade, and hover outlines. Check for noticeable redraw delay.
6. With more than 16 eligible powers, verify the first 16 remain distinct; further powers require a future capacity extension.
