# Enhanced Power Wheel

Enhanced Power Wheel is an experimental mod project for the Power Wheel in Mass Effect Legendary Edition. Development starts with LE3. Longer term, the project aims to improve power capacity, ordering, navigation, and the information shown on the wheel.

LE3 v1.10.0 adds a PC proof of concept: Space switches the two lower power bars, dragging moves/swaps powers within a character's slots, and Shepard can cross pages while dragging. It shares saved ordering, icon fades and combo outlines with the controller version. Compilation and structural checks pass against installed LE3 and the local reference; PC gameplay validation is pending. See [PC implementation, export and test plan](docs/architecture/pc-power-bar-v1.10.0.md). Build/export do not install the mod.

The owner reports v1.10.2 works well, including companion reordering. Version 1.10.3 aligns green reorder outlines with PC clip visibility and physical companion slots, and removes the Space / Swap bar indicator completely. Space still switches pages. The new visual changes await an in-game test. See [PC companion outlines and removal of Space help](docs/architecture/pc-outline-v1.10.3.md).

HUD Enhancements 1.1 uses separate handlers that bypass EPW's PC frame update. Compatibility patch 0.4 adds a PC bridge alongside the existing controller bridge and keeps HUD radar, camera handling and graphics. It requires EPW 1.10.3; replace the previous compatibility DLC and install this patch last through Mod Manager. Combined gameplay validation is pending. See [HUD compatibility for PC](docs/architecture/hud-compatibility-pc-v0.4.md).

## LE3 checkpoint: two-page ordering wheel

Version 1.6 extends the directional combo outline to documented LE3 single-player primers and the loaded powers' actual detonator arrays. Visible squad powers participate alongside Shepard's powers. A red border marks a potential detonator for the hovered primer; a violet border marks a potential primer for the hovered detonator. Version 1.7 closes the missing upper-left outline segment reported in game. Conditional primers still require their combat conditions. See [combo hover implementation](docs/architecture/combo-hover-v1.6.md). The exported Mod Manager folder is under `dist/`; build scripts do not install it.

Version 1.8 uses LB to pick and place a power, adds a green border and separate selection/placement sounds, and retains joystick hover after placement. This version needs in-game confirmation. See [move feedback](docs/architecture/move-feedback-v1.8.md).

Version 1.9 collects up to 16 eligible Shepard powers before native icon truncation, fills page 0 then page 1, and keeps saved positions by power identity when powers are added or removed. The owner reported a crash before the main menu with 1.9; do not use that export. Version 1.9.1 makes its three new helpers final to correct a verified virtual-table defect and adds structural validation. Both startup recovery and overflow behavior still need in-game confirmation. See [power overflow](docs/architecture/power-overflow-v1.9.md).

Version 1.9.2 uses R3 to toggle both pages, plays a navigation cue on each accepted toggle, and uses the existing pick cue for placement too. An extra help row reads `R3 - Alternar rueda` with Spanish text settings and `R3 - Switch wheel` otherwise. Compilation and virtual inheritance validation passed against the installed LE3 package; sound and help rendering still need in-game confirmation. See [wheel toggle and help](docs/architecture/wheel-toggle-v1.9.2.md).

Version 1.9.3 follows the visible native action rows with an R3 texture icon and localized label, uses `BrowserSelectMenu` for switching pages, and preserves the stick angle and player slot hover at the fade rebuild. The owner reported 1.9.2 was much better, requested more integrated help and a different sound, and reported the arrow jumping on page changes. These 1.9.3 changes compile and pass structural validation; their visual/audio result needs in-game confirmation. See [dynamic help and arrow continuity](docs/architecture/wheel-help-v1.9.3.md).

Version 1.9.4 uses the pause wheel's actual `BrowserSegmentChange` navigation sound, packs contextual help with uniform spacing, and explicitly recreates the native dark text outline. `NotSuggested` presentation is hidden by default: powers keep their native evaluation and activation rules but use their normal icon appearance. A single optional flag restores the original presentation for future configurable builds. No grey treatment is included. Compilation and structural validation passed; the result needs in-game confirmation. See [wheel polish](docs/architecture/wheel-polish-v1.9.4.md).

Version 1.9.5 addresses two owner-reported 1.9.4 regressions: contextual text drifting offscreen and warning powers disappearing on hover. Native help positioning now changes only Y through display-info flags, and warning-icon substitutes explicitly initialize their artwork and preserve the current state clip during cleanup. The owner confirmed the improved spacing; the regression fixes still need in-game confirmation. See [help drift and hover fixes](docs/architecture/wheel-fixes-v1.9.5.md).

The owner confirmed 1.9.5 now works correctly and reported assignment badges disappearing after page changes or close/reopen. Version 1.9.6 redraws those badges through the native `SetMappingIcon` visual setter after each player-page rebuild. Power assignments are unchanged. Compilation and structural validation passed; badge persistence needs in-game confirmation. See [mapping badge refresh](docs/architecture/mapping-badges-v1.9.6.md).

The owner reported 1.9.6 did not change the missing-badge behavior. Version 1.9.7 reads the three real assignments from `BioPlayerInput` and explicitly sets the existing badge child clips during redraw/update, instead of trusting isolated icon setup metadata. Input assignments remain read-only. The owner confirmed this correction works. See [mapping source correction](docs/architecture/mapping-badges-v1.9.7.md).

