# LE2 startup recovery 0.2.1

**Failed in game:** the owner reported another crash at “Press any key to continue” after restoring the game and installing this candidate. Do not use this export. Removing class recompilation did not resolve the fault. See [0.2.2 panel lifetime correction](le2-panel-lifetime-fix-v0.2.2.md). The diagnosis below is historical.

## Confirmed failure and diagnosis limit

On 2026-10-01 the owner reported that 0.2 crashes before the main menu, before any wheel interaction. Do not use the 0.2 export. The installed failing `SFXGame.pcc` hashes to `E7FBCE15E1F2DDAF9EE244BCFEDB69CC1B5890B951B9CEBBB6567F8D0E32B16D` and still decompiles (92 wheel exports, zero decompilation failures). Successful compilation/decompilation and property-declaration checks did not establish startup safety.

The main structural difference from owner-confirmed 0.1 is native class recompilation through `addtoclassorreplace`, adding a refresh helper and an inherited `Update` override. The pre-menu timing makes this structural/load-time change the leading suspect. No crash stack was available, so the exact cause is not proven. The correction removes this entire difference rather than making another class-recompilation experiment.

## Correction

The manifest contains only replacements of five existing functions: `HandleInputEvent`, `SelectCurrentWheelItem`, `HoverPowerIcon`, `WheelVisibilityChanged` and `CleanupReferences`. There are no new helper members, no `Update` override and no class recompilation. The source files for the former additions were archived locally and removed from the active source.

The existing refresh code is now inside `HandleInputEvent`, entered only by an internal L3 event with negative `fValue`. Real L3 input keeps its native path. Page changes/placement use this redraw request; opening invokes it after the original visibility callback and leaves a pending recheck for the first forwarded input event. This avoids adding a new update callback. Personalized first-open rendering still needs explicit testing, especially native setup occurring after the visibility callback.

R3 navigation, eight visible player positions per page, LT move/swap and occupied-slot A activation remain the target behavior. The layout remains session-only, with no save writes, power-capacity expansion, assignment rewrites or PC quickslot changes. The other render/data assumptions from 0.2 still need gameplay confirmation after startup recovery.

## Validation and artifact

Mod Manager's locally registered LE2 vanilla backup is `Y:\Mass Effect\Backups\LE2`. Only its `BioGame/CookedPCConsole/SFXGame.pcc` was read/copied into ignored research; it was not changed. Its SHA256 is `681F3FC72C08C66BC6D77CA91102E08CEAD7C6A5586C22BAD0A8F7085BE38D77`.

All five replacements compile and round-trip against that vanilla package. The validator checks every original class export hash; all class data stays unchanged, including the wheel. The merge contains only these existing-function operations and exactly matches source. Build/export do not deploy. The build's optional `-ValidationPackagePath` permits validating against the backup while separately checking that the installed package hash stays unchanged.

Export: `dist/EnhancedPowerWheel-LE2-StartupRecovery-v0.2.1-A662C4F56476`.

M3M SHA256: `A662C4F5647600A82763B2535B3FAA24050D1CA4D4F1760CC649119F4C568CAC`.

The failing installed package remains `E7FBCE15E1F2DDAF9EE244BCFEDB69CC1B5890B951B9CEBBB6567F8D0E32B16D`: no installed file was modified by this investigation. Startup recovery and wheel behavior are not yet owner-confirmed.

## Required recovery sequence (owner performs it)

Close LE2. Restore LE2 basegame through Mod Manager using its registered vanilla backup, then reapply wanted basegame mods in their existing order, excluding EPW 0.2. Import/install 0.2.1 last. A merge containing only function replacements cannot undo the previous native class recompilation: installing directly over 0.2 is not a valid recovery test.

The new merge changes only LE2 `Game/ME2/BioGame/CookedPCConsole/SFXGame.pcc`. Keep the verified backup, record the installed mods/package hash and copy the test save before installing. Removal uses that same Mod Manager basegame restoration followed by reapplying desired mods; do not manually swap PCCs between versions. Exported `INSTALL.txt` includes this plan.

Check startup reaches the main menu before testing anything else. Then load a test save and verify both pages, placeholders without hover, LT placement/swaps, A activation of the intended moved power, empty-slot safety, canceling selection, close/reopen order, cooldown/badge rendering and unaffected weapon/PC controls. If startup still fails after a clean restore/reapply, the class-recompilation hypothesis is insufficient and a crash log/stack becomes the next evidence needed.
