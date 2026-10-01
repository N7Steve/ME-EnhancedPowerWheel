# LE2 R3 and native color icons 0.3.2

## Corrected scope

The owner reports that 0.3.1 reads correctly but uses gray button artwork, and asks for R3 page switching plus colored icons. They explicitly clarify that UI slowdown belongs to a separate mod and ask to remove all EPW speed corrections. Version 0.3.1's FPS asset merge is retired. EPW no longer owns or changes movie cadence.

The active movie manifest, FPS builder/checker, generated-package helper and CLI entry were removed. Build/export again produce only the script merge targeting SFXGame.pcc. No Startup resources, movie FPS, world/time dilation or other UI clocks are changed. Prior local test artifacts remain ignored historical evidence.

The original 0.3 page fade retains its alpha-only Update and duration, as requested. It is a page-content effect, with no movie-clock compensation. The native cleanup and First Aid counter correction remain.

## Confirmed source mapping and changes

Read-only extraction of the installed `GUI_SF_Xbox_ControllerIcons.Xbox_ControllerIcons` identifies these authored exports and their image resources:

- `xboxRStickPress` -> `Xbox_ControllerIcons_I2E.tga` -> native texture `GUI_SF_Xbox_ControllerIcons.Xbox_ControllerIcons_I2E`.
- `xboxLBumper` -> `Xbox_ControllerIcons_I1F.tga` -> native texture `GUI_SF_Xbox_ControllerIcons.Xbox_ControllerIcons_I1F`.

These are the shared controller library used by vanilla colored wheel controls. The tooltip now references them rather than the gray `GUI_GlobalIcons.Buttons` variants. No texture/SWF is included in this export. Embedded-font/HTML text, shadow, native-help alignment and English/Spanish label selection from 0.3.1 are retained. Actual rendering remains an owner check.

Physical R3 begins the page fade and its release is consumed. LB still picks, places, swaps and cancels. Physical L3 returns to its inherited behavior. The negative L3 sentinel remains an internal redraw implementation detail; the fade midpoint uses that same existing redraw path.

## Validation and artifact

The current installed package compiles/round-trips all replacements and the two existing added members. Native wheel class/struct property declarations remain unchanged; the UI helper is final. Embedded scripts match the manifest. The M3M has one target (`SFXGame.pcc`), no asset operations and zero embedded asset packages. The exported folder contains only the script merge, descriptor and installation notes. The Update/fade source is byte-identical to 0.3.1.

Export: `dist/EnhancedPowerWheel-LE2-R3ColorIcons-v0.3.2-CD6CD6E145A6`.

M3M SHA256: `CD6CD6E145A6DFE5975A2A90386608D7A93A0EDCBF60F39C92FE56508EEB3A6D`.

Build/export do not install. This version changes only `Game/ME2/BioGame/CookedPCConsole/SFXGame.pcc`. Keep the registered vanilla backup and installed-mod order; install through Mod Manager with LE2 closed. Removal restores SFXGame through Mod Manager and reapplies desired mods.

## Retired 0.3.1 movie edits and owner test

A script-only merge does not undo previously installed Startup asset changes. To remove the correction from an already installed 0.3.1, restore its eight `Startup_DEU/ESN/FRA/INT/ITA/JPN/POL/RUS.pcc` files through Mod Manager using the verified basegame backup, then reapply desired mods that own those resources, including the independent time/UI mod. Do not restore SFXGame after installing EPW unless reinstalling EPW as well. No installed file was changed by this work; these are owner actions documented in `INSTALL.txt`.

Check R3 page switching, L3 native behavior, colored R3/LB hint art and native hint spacing. Recheck the accepted fade, LB pick/placement sound, blue outline, both-page moves/swaps and First Aid counter. UI speed is managed separately and this version makes no cadence claim. New button rendering and R3 behavior await owner confirmation.
