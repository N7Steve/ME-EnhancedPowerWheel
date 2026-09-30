# Help drift and hover fixes, version 1.9.5

## Owner-reported behavior and source-based diagnosis

The owner confirmed better action-icon spacing in 1.9.4, but reported contextual text continuously moving right and powers disappearing when hovering a `NotSuggested` power.

The 1.9.4 layout reread native text `_x` and rewrote it through `SetPosition` every update while changing Y. This unnecessary horizontal feedback is a plausible cause of the reported drift; the exact native coordinate conversion has not been independently instrumented. The correction eliminates horizontal writes to native action fields entirely.

Warning suppression previously showed a normal or selected substitute clip by changing visibility only. Native hover can change the current/desired state while the previous substitute remains recorded. Cleanup then hid that substitute even when it had become the real current state, and depended on a native display refresh to restore visibility. A separate possible contributor is artwork not initialized in the substitute's loader. Local wheel SWF inspection confirms the state `iconMC` instances use the exported `PowerIconLoader`, whose inherited `SetIcon(sResource, nIcon)` function initializes its resource and frame. These source findings explain the two corrections without claiming live tracing of the owner-reported failure.

## Changes

- Native action text/buttons are moved/restored with an `ASDisplayInfo` that enables only `hasY`. Original Y coordinates come from `GetDisplayInfo`, the matching API. The 28-pixel baseline interval and empty-row compaction remain.
- Custom switch text/icon positions use the template/button's `GetDisplayInfo` coordinates and the same setter, avoiding `_x` read/write feedback.
- Warning suppression covers current `NotSuggested` and normal/selected states transitioning toward that desired state. Native cooldown, activation and overload precedence remains unchanged.
- On a substitute change, its authored `iconMC.SetIcon` is initialized from the power icon's existing resource and frame. Cleanup no longer hides a substitute that is now the real current state and explicitly restores the current clip for occupied visible slots.
- The optional `bShowNotSuggested = FALSE` default remains the single reversible presentation policy. No grey tint or gameplay rule change is introduced.

## Validation and export

All manifest functions compiled against the installed LE3 package. Base/PC virtual inheritance passed (110/110), all EPW helpers remain final, and `git diff --check` passed. Build/export did not install anything. The installed `SFXGame.pcc` hash was unchanged before and after: `97A2D9A486C5D1F853A90CB130FA34B10830ED9366B9443A3F14A5945F9182DD`.

Reproduce with `scripts/Build-Le3.ps1` and `scripts/Export-Le3Folder.ps1`. Export: `dist/EnhancedPowerWheel-LE3-WheelFix-v1.9.5-E6B078049379/`. Files: `moddesc.ini` and `MergeMods/EnhancedPowerWheel.m3m`. M3M SHA256: `E6B078049379D8A95E4C50782F622161E7908D6953DC053C76C076B879A0A7CB`.

The owner performs installation and game validation. The only merge target is `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc`. Verify Mod Manager's basegame backup and record existing mods first; uninstall by restoring that backup and reapplying desired mods. See [toolchain research](../research/toolchain.md).

Pending checks: leave the wheel open for at least 30 seconds with each action count and confirm text X remains stable; repeatedly hover/leave First Aid and active ammo powers; switch away/back with a warning power hovered; check normal, warning, cooldown and empty slots through move/swap and close/reopen. Spacing, sound and reversible suppression should retain their previous behavior. The fixes are compiler-validated and await in-game confirmation.
