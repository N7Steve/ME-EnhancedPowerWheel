# LE3 pagination proof of concept

## Target behavior

The Power Wheel opens on vanilla page 0. R3 changes its displayed entries to an empty page 1 while leaving wheel chrome visible and disabling power activation. L3 restores page 0 through a vanilla refresh path if possible. Boundary presses do nothing. Closing resets the page state.

## Implementation gate

Before code changes, confirm the LE3 Power Wheel handler's icon lifecycle, selection state, controller input identifiers and dispatch, GFx object ownership, and a safe canonical restoration method. Prefer a focused UnrealScript Merge Mod. Do not touch quickslots, the SWF, or native code unless evidence shows they are necessary.

## Validation

Test in game that the wheel stays open, icons vanish and restore with current cooldowns, no hidden power activates, repeated navigation works, close/reopen resets, and stick clicks retain vanilla behavior outside the wheel.

## Status

Investigation pending. No POC code or in-game validation yet.
