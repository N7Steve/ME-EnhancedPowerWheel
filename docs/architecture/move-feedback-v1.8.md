# LE3 move feedback v1.8

## Confirmed from the installed LE3 scripts

- `BioPlayerInput` binds the left bumper to `BIOGUI_EVENT_BUTTON_LB` and `BIOGUI_EVENT_BUTTON_LB_RELEASE`; LT has separate events. The wheel's vanilla `HandleInputEvent` forwards events it does not handle to its superclass.
- The installed wheel already uses `PlayGuiSound('HUDPowerWheelQueueingHighlightedPowerForActivation')` when queuing a power, and `PlayGuiSound('HUDWeaponPadNewHighlight')` when highlighting a weapon. Both are existing GUI sound identifiers; the mix and duration of their use for moving powers need an in-game check.
- The icon border can be traced in a child movie clip with the same coordinates as the existing red and violet combo outlines. The project already uses this method for those outlines.

## Change

- LB picks an occupied player slot, then moves its power to an empty slot or swaps it with an occupied slot on either page. LB on the same slot cancels. LT and its release are no longer intercepted by the move feature.
- The picked slot gets a solid green outline, drawn in its own clip at depth 102. The existing combo outlines remain at depths 100 and 101. The green outline follows the logical selected slot through page switches and disappears on placement or cancellation.
- Picking plays the existing power queue cue; a completed move plays the existing weapon highlight cue. A move to the same slot is a cancellation and makes no confirmation sound.
- On a completed move, the redraw retains `m_nCurrentPowerIconIndex` and `m_fLastProcessedStickAngle` and restores the current icon's hover display. Page switches still clear hover and reset the stick angle. This targets the observed upward selection jump after placement.
- The 16-slot plot map and its save behavior are unchanged. Build and export do not install into the game.

The installed-package validation compiled all eight merge members and Mod Manager produced an M3M v1. The exported folder is `dist/EnhancedPowerWheel-LE3-MoveFeedback-v1.8-6B045824938D`; its M3M SHA256 is `6B045824938D07D1AB43A52F54B2097E98DAC166C8BD01D8EF4104BCF42A8F92`. This proves syntax and export integrity, not the controller feel in game.

## Inference and test needed

The forced `LeavePowerIcon()` plus `m_fLastProcessedStickAngle = -1.0` on every redraw likely caused the selection to return to the top and then reprocess the held stick after a move. This source-based explanation is not yet confirmed by an in-game retest. The reused icon clips and native stick handling could also contribute.

Test LB pick, cancellation, same-page move, cross-page move, and occupied-slot swap. Watch the selected icon and the radial selection marker while holding the stick at the destination. Verify the green outline stays on the picked power during hover and page changes, then clears after placement. Listen for distinct pick and place sounds and check LT retains its vanilla behavior. Confirm quickslots, power activation, fade, and combo outlines still work. Save/quit/reload remains separately unreported.
