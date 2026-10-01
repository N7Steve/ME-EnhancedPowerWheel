# LE2 ordering POC 0.2

The owner reported a pre-menu startup crash on 2026-10-01. Do not use this export. See [0.2.1 recovery](le2-startup-recovery-v0.2.1.md); the compilation checks below are historical and did not establish startup safety.

## Goal and status

The owner confirmed that 0.1's pagination works and reported the expected limitations: no icons/placeholders on page 1 and no ordering. Version 0.2 makes that second player page functional using the eight existing physical player positions twice. Compilation, class declaration checks and export verification pass; this version's gameplay remains unconfirmed.

R3 toggles pages. LT picks a hovered player power; LT at an empty position moves it, or swaps with an occupied position. Selection survives R3 navigation. LT at the same position cancels. A activates occupied powers on either page and cannot activate empty slots. Squad powers appear only on page 0 and are not reordered. L3 and the weapon/PC wheel paths retain their native behavior. Native X/B mapping remains available for occupied page-0 powers; pagination never writes input assignments or PC quickslots.

## Confirmed package/SWF evidence

The installed controller movie `GUI_SF_ME2_PowerWheel.ME2_PowerWheel` is in LE2 `Startup_INT.pcc`. Read-only SWF inspection confirms `mainContent.Icon001` through `Icon008`, their `powerIconMC.sub` state container, and all eight state names already used by the handler. Empty placeholders have their own `emptyUnselected` and `emptySelected` clips. Each occupied state has an `iconMC` with the movie's 74-frame native power artwork. `BioSFPanel.GotoFrameAndStop` is available to initialize those frames immediately. Extracted/decompiled assets remain ignored in `research/local/LE2/OrderingUI/`.

LE2's `BioSFHandler.Update(float)` is an inherited event. LegendaryExplorerCore's `UClass` serializer has virtual-function tables only for game-3 packages: LE3's table audit cannot be applied to LE2. LE2 compilation instead checks retained class/struct property declarations (names, types, static-array sizes and flags), the final refresh helper, whole-class decompilation and function round trips. These are structural checks, not a proof of runtime compatibility.

## Implementation

`EPWRefreshPage` is a final helper added to the native wheel class. It clears player data, calls native `SetupPlayerPowers`, and captures the eight original structs. It renders a logical page by copying the selected source struct into each physical destination and restoring that destination's clip paths, ID and stick boundary. No native class fields or new icon slots are introduced.

Occupied slots retain native power/pawn references, manager power IDs, names, descriptions, state and mapping metadata. Empty slots receive a clean struct and `PWPS_EmptySelectable`. Every player slot is made visible; state-child visibility and artwork are explicitly initialized before any hover. Native setters continue to handle state/selection/mapping. Player content is separate from the preserved squad-visibility snapshot, wheel ring, portraits and other wheel chrome. Cooldown/blocked-state presentation still needs runtime confirmation after moves.

Layout state lives in custom panel variables, rather than a borrowed native icon ID: a 16-character permutation of the eight original source indices and empty positions, current page, selected absolute position, native source signature, squad visibility and pending-redraw flag. Duplicate/missing/invalid source indices reset to native order. A changed native source signature resets the layout instead of applying stale indices to different powers.

The `Update` override calls `Super.Update` and handles the pending opening redraw after native setup. Existing `HandleInputEvent`, `SelectCurrentWheelItem`, `HoverPowerIcon`, `WheelVisibilityChanged` and `CleanupReferences` are replaced. Closing restores native source data before normal hiding and cancels selection, while retaining the panel layout for reopening. Session/panel cleanup resets it. This recompiles the handler class and requires separate checks for other mods editing it; no Dynamic Time Wheels dependency or gameplay-system edit is introduced.

## Deliberate limits

This milestone provides sixteen destinations for the original eight native player entries; it does not collect additional powers beyond that source limit. The order survives wheel close/reopen within the GUI session, but is not written into save data. Changes in the native source ordering reset it. Save persistence, overflow, fades and combo outlines remain separate milestones. The placement-help string is currently Spanish.

## Validation and artifact

- Research tool builds with zero warnings/errors. Both new functions and all five replacements compile against the installed LE2 package and decompile successfully.
- Only the explicitly recompiled wheel class changes class export data. Class/struct property declarations remain unchanged; `EPWRefreshPage` is final.
- M3M v1 embedded game/package/member targets and every script exactly match authored source. Export hash matches build hash.
- Installed LE2 package SHA256 before and after build: `6720B1A8C9C9632EA60921A8BFBFF5734E6AFEE984D0B63342F24F5DAFC40C0B` (owner-installed 0.1 target, not pristine vanilla).
- M3M SHA256: `D2FA2604C40790B2CB38606CB9E0EB11B843AE2BDF293075D15D6C642B94DBAC`.
- Export: `dist/EnhancedPowerWheel-LE2-OrderingPOC-v0.2-D2FA2604C407`. The 0.1 export is preserved. Nothing was installed by build/export.

The validator now follows Core's documented requirement to call `FileLib.ReInitializeFile` between compilation mutations. Previously cached field links could falsely report a class-chain loop and hide newly added symbols. Refreshing the cache fixes the LE2 validation and the earlier LE3 validation failure; the complete LE3 1.9.9 merge now also passes its existing virtual-inheritance audit without LE3 source changes.

## Owner validation and rollback

Import the new folder into Mod Manager with LE2 closed and a verified restorable LE2 basegame backup. The only installed-file change is `Game/ME2/BioGame/CookedPCConsole/SFXGame.pcc`; the modified/added functions and full backup/removal plan are listed in `INSTALL.txt`. Uninstall by restoring the manager's backup and reapplying other desired basegame mods.

First verify eight placeholders on page 1 without joystick movement. Then pick a player power with LT, switch with R3, place it on page 1 with LT, activate it with A, and confirm its old slot is empty and cannot activate. Check swaps in both directions, canceling selection, close/reopen from either page, current hover, correct power text/artwork/cooldowns/badges, no squadmates, and unchanged weapon/PC wheel behavior and assignments. Opening must display the session's personalized page 0. Loading a new session is expected to reset order in this version.