Version 1.9.8 removes the first-page restriction from the three native assignment actions. Powers on either page can now be assigned to the same global LB/Y/RB slots; the existing page-independent badge refresh displays those assignments. Compilation and structural validation passed; assigning from page 1 needs an in-game check. See [mapping on both pages](docs/architecture/mapping-both-pages-v1.9.8.md).

Version 1.9.9 keeps power icons and mapping clips transparent during native opening, then reveals them after the pending personalized-page redraw. This addresses the owner-reported brief flash of old icons. Compilation and structural validation passed; eliminating the flash needs in-game confirmation. See [opening flash correction](docs/architecture/opening-flash-v1.9.9.md).

Version 0.8's page fade was confirmed in game, but it also fades the vignette and portraits. Version 0.9 limits the fade to power icons and their mapping clips; the owner confirmed this result works in game. See [fade POC](docs/architecture/fade-poc.md) and [icon-fade POC](docs/architecture/icon-fade-poc.md).

The current LE3 proof of concept has two pages while the Power Wheel stays open:

- Page 0 shows the saved player-power arrangement immediately on opening.
- R3 (right stick click) alternates between pages 0 and 1.
- L3 no longer changes page.
- Input during the page fade is consumed; closing and reopening starts on page 0.
- Page 1 provides eight selectable player slots and hides squad power icons.
- LB on a player power selects it; LB on another slot moves it there or swaps it with the power already there.

The project owner confirmed the ordering behavior through the LT version in game, including the personalized first page on RB, page switching, and immediate icon rendering. The new LB, feedback, and overflow behavior need separate in-game checks. The arrangement is written to the current game's plot variables and reloaded when the wheel opens; it reaches disk with the next game save. Save/quit/reload behavior has not been separately confirmed by the owner. Version 1.9 expands Shepard's displayed capacity to 16; it does not grant powers or establish general mod compatibility.

## LE2 ordering POC and startup recovery

LE2 version 0.3.2 switches pages with R3 and uses the native colored R3/LB controller-library images. LB ordering, the accepted fade, blue selection outline and First Aid counter fix remain. At the owner's request, all movie FPS/UI-speed corrections from 0.3.1 are removed; timing belongs to the game and independent mods. See [R3/color checkpoint and artifact](docs/architecture/le2-r3-color-icons-v0.3.2.md).

The new export changes only SFXGame.pcc and contains no Startup assets. If 0.3.1's movie merge was installed, its Startup edits need restoration through Mod Manager followed by reapplying desired mods; the script-only update cannot undo those asset edits. The export documents that recovery and its own backup/removal plan. Build/export do not install. New R3/icon rendering awaits owner confirmation.

LE2 version 0.3.3 synchronizes green hover after moves/swaps, hides red NotSuggested artwork behind a default-off boolean, and refreshes LB/RB/Y badges from live input assignments on both pages. Installed/vanilla-backup compilation and structural checks pass; gameplay confirmation is pending. See [hover/mapping checkpoint and export](docs/architecture/le2-hover-mapping-v0.3.3.md).

The owner reports 0.3.3 leaves badge overlays visible after closing, retains red warning artwork, and leaves gaps between help rows. Version 0.3.4 explicitly clears badges/backgrounds after close, zeros the warning clip's own alpha and dynamically packs visible help into aligned 28-pixel rows. Installed/vanilla validation passes; these corrections await gameplay confirmation. See [overlay/help checkpoint and export](docs/architecture/le2-overlay-help-v0.3.4.md).

The owner confirms 0.3.4 works very well. LE2 version 0.4 adds save-specific layout persistence using stable power identities and plot integers 7400–7416, preserving that visual baseline. It reads the loaded save rather than carrying another save's Flash cache. Installed/vanilla compilation passes; save/quit/reload confirmation is pending. See [save-ordering checkpoint and export](docs/architecture/le2-save-ordering-v0.4.md).

With local toolchain paths configured, run `scripts/Inspect-Le2.ps1`, `scripts/Build-Le2.ps1` and `scripts/Export-Le2Folder.ps1`. During recovery, `Build-Le2.ps1 -ValidationPackagePath <backup SFXGame.pcc>` validates against the backup without modifying it or the installed game.

## Development

Prerequisites: a local LE3 installation, the pinned LegendaryExplorer source checkout, .NET SDK 10.0.401 and .NET 8 runtime, PowerShell, and ME3Tweaks Mod Manager 9.2.1.137. Copy `local.settings.example.ps1` to ignored `local.settings.ps1`, set verified local paths, then dot-source it. Run `scripts/Build-ResearchTool.ps1`, `scripts/Inspect-Le3.ps1`, `scripts/Build-Le3.ps1`, and `scripts/Export-Le3Folder.ps1`. The build validates four function replacements and the wheel's `Update` override, then creates `build/LE3/MergeMods/EnhancedPowerWheel.m3m`; export creates an import folder under `dist/`. Neither command installs anything. See [toolchain research](docs/research/toolchain.md) and [ordering implementation](docs/architecture/ordering-poc.md).

## Status

Version 0.7 is the first owner-confirmed ordering checkpoint. Its merge artifact has SHA256 `43BE9E7783774FDD70D812712882A5D2291AB3422B4BD287C3F17B185C722991`. The Git tag `checkpoint/le3-ordering-v0.7` marks the source and documentation baseline. See [ordering POC](docs/architecture/ordering-poc.md) and [LE3 findings](docs/research/le3-power-wheel.md).

## Rights

Mass Effect and its game assets belong to Electronic Arts and BioWare. This independent fan project is not affiliated with or endorsed by them. Do not redistribute extracted game packages or assets from this repository.
