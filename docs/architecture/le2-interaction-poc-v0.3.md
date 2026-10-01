# LE2 interaction POC 0.3

## Scope and accepted baseline

The owner accepted 0.2.3 after its First Aid charge-counter correction and requested LE3-style interaction: LB ordering, the power-selection sound on pick, fading page transitions, game-icon L3/LB hints below vanilla help, and a blue outline around the power picked for moving.

The preserved 0.2.3 export remains `dist/EnhancedPowerWheel-LE2-ChargeCounterFix-v0.2.3-F71CC5FCF6BC`, M3M SHA256 `F71CC5FCF6BCDBD43F1A353EEB5DBE9D230652987B067C9BF0D3D9E224CB7762`. Detailed counter edge cases were not separately reported. Its source snapshot is ignored local research.

## Confirmed local evidence

LE2 `BioSFSharedBase` declares L3/LB input events and their release events, plus `ASParams` and its string/integer/float argument types. `BioSFPanel` exposes native `InvokeMethodArgs`, variable accessors and visibility setters, allowing runtime Flash text fields and vector clips without altering a SWF.

Installed `Startup_INT.pcc` contains native textures `GUI_GlobalIcons.Buttons.Xbox_Btn_L3` and `GUI_GlobalIcons.Buttons.XBox_Btn_LB`. These exact references are used in HTML image tags; no replacement controller artwork or button-name text is shipped. The HTML image loading technique is adapted from the LE3 hint implementation. Rendering these LE2 texture references still requires the owner's in-game check.

The LE2 wheel SWF's authored help text uses `AeroLight Shared`, size 16, color `#ffb47b`. Its vanilla action baselines are spaced roughly 26-28 pixels, and Use is the bottom action. The added rows use those font/color values, native text/button X positions, and the Use baseline plus 28/56 pixels. Vanilla action rows are retained.

The selectable icon's native shape 97 starts at (-37, -6.45), curves through (-10.2, -11.25) to (16.65, -4.95), and follows the same clipped-corner lower polygon used by LE3. The blue runtime outline follows that authored geometry, with a 2.2-pixel line in `#38acff`.

The matching LE2 executable contains the native wheel cue names `HUDPowerWheelChangeHighlightedPower`, `HUDPowerWheelMapOnePower` and `HUDPowerWheelQueueingHighlightedPowerForActivation`. Pick uses the activation-selection cue, matching LE3; placement retains MapOnePower.

## Implementation

L3 toggles between pages 0 and 1; LB picks, places, swaps or cancels on the same position. Negative L3 remains an internal redraw sentinel. R3 and LT no longer perform EPW actions. The old LT/R3 text injected into vanilla Use help is removed.

The page transition fades power clips and their mapping icon/background clips at 600 alpha units per second, matching LE3's approximately 167 ms out / 167 ms in. Page data switches at zero alpha. Portraits, the ring and vignette are excluded. Repeated page/order/activation inputs are ignored until the transition ends; inherited close/back/menu input still passes through. Closing or opening resets fade alpha, phase and page 0.

`EPWUpdateUI` creates two help rows below vanilla actions, using native button textures and labels “Alternar rueda” / “Reordenar poder”, changing the second to “Colocar / Intercambiar” while a power is picked. Labels are currently Spanish. It creates a separate blue outline at the icon-state container, so hover/state changes do not remove the picked marker. The marker is visible only for the selected absolute slot on the displayed page; placement, cancellation and closing clear it.

The merge adds final helper `EPWUpdateUI` and an inherited `Update` event to `SFXSFHandler_PowerWheel`, recompiling that class. No native fields or structs are added or changed. `Update` preserves `Super.Update`, checks panel initialization/removal and the active controller/power mode, and runs custom work only while the wheel is open. `CleanupReferences` remains the vanilla body, with no Flash calls during teardown. The earlier startup bug correction and charge-counter redraw are retained.

No save writes, source-capacity expansion, quickslot edits or Dynamic Time Wheels dependency are introduced. Native class recompilation means mods changing this handler require a separate compatibility check. Runtime behavior of this new callback is not established merely by compilation.

## Validation and export

Compilation/round-trip passes against both the installed owner-test package and the registered vanilla backup. All wheel class/struct property declarations remain identical; the EPW helper is final. Only the explicitly targeted wheel class is permitted to change class export data. The M3M assertion checks all existing-function and class-member embedded sources against the manifest.

The unchanged `CleanupReferences` source matches vanilla after whitespace normalization. The generated build/export does not modify installed files.

Export: `dist/EnhancedPowerWheel-LE2-InteractionPOC-v0.3-8B7DA16FE74E`.

M3M SHA256: `8B7DA16FE74EAB57D34706AFD7AB7712E792C319CC42ECA20C47E2BB9B16E6E0`.

## Deployment and owner validation

Import/install through Mod Manager with LE2 closed. A working 0.2.2/0.2.3 installation can receive this merge. Keep the registered vanilla backup at `Y:/Mass Effect/Backups/LE2`, record other installed mods and copy a test save. Failing 0.2/0.2.1 installations still require restoration first. The only game file changed is `Game/ME2/BioGame/CookedPCConsole/SFXGame.pcc`; `INSTALL.txt` lists the five replaced functions and the two added members. Removal restores the verified LE2 basegame backup and reapplies desired mods.

Check startup first. Then verify native L3/LB glyphs and spacing below vanilla help, the pick sound vs normal power selection, the unchanged placement sound, blue outline persistence while hovering other powers, cancellation, moves/swaps across pages, and fade appearance. Close during each fade phase and reopen to check normal alpha/page 0. Recheck First Aid counts, activation on both pages, empty-slot safety, weapon/PC controls, aspect ratios and UI scale. The owner subsequently confirmed the interactions and fade, reporting accelerated UI cadence and boxed tooltip text. See [0.3.1](le2-ui-fixes-v0.3.1.md).
