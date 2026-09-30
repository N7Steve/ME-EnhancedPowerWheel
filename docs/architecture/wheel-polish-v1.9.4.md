# Wheel polish, version 1.9.4

## Confirmed evidence

The owner's screenshot shows an empty gap between contextual actions, a weaker outline on `Switch wheel`, and the wheel's warning presentation. The owner reported that warning powers become blue after switching away and back until hovered. The subsequent instruction supersedes the requested grey appearance: hide `NotSuggested` in this release and keep that decision easy to reverse.

Read-only extraction of the installed `Startup.pcc` confirmed that `GUI_SF_MainWheel.MainWheel` calls `BrowserSegmentChange` in its `SelectSegment` function when moving to a different pause-menu segment. This is the sound now used for accepted R3 page changes. It replaces the menu-open sound chosen in 1.9.3. Pick/place sounds remain unchanged.

The installed power icon enum includes `PWPS_NotSuggested`. Local wheel SWF inspection shows a separate `notSuggested` clip with an unnamed arrow; `selectable` and `selected` already contain normal power artwork. The native action text uses AeroLight Shared, size 20, and a dark glow with RGB `062031`, blur 2 by 2, strength 10 and one pass. Extracted assets and ActionScript remain in ignored local research.

## Presentation option

`EPWUpdateSuggestedDisplay(optional bool bShowNotSuggested = FALSE)` is the single policy switch. Change its default to `TRUE` and rebuild/export to restore native warning presentation; future installation variants can instead supply a flag. This release does not yet expose an installer option.

The helper leaves `eState`, `eDesiredState`, native power evaluation and activation untouched. While a visible real power is in `NotSuggested`, it hides that clip and displays its normal selectable/selected clip. It restores native display when the logical state changes or suppression is disabled. No grey tint, altered power availability, or new evaluator is included. Cooldown, activation, overload and empty states remain native.

The helper runs after page rebuilding and during the wheel's update so hover is not required to suppress the warning presentation. Two transient GFx properties record the visual state for existing combo and move outlines; they do not change class layout or save data. This hides the warning consistently rather than claiming to repair the underlying native recommendation evaluation.

## Contextual help

Visible map/use actions and the switch action are packed in native top-to-bottom order using one 28-pixel baseline interval, with empty rows omitted. Button positions retain their original offset from their text. Authored native Y positions are cached and restored on close or outside power mode. Text, mapping operations and quickslot assignments are unchanged.

The switch label retains the shared font and recreates the authored outline explicitly through a `GlowFilter`; merely copying the existing static filter array did not match the owner's screenshot. The R3 image uses the same font metrics around its HTML image. Matching runtime rendering of that filter still needs an in-game check.

The screenshot also contains Spanish action text with an English switch label. In addition to Spanish profile codes, the helper recognizes the visible Spanish action strings and remembers that choice when no actions are shown. This supports Spanish text replacements that leave the profile language at INT; that cause is a source-based hypothesis, not a confirmed account of the owner's language setup.

## Validation and deployment

All manifest functions compiled against the installed LE3 package. Virtual inheritance validation passed (base/PC 110/110); all EPW helpers remain final and outside the virtual table. `git diff --check` passed. Build/export performed no installation. The installed package's SHA256 after the build was `F5CCD2BFC7A8302E61C3035293EFC74F2BFC8B9924F731F81AF356DACA8E9385`.

Reproduce using `scripts/Build-Le3.ps1` followed by `scripts/Export-Le3Folder.ps1`. Export: `dist/EnhancedPowerWheel-LE3-WheelPolish-v1.9.4-3D83B2B88B29/`. Contents: `moddesc.ini` and `MergeMods/EnhancedPowerWheel.m3m`. M3M SHA256: `3D83B2B88B29A75018E047FC45D6CF108B812AB46B3341496E24F439B24A9884`.

If installed by the owner, only `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc` is a merge target. Verify Mod Manager's basegame backup and record existing mods first. Uninstall by restoring that backup and reapplying desired mods, as described in [toolchain research](../research/toolchain.md).

Pending in-game checks: compare R3 with pause-wheel navigation audio; verify no red warning/arrow on opening, hover, page return or cross-page moves; check cooldown/activation visuals; compare spacing with different action counts, label outline, both languages, close/reopen and weapon mode. Existing save/reload and compatibility limitations remain.
