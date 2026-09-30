# Dynamic help and arrow continuity, version 1.9.3

## Confirmed local evidence

The owner reported improvement with 1.9.2, then requested a controller icon and dynamic positioning within the help list, a different page-switch sound, and a fix for the selector arrow jumping through the top when switching pages.

Read-only inspection of the installed LE3 package confirmed that `SFXSFHandler_AreaMap.Initialize` uses `BrowserSelectMenu` when opening outside the browser wheel. The installed controller defaults associate the R3 token with `BIOA_ControllerIcons_XBOX.xbox_R_press`, and that texture exists in `Startup.pcc`. Local wheel ActionScript uses the `img://` resource prefix. Existing help text uses the shared AeroLight font and separate button icons; authored help rows are roughly 26 Flash pixels apart. Decompiled/extracted assets remain ignored in `research/local/`.

## Implementation and source-based expectations

`EPWUpdateSwitchHint` now creates separate icon and text fields under the wheel. Its label is `Alternar rueda` for Spanish profile codes and `Switch wheel` otherwise. The icon references the installed R3 texture through HTML image markup, rather than redistributing an asset. The label aligns to the native text column and the icon to the button column. On each update after `Super.Update`, it follows the lowest nonempty use/map action row with the native row spacing; empty actions do not reserve space. When no actions are shown, it uses the use-row position. Text is changed only when the localized label changes. The row hides on close or outside power mode.

This is a script addition to the existing help list, not an SWF replacement or a change to quickslot assignment. Actual HTML texture rendering, icon baseline, clipping, and dynamic positioning need an in-game check; the existing native help layout still determines the positions that the new row follows.

Page changes now use `BrowserSelectMenu`; pick/place retain their shared cue. Internal redraws remain silent. At the fade midpoint, the input handler recognizes a page redraw by the existing transition suffix, retains the hovered physical player slot, refreshes its new power/text without a hover sound, and avoids setting `m_fLastProcessedStickAngle` to `-1`. First-open behavior retains its existing forced redraw. If the previous hover was a squad icon, normal leave behavior clears that hover while the stick angle remains intact. The handler also keeps accepting joystick axis values during the fade while consuming action buttons, so stick releases and motion are not lost during transitions.

The arrow continuity correction removes the explicit source-level angle reset identified during inspection. Native wheel processing remains in `Super.Update`; the visible result still needs owner confirmation. No broad native behavior or mod compatibility claims are implied.

## Validation and export

All manifest functions compiled against the current installed `SFXGame.pcc`. Virtual inheritance validation passed (base/PC 110/110), and all EPW helpers remained final and outside the virtual table. `git diff --check` passed. Build/export did not modify the installed package: SHA256 stayed `A85A82599401BD00AA2AF46E43742AEF0744FCA052E251ACB95E981A73646AED`.

Reproduce with `scripts/Build-Le3.ps1`, then `scripts/Export-Le3Folder.ps1`. Export folder: `dist/EnhancedPowerWheel-LE3-WheelHelp-v1.9.3-A75EFD140B1E/`. Exported M3M SHA256: `A75EFD140B1E359C720CA27D729E8CAAFBDDC3E4307AF88A2788169E1024D140`. Contents: `moddesc.ini` and `MergeMods/EnhancedPowerWheel.m3m`. No installation performed.

If installed by the owner, the merge targets only `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc`. Verify Mod Manager's basegame backup and record existing mods before installation; uninstall by restoring that backup and reapplying desired mods. See [toolchain research](../research/toolchain.md).

Check both languages, no hover, empty and occupied slots, squad hover, and differing numbers of assignment actions. Listen for the menu cue on both switch directions. Hold the joystick at several angles while alternating R3, move/release it during the fade, and check the selector stays continuous. Also check LB moves across pages, first-open layout, and close/reopen during a fade.
