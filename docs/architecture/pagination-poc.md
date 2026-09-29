# LE3 pagination proof of concept

## Target behavior

The Power Wheel opens on vanilla page 0. R3 changes its displayed entries to an empty page 1 while leaving wheel chrome visible and disabling power activation. L3 restores page 0 through a vanilla refresh path if possible. Boundary presses do nothing. Closing resets the page state.

## Compiled experiment

The Merge Mod replaces only three existing `SFXSFHandler_PowerWheel` script functions: `HandleInputEvent`, `SelectCurrentWheelItem`, and `WheelVisibilityChanged`. It introduces no class fields or new functions. Page state is inferred from the visibility flag of existing player icon index 5 while the power wheel is open. Page 1 calls `ClearIcon()` and `Hide()` on each existing icon, nulls power/pawn references, resets selection and text, and leaves the wheel chrome visible. L3 calls native `SetupPlayerPowers()` and makes the existing icons visible again. Closing from page 1 also repopulates native data before the next open.

This is deliberately an experiment. The visibility flag is used as a page marker because adding a field to a native class may affect its layout. Runtime testing must establish that native code does not independently reset the marker and that `SetupPlayerPowers()` restores all visual and gameplay state. `InitPowerIcons()` is not rerun because it appends to `m_aPowerIcons` without first clearing it.

## Validation

Test in game that the wheel stays open, icons vanish and restore with current cooldowns, no hidden power activates (including PC mouse input), repeated navigation works, close/reopen resets, and stick clicks retain vanilla behavior outside the wheel. Test with and without squadmates. Also check whether thumb clicks reach the script handler and whether a native update unexpectedly shows icons on page 1.

## Status

The project owner confirmed this first empty-page POC works in game. Its implementation has since advanced to the [LT ordering POC](ordering-poc.md), which is built but not yet gameplay-tested.
