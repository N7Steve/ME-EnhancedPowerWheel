# LE2 UI cadence and tooltip fixes 0.3.1

**Retired speed correction:** the owner reports that the 30 FPS reset is too slow with their current mod setup and explicitly assigns UI cadence to another mod. [0.3.2](le2-r3-color-icons-v0.3.2.md) removes the entire asset/FPS correction and retains the improved tooltip text. This document records historical evidence, not the active build.

## Owner report

The owner confirms 0.3 works, but reports that wheel animations, cooldown displays and effects are too fast. They explicitly confirm that the page fade speed is correct. Their screenshot shows both added hint rows rendered as boxes instead of usable labels/icons. The new fixes still require in-game confirmation.

## Confirmed timing evidence

The installed controller wheel movie in `Startup_INT.pcc` is at 240 FPS; the registered vanilla backup is at 30 FPS. Comparing the complete 121,979-byte resources finds exactly one difference, at byte 18: the integer byte of the GFX 8.8 frame-rate field. Both controller and PC wheel movies are installed at 240 FPS. The eight installed Startup localizations contain byte-identical copies of each wheel resource.

This 240 FPS resource was already present in the earlier local wheel research capture. EPW 0.3's script-only export did not write Startup packages. The report establishes when the owner noticed the speed problem, but does not prove that the new Update event introduced it. The current package also retains vanilla power-wheel activation (`bPlayersOnly = TRUE`); no compensating slow-time request is installed in that path.

0.3.1 restores the two wheel movies to the backup's native 30 FPS. It does not change time dilation, world/actor clocks, movement, cooldown calculations or any other gameplay system. No dependency on another timing mod is introduced. The script fade is byte-identical to 0.3 and retains its 600 alpha units/second timing.

## Tooltip correction

The runtime-created text fields did not set `embedFonts` or `html`, unlike the LE3 implementation and the authored LE2 HTML text fields. 0.3.1 enables both before setting the font/icon markup. It keeps the installed native L3/LB textures, authored AeroLight Shared 16 font, amber text and existing placement. It also applies vanilla help's `shadowStyle = s{1,1}t{0,0}` and `shadowColor = 3342336`.

Labels now follow visible English/Spanish vanilla action text when detected. A cached language choice remains while an empty slot has no vanilla action label. The render symptoms and missing field configuration make this the evidence-based tooltip correction; native glyph rendering remains an owner test.

## Build and verification

`Le2WheelMovieRestorer` reads the installed Startup packages and the registered vanilla backup, writes only under ignored `build/LE2/MergeMods`, and verifies:

- The backup's controller/PC wheel FPS is 30.
- Localized source movies are identical before enabling localization-wide application.
- Exactly one byte changes in each wheel export for 240 -> 30; all other export bytes remain unchanged in the generated package.
- Saving/reopening preserves the result, and the installed source hash stays unchanged.
- A repeat build from an already restored 30 FPS source changes zero export bytes.

The output-path guard rejects writing beneath the input directory or outside the generated build directory. Script compilation/round-trip and native wheel property-layout checks pass against the installed package. The two serialized merges are checked against their source manifests; the embedded asset package hash matches the verified generated copy. Proprietary generated PCC/M3M/SWF output remains ignored, for local owner testing only; no asset redistribution permission is asserted.

Installed source hashes remain unchanged during the work:

- `SFXGame.pcc`: `2038407035927B1BE128B879694285CB98FB4E5239CBA5A1C3DFD93ECBAF30C2`.
- `Startup_INT.pcc`: `E6114657F8200B76EEF2D4E2854C0DAA63C54D41F7A118703285B33E71A2405D`.

## Artifact

Export: `dist/EnhancedPowerWheel-LE2-UIFix-v0.3.1-3F876E98AF54`.

`EnhancedPowerWheel.m3m` SHA256: `3F876E98AF54E6DE40E242C83FF13E89AFB0E73F1753C253A51FB358B8C279CD`.

`WheelMovies.m3m` SHA256: `F9680113425529C8418969039AC07797AEE23A255D2A26D3B5CA626421B1538A`.

## Deployment, rollback and owner test

With LE2 closed, import/install the folder through Mod Manager over working 0.3. Install both merges. Keep the registered vanilla backup at `Y:/Mass Effect/Backups/LE2`, the installed-mod order and a test-save copy. This version changes these files under `Game/ME2/BioGame/CookedPCConsole`:

- `SFXGame.pcc`.
- `Startup_DEU.pcc`, `Startup_ESN.pcc`, `Startup_FRA.pcc`, `Startup_INT.pcc`, `Startup_ITA.pcc`, `Startup_JPN.pcc`, `Startup_POL.pcc`, `Startup_RUS.pcc`.

The movie merge targets only controller/PC wheel frame-rate restoration across those locales. The exported `INSTALL.txt` includes the changed-file list and backup/removal plan. Uninstall by restoring all listed files through Mod Manager and reapplying wanted basegame mods; restoring only SFXGame leaves the movie changes installed.

Check opening, hover, cooldown/effects and closing at normal vanilla cadence. Confirm the fade retains its previously accepted duration. Check readable labels, native L3/LB images and vanilla-style placement/shadow on both pages, including English help as in the screenshot. Recheck LB pickup/placement sound, blue outline, moves/swaps and First Aid counts. Startup, cadence and tooltip fixes remain pending owner confirmation.
