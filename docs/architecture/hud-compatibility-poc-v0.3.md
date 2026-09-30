# HUD compatibility POC 0.3: startup referencer and memory evidence

Date: 2026-09-30. Owner reported both wheels absent with 0.2 and explicitly authorized live read-only memory inspection. The new 0.3 artifact passes static checks; owner runtime confirmation remains pending.

## Live evidence

Inspected PID 51096, the verified installed `MassEffect3.exe`, with only `PROCESS_QUERY_INFORMATION | PROCESS_VM_READ` (0x410). No debugger attached, injected code, remote calls, process memory writes, suspension or installed-file changes were performed.

Used LE3 name-pool/GObjects RVAs and reflected UObject/property offsets from the pinned LegendaryExplorer ScriptDebugger source. Validated the pointers with Core.TextBuffer's class/outer and decoded 178196 entries with zero object-header read failures. Heap reads were limited to the object registry, name entries, relevant object/property metadata and selected GUI/config values; no full process dump was made. Original inspection code and JSON are in ignored `research/local/LE3/HUDCompatibility/Memory/`.

Confirmed in the running game:

- HUDEnhanced's PC and console classes/defaults are resident.
- A live `SFXModHandler_HybridPowerWheel_PC_0` exists, has initialized power icons and world/player references, and is in wheel mode 1.
- Its `consolePowerWheelHandler` is null.
- No EPWHUDCompat package/class/default/instance appears in GObjects; there is no live console handler instance.
- The live SFXGUIInteraction MovieLibrary contains ConsolePowerWheel with MovieClass `EPWHUDCompat.EPWHUDConsoleWheel` and the intended HUD GFx resource.
- The live SFXEngine DynamicLoadMapping contains that class mapped to `Startup_MOD_EPWHUDCompat_INT`, but CachedObjectHandle and LoadedLinkerRoot are null.

This confirms that 0.2's configuration reached the game while the new class was unavailable. It rules out an initialized compatibility handler merely keeping its icons transparent in this snapshot. It does not distinguish never-loading from losing the class earlier in startup/GC, and the null dynamic-load cache alone does not prove a failed load call.

## Package defect and fix

HUD's real startup contains `CombinedStartupReferencer` (export 1). Our 0.1/0.2 startup omitted it entirely. The pinned LegendaryExplorer `Packages/PackageExtensions.cs` implements `CreateObjectReferencer(isStartupPackage: true)` for LE3 using that exact name and states that startup files do not work with the normal ObjectReferencer name. This required startup structure was missed in the initial builder.

0.3 creates an **original** CombinedStartupReferencer as export 1. Its ReferencedObjects retains our class and class default object. No dependency implementation or asset is copied. The builder now checks the exact name and reopens the saved package to verify both references. Dependency-export guards explicitly allow only this new original referencer in addition to the existing five original exports.

The controller subclass and Update bridge remain unchanged, as do the 0.2 config, dependency, mount and HUD Scaleform resource. The new startup structure addresses a concrete package omission consistent with the live absence; it still needs a restart and owner test to establish the causal fix.

## Artifact and validation

Export folder/ZIP stem: `dist/EPW-HUDEnhancements-Compatibility-v0.3-79E5D20216CC`.

- Startup PCC SHA256: `79E5D20216CC8EE9E29AAA6C77D5929A88DA2BEE5B20272D9F206199AA97F3FD`.
- ZIP SHA256: `85B44D2B05A9BD8CB4C0949026F1E8697B000C2B96F89A05051EDB9777DD3A1E`.
- Six original exports, with CombinedStartupReferencer first.
- Compiler, Update dispatch/import checks, saved startup-reference read-back, config serialization/preload checks and single movie replacement merge pass.
- Build hashes of inputs are unchanged. Binary artifacts and live research remain ignored.

## Retest and removal

Inspection is finished; the owner can close LE3. Back up the existing patch DLC if preserving the failed checkpoint, remove 0.2 through M3, import the 0.3 ZIP and install it with prerequisites unchanged. Do not replace files while the game is running. First check both wheel UIs, then R3/redraw/fades and ordering. If still absent, the next useful live check is whether EPWHUDCompat and a live console instance now exist.

Installation adds/replaces only the dedicated `DLC_MOD_EPWHUDCompat` folder, containing the original startup, config, mount and eight TLKs. Removing that exact patch DLC with the game closed restores HUD's registration on the next launch. No basegame merge or dependency package replacement is introduced. The shipped INSTALL.txt retains the full file/backup/removal instructions.
