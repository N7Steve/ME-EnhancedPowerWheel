# LE2 power-wheel research

## Confirmed from the installed package

Read-only inspection on 2026-09-30 decompiled 90 wheel class/function exports with zero failures. Installed `Game/ME2/BioGame/CookedPCConsole/SFXGame.pcc` SHA256: `BB99E7A8882EC2D1562E5276FEABC5E7AF64548A6B5E1F93BC52BC00F1C937E7`. This identifies the installed target, not a claim that it is pristine vanilla. Bulk source and metadata remain ignored in `research/local/LE2/`.

- `SFXSFHandler_PowerWheel` extends `BioSFHandler`, unlike LE3's GFx handler architecture. Its power icons are native structs, not `SFXGUIValue_PowerIcon` objects.
- `HandleInputEvent` returns void, is not an event, and uses `Super.HandleInputEvent`. LE3's bool-returning handler cannot be copied directly.
- Class defaults have eight player indices `(8,9,7,10,6,11,5,12)` and five indices for each squadmate, totalling 18 physical power icons.
- Icons have `sID`, `sPath`, `bVisible`, power/pawn references, desired/current state and a mapping struct. Defaults have empty `sID` strings. The PC handler searches `sID` for mouse events.
- `SetupPlayerPowers`, `HidePowerIconByIndex`, `SetPowerIconState`, `SetPowerIconSelected` and `SetMappingIcon` are native functions. Their declarations are confirmed; their internal implementation is not visible in UnrealScript.
- Native controller actions use A to select, X/B to map to 5/6. `SetMapText` has two mapping arguments, unlike LE3's three.
- `PWM_Powers`, `PWM_Weapons` and `PWM_PC` are distinct. The PC subclass overrides wheel visibility and calls the base implementation.

## Source-based inference

The existing panel visibility setters can hide power clips while retaining wheel chrome. Restoring existing data through native setters should preserve combat evaluation and assignments. Restricting pagination to `PWM_Powers` should leave the combined keyboard/mouse wheel on its native path. These deductions are not runtime confirmation.

## Hypotheses requiring gameplay checks

Native updates must preserve the console-only `sID` marker and keep hidden icons hidden. `HidePowerIconByIndex` must not destroy the retained power data or mapping metadata. Native player setup and state/mapping setters must redraw every originally visible icon correctly after restoration. The compiler does not establish these behaviors. See the [first POC](../architecture/le2-pagination-poc-v0.1.md) and shipped test instructions.

## Functional-page investigation (0.2)

The owner confirmed the first empty-page navigation POC works. Installed `SFXGame.pcc` now hashes to `6720B1A8C9C9632EA60921A8BFBFF5734E6AFEE984D0B63342F24F5DAFC40C0B`, identifying the owner-installed 0.1 package. Read-only LE2 movie inspection confirms existing empty-state placeholders and occupied-state frame artwork under `mainContent.Icon*.powerIconMC.sub`. The POC can reuse these assets through `BioSFPanel` without editing the SWF. The [0.2 implementation](../architecture/le2-ordering-poc-v0.2.md) records the exact render paths and pending runtime checks.

## Startup failure report (2026-10-01)

The owner reported startup failures with both 0.2 and 0.2.1, including a clean restoration before the latter. Removing class recompilation did not solve the crash. Two Windows Application Error reports have the same exception (`c0000005`) and native fault RVA (`0x1a73e7`). Static inspection of the matching executable snapshot places this inside a Flash string setter dereferencing its movie pointer. Both failed versions added `SetVariableString` calls to `CleanupReferences`, which vanilla calls before clearing `oPanel` during removal. This is the leading evidence-based explanation, without a full crash stack. [0.2.2](../architecture/le2-panel-lifetime-fix-v0.2.2.md) restores vanilla cleanup; The owner has subsequently confirmed that 0.2.2 works. Its reported remaining First Aid counter artifact is addressed by [0.2.3](../architecture/le2-charge-counter-fix-v0.2.3.md), pending gameplay confirmation.

## Interaction adaptation (0.3)

Local engine/SWF inspection confirms the LE2 panel invocation API, authored help font/color/spacing, and icon outline geometry. Installed Startup textures provide the native L3/LB glyphs; their HTML rendering remains to be tested in game. [0.3](../architecture/le2-interaction-poc-v0.3.md) adds a guarded inherited Update event and final UI helper for fades/selection hints, retaining vanilla cleanup and checking native property declarations after class recompilation. LB orders and L3 switches pages. New visual behavior is not yet owner-confirmed.

## UI cadence and runtime fonts (0.3.1)

The owner confirms 0.3 fade/interaction but reports accelerated wheel animation and boxed hints. Current installed wheel movies are 240 FPS, while the registered vanilla backup is 30 FPS; the controller movie differs in exactly its FPS byte. All eight localized movie copies match. [0.3.1](../architecture/le2-ui-fixes-v0.3.1.md) restores that byte for both wheel movies through a generated local asset merge, without changing gameplay clocks, and enables embedded-font/HTML hint fields. The fade script is retained byte-identical. Gameplay/rendering confirmation is pending.

## Scope correction and colored controller resources (0.3.2)

The owner assigns UI cadence to a separate mod; all EPW FPS corrections/tools are removed. Read-only shared controller SWF mapping identifies native colored R3/LB images I2E/I1F. [0.3.2](../architecture/le2-r3-color-icons-v0.3.2.md) uses those images and R3 switching, targeting only SFXGame. Historical 0.3.1 Startup edits require owner restoration/reapplication; no deployment was performed here.

## Hover and live assignment presentation (0.3.3)

The owner reports lost green hover after reordering and missing assignment badges. Local LE2 SWF confirms all badge symbols coexist in one frame and mapping backgrounds live below mainContent; native class background paths are short names. Installed SFXGame exposes the three BioPlayerInput assignment names, and Engine exposes southpaw/shoulder-swap queries. [0.3.3](../architecture/le2-hover-mapping-v0.3.3.md) reconciles hover artwork, adds optional red-warning suppression and reads live assignments for both-page badges. Installed/vanilla compilation passes. Badge field semantics and visual results remain gameplay checks; native state/selection setter internals are not visible in UnrealScript.

## Overlay lifetime and help gaps (0.3.4)

The owner reports that 0.3.3 overlays persist after close, its warning suppression is ineffective, and missing native actions leave blank help rows. SWF inspection confirms `notSuggested` is an independently tinted child and native button root paths are aliases (swapped by the input-configuration callback). [0.3.4](../architecture/le2-overlay-help-v0.3.4.md) sets the warning child alpha, explicitly clears all real mapping clips after close, and caches/restores native positions while packing visible help. Installed/vanilla compilation passes; runtime correction is pending.

## Save-specific persistence (0.4)

The owner confirms 0.3.4 works very well and explicitly requests per-save/character persistence. Installed LE2 has a dense BioGlobalVariableTable.IntVariables array and a two-argument SetInt, unlike LE3's sparse API. Save-format source corroborates dense integer serialization. [0.4](../architecture/le2-save-ordering-v0.4.md) stores sixteen identity keys plus a marker in integers 7400–7416, reads the current loaded save on redraw, and canonicalizes empty source tokens after placement. Native assignments and confirmed visual helpers remain unchanged. Installed/vanilla compilation passes; save/quit/reload and evolved-power matching remain gameplay checks.
