# LE3 ordering proof of concept

## Goal and controls

The project owner confirmed the first R3/L3 empty-page POC works in game. This iteration tests whether the existing eight player GFx positions can act as visible, selectable slots on page 1 and whether a vanilla player power can move there.

- R3 moves from page 0 to page 1; L3 returns.
- Page 0 begins with the vanilla player power arrangement.
- Page 1 shows eight empty player positions; squad power icons are hidden there.
- LT on an occupied player slot selects its power as the move source. LT on a second player slot moves it there, or swaps the powers if occupied. LT on the same slot cancels.
- A is blocked on an empty slot. X/B/Y mapping remains available only on page 0. The LT and thumb-click release events are consumed while the Power Wheel is in power mode.
- Closing the wheel discards the temporary arrangement and restores vanilla powers for the next opening. Persistence is outside this POC.

## Implementation

The same three existing script functions are replaced. No class fields, new class members, SWF edits, native hooks, or quickslot changes are introduced. `m_oPowerIndices.aPlayer` supplies the eight actual physical icon indices. A temporary 16-slot map records which vanilla source slot appears at each page/position, plus selected source and current page. The map is held in `m_aPowerIconInfo[0].Id` after the initial GFx values have been created and is cleared when the wheel closes. The default value of this descriptor's `Id` is empty. This is a POC storage choice and must be checked in game for interference with native setup or movie reinitialization.

On a page change or completed LT move, the handler calls native `SetupPlayerPowers()` to recover the vanilla player icons, snapshots their power/visual fields, then clears and repopulates the eight physical player icons according to the temporary map. Page 1 leaves cleared icons visible with `PWPS_EmptySelectable`. The squad icons are hidden on page 1 and restored on page 0. The selection guard blocks empty-slot activation, including the PC mouse-up path.

## Static validation and gameplay checks

LegendaryExplorerCore compiled all three replacements against the installed LE3 package in memory; Mod Manager serialized an M3M v1. No new runtime behavior is proven by compilation. Test in this order:

1. Confirm page 0 remains vanilla on opening and page 1 shows eight empty player slots with wheel chrome intact.
2. Select a vanilla player power with LT, press R3, hover an empty slot, then press LT. Confirm the power appears there and can be selected or activated with A.
3. Return with L3. Confirm the original slot is empty and other vanilla powers remain correctly placed.
4. Move the power back, then test LT on two occupied slots to verify swapping.
5. Repeat page switches, verify cooldown/mapped state, test empty-slot A and mouse activation, and close/reopen to verify vanilla reset.
6. Check LT/R3/L3 outside the power wheel retain their normal actions.

If page 1 slots do not receive controller hover, trace native radial selection before adding a SWF or native hook. If copied powers lose cooldowns or cannot activate, inspect which `SFXGUIValue_PowerIcon` fields native `SetupPlayerPowers()` and `SetPower()` require; the current script copies the fields exposed by LE3 but native behavior is not documented.

## Status

Built and exported for testing. The first empty-page POC is user-confirmed; this ordering iteration has not yet been tested in game or installed by this build workflow.
