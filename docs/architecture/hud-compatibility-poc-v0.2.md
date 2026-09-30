# HUD compatibility POC 0.2: explicit runtime loading

Date: 2026-09-30. Owner reported no UI for either power or weapon wheel with 0.1. Version 0.1 is retired. Version 0.2 is compiled/exported but has not been validated in game.

Follow-up: the owner reported the same failure with 0.2. Read-only memory inspection found the configured class absent and identified a missing CombinedStartupReferencer in the generated startup. Version 0.2 is retired; see [POC 0.3 and runtime evidence](hud-compatibility-poc-v0.3.md).

## Evidence and hypothesis

Read-only inspection confirmed the installed 0.1 DLC and HUD startup packages are present. The installed patch config replaces ConsolePowerWheel with the compatibility class as intended. Both startup packages have `RequireImportsAlreadyLoaded`; the compatibility subclass imports HUD's console handler and its defaults/visibility function.

The 0.1 resolver checks used LegendaryExplorer's custom file resolver and import hints. Those are tooling metadata and are not a runtime class-loading route. Its config provided only `dlcstartuppackage` and a seek-free path. This is a gap in the runtime checks, not proof of the exact failure.

As a local comparison, Journal Enhanced's library config explicitly registers `dlcstartuppackagename` and startup files in `Engine.StartupPackages.Package`. Existing HUD config demonstrates SFXEngine's `dynamicloadmapping` format. This revision applies those runtime registration mechanisms to our original subclass without copying dependency assets.

Hypothesis: the new handler is not available when ConsolePowerWheel is instantiated, or its HUD dependency is unavailable when its startup loads. Loss of both wheels is consistent with a failure at their shared movie/handler layer. There is no game trace confirming that explanation yet; class initialization and native behavior remain alternatives if 0.2 also fails.

## Changes and validation

Only compatibility config/version change. The UnrealScript bridge and startup PCC remain identical to 0.1:

- `dlcstartuppackagename = Startup_MOD_EPWHUDCompat_INT`.
- Explicit Package preload sequence: HUD startup, then compatibility startup.
- DynamicLoadMapping from `EPWHUDCompat.EPWHUDConsoleWheel` to `Startup_MOD_EPWHUDCompat_INT`.
- Same single ConsolePowerWheel replacement, same HUD SWF, same mount 5088.

Compilation, import resolution, saved-package read-back and the single-movie replacement checks pass. New round-trip checks verify the preload order and class mapping survive coalesced serialization. Inputs are hashed before and after building; no installed files are saved. The current installed SFXGame hash is `D4BE0CC889BCC038F72FCD2F75EDB94733F8E4D6593362876F5407374ECCF433`; the installed 0.1 config remains `70B0335AF846C21A72E082F2348A520F60A23B49752669528A6F96062EE63EEB`.

Export: `dist/EPW-HUDEnhancements-Compatibility-v0.2-POC-21CDD1729138.zip`.

- ZIP SHA256: `C3DA7F743BEC58F109F1CD67AB1C68ADC546F43F16964449A8B24178EDFAE9E7`.
- Startup SHA256 unchanged: `21CDD17291383D9EAE18E01061AB06E4FDEFE225717A58A89F31589BD0B0A59A`.
- All payload hashes and current dependency hashes are in exported `build-evidence.json`.

## Replace and test

Close LE3. Back up the existing `DLC_MOD_EPWHUDCompat` folder if retaining the failed checkpoint is useful. Remove 0.1 through Mod Manager's installed DLC management, import the 0.2 ZIP, and install it with HUD Enhancements and EPW still present. The new patch installs only the same dedicated compatibility DLC folder. See the shipped INSTALL.txt and 0.1 document for exact files and removal; no basegame or HUD package replacement is introduced.

First test whether **both wheels appear**. Only then test saved page 0, R3/fades and move/swap. Do not claim the loading hypothesis confirmed until the owner reports the result. If both wheels remain absent, stop treating static resolution as runtime proof and obtain runtime evidence or build a controlled alternative that avoids the new handler registration.
