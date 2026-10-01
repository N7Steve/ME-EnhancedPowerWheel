# LE2 hover and assignment artwork 0.3.3

Subsequent owner feedback: badge overlays remain visible after close and red warning artwork remains visible, especially on hover. These presentation fixes were not successful in game; see [0.3.4](le2-overlay-help-v0.3.4.md) for the follow-up. The 0.3.3 export is preserved as historical evidence.

## Report and scope

The owner reports that a moved/swapped power loses its green hover appearance until the stick leaves and returns, requests removal of the red NotSuggested overlay behind a simple future configuration switch, and reports missing LB/RB/Y assignment badges. This checkpoint changes presentation only. Native mapping actions, controller assignments, power evaluation and activation remain unchanged.

## Confirmed local evidence

Read-only inspection of installed LE2 SFXGame identifies `BioPlayerInput.m_nmMappedPower`, `m_nmMappedPower2`, and `m_nmMappedPower3`, and SFXPower's Class/PowerName identity. Installed SFXGame SHA256 at inspection/build: `BD0D070414F9206B30CC1BB20E6BB5BC2D2F72C61494A8A033D683C1926AFDE6`. Engine exposes `BioSFManager.IsTriggerSouthpaw` and `IsTriggerShoulderSwapped`.

The locally extracted LE2 controller wheel has a one-frame mapping sprite (254) containing all eight named symbols: Y, X, LDpad, RDpad, LB, RB, LT and RT. Changing timeline labels cannot select these independently. The native class supplies the corresponding `m_aMappingIconPaths`. The mapping backgrounds are children of mainContent, while `sMappedBGPath` stores only their short names. The previous script used these short names directly for visibility/alpha.

The existing rebuild resets every state clip to the source display state before invoking HoverPowerIcon. Native SetPowerIconSelected and SetPowerIconState implementations are unavailable in UnrealScript; LeavePowerIcon does reset the current index. A claim that HoverPowerIcon's same-index guard causes this bug is therefore unsupported.

## Implementation and source-based inference

`EPWUpdateSuggestedDisplay` reapplies the existing selected/selectable artwork according to native `bSelected`, after hover and during the initialized open panel's UI update. This explicitly reconciles Flash presentation after rebuild, including a stationary stick. All eight authored state visibilities are synchronized; inactive, activated, overload and empty states retain their native states. The expected fix for the owner-reported mismatch requires gameplay confirmation.

The helper's optional `bShowNotSuggested = FALSE` is the single switch. FALSE substitutes selected/selectable artwork for the NotSuggested state; TRUE restores the native warning state. It changes no native evaluation, desired-state fields or activation rules. The substitution covers both Shepard and squad icons. Native descriptive warning text is retained.

`EPWRefreshMappingIcons` reads live BioPlayerInput assignments instead of trusting metadata from the isolated SetupPlayerPowers rebuild. It matches power class name or PowerName, assigns GUI-only metadata, and toggles the eight named badge children. Shoulder sides honor southpaw and shoulder/trigger swapping through LE2's manager. The assignment-field interpretation follows the existing LE3 implementation and LE2 native mapping-text conventions; actual LB/RB/Y identity and alternate-layout rendering remain runtime checks.

Refresh runs before restored hover text and in the existing open-panel UI update, so both pages, moves/swaps, close/reopen and native reassignment are covered. Empty/unassigned slots hide their badges. Background visibility and fade/reset now address `mainContent.<sMappedBGPath>`. Fade speed, ring, vignette and portraits are unchanged. The final helpers precede their callers in the manifest to support sequential compilation. No native fields/structs or quickslots change.

## Validation and export

All members and replacements compile/round-trip against the current installed package and registered vanilla backup. Class/struct property declarations are unchanged, all EPW helpers are final, and only the explicitly targeted class changes class export data. Build checks the installed SFXGame hash remains unchanged and verifies embedded scripts against the source manifest. `git diff --check` passes.

Export: `dist/EnhancedPowerWheel-LE2-HoverMapping-v0.3.3-E2D5D1297702`.

M3M SHA256: `E2D5D129770291417654B37955291E875A442F25E8914337EC9FA65A9D6A9AE9`.

Build/export do not install. The exported INSTALL.txt lists the sole deployment target (`Game/ME2/BioGame/CookedPCConsole/SFXGame.pcc`), backup requirements, recovery from historical 0.3.1 Startup edits and removal through Mod Manager with desired mods reapplied. Class recompilation still requires separate compatibility checks for mods editing this handler.

## Owner checks still required

Hold the stick still after placing/swapping into occupied and empty slots on either page: the destination should keep green hover immediately. Check cancel and subsequent leave/rehover, the blue pick outline and First Aid counter. Verify LB/RB/Y badges follow their powers across moves, pages and close/reopen, clear from old/empty positions, and respond to native X/B reassignment. Check southpaw/swapped layouts. Against resistant targets, check red artwork is absent on Shepard and squad, while cooldown/unavailable/activated visuals and activation behavior stay intact. Rebuild with the boolean TRUE to check restoration of native warning artwork. In-game results are not yet confirmed.
