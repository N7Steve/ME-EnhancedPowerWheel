# LE3 ordering proof of concept

## Goal and controls

The project owner confirmed the first R3/L3 empty-page POC works in game. This iteration tests whether the existing eight player GFx positions can act as visible, selectable slots on page 1 and whether a vanilla player power can move there.

- R3 moves from page 0 to page 1; L3 returns.
- Page 0 begins with the vanilla player power arrangement.
- Page 1 shows eight empty player positions; squad power icons are hidden there.
- LT on an occupied player slot selects its power as the move source. LT on a second player slot moves it there, or swaps the powers if occupied. LT on the same slot cancels.
- A is blocked on an empty slot. X/B/Y mapping remains available only on page 0. The LT and thumb-click release events are consumed while the Power Wheel is in power mode.
- Completed LT moves are stored in the current game's plot integers. Saving the game records the arrangement; reopening the wheel and loading that save restore it. Loading an older save restores that save's arrangement.

## Implementation

Four existing script functions are replaced. No class fields, new class members, SWF edits, native hooks, or quickslot changes are introduced. `m_oPowerIndices.aPlayer` supplies the eight actual physical icon indices. A 16-slot map records which vanilla source slot appears at each page/position. The selected source and current page are temporary state in `m_aPowerIconInfo[0].Id`; they are reset when the wheel closes. The default value of this descriptor's `Id` is empty.

`BioWorldInfo.GetGlobalVariables()` provides the save's `BioGlobalVariableTable`. Plot int 740200 is a version marker (2); 740201–740204 each pack four slot values as hexadecimal digits (0–7 are vanilla source positions, 15 is empty). The marker is written last. On opening, the map is accepted only if all 16 values are valid and the eight source positions each occur once. Otherwise the vanilla arrangement is used. These five plot IDs are project allocations; compatibility with other mods using the same IDs has not been established. The map refers to vanilla source **positions**, so a change in the native ordering of powers could change which power a saved position denotes.

On wheel opening, page change, or completed LT move, the handler calls native `SetupPlayerPowers()` to recover the vanilla player icons, snapshots their power/visual fields, then clears and repopulates the eight physical player icons according to the map. Empty slots receive `PWPS_EmptySelectable` through `SetState()` and each slot calls `SetStateDisplay()` immediately, instead of waiting for joystick hover. `HoverPowerIcon` does not apply the selected state to empty slots, and copied vanilla selected state is normalized. The squad icons are hidden on page 1 and restored on page 0. The selection guard blocks empty-slot activation, including the PC mouse-up path.

## Static validation and gameplay checks

LegendaryExplorerCore compiled all four replacements against the installed LE3 package in memory; Mod Manager serialized an M3M v1. No new runtime behavior is proven by compilation. Test in this order:

1. Confirm page 0 remains vanilla on opening and page 1 shows all eight empty player slots immediately, with no intermittent green outline.
2. Select a vanilla player power with LT, press R3, hover an empty slot, then press LT. Confirm the power appears there and can be selected or activated with A.
3. Return with L3. Confirm the original slot is empty and other vanilla powers remain correctly placed.
4. Move the power back, then test LT on two occupied slots to verify swapping.
5. Repeat page switches, verify cooldown/mapped state, test empty-slot A and mouse activation, and close/reopen to verify the custom arrangement remains.
6. Save, quit, reload, and verify the same arrangement. Load a different save and verify its own arrangement. Check LT/R3/L3 outside the power wheel retain their normal actions.

If page 1 slots do not receive controller hover, trace native radial selection before adding a SWF or native hook. If copied powers lose cooldowns or cannot activate, inspect which `SFXGUIValue_PowerIcon` fields native `SetupPlayerPowers()` and `SetPower()` require; the current script copies the fields exposed by LE3 but native behavior is not documented.

## Status

The user confirmed LT moves work in the previous build, and reported delayed empty-slot rendering, an occasional green outline, and reset on reopening. This revision addresses those reports and compiles, but has not yet been tested in game. Persistence reaches disk when the game itself saves; unsaved changes are not expected to survive quitting or loading an older save.
