# Wheel toggle and help, version 1.9.2

## Requested behavior

R3 alternates between both power pages. L3 no longer navigates. The request mentioned L3 in the help label after requesting R3 as the sole navigation button; the label uses R3 to match the implemented control. LB pick and completed placement/swap share `HUDPowerWheelQueueingHighlightedPowerForActivation`. Cancellation on the same slot stays silent. Accepted R3 presses play `HUDPowerWheelChangeHighlightedPower`, an existing short navigation cue already used by power hover.

## Confirmed local evidence

Read-only inspection of installed LE3 `SFXGame.pcc` confirmed the native `SFXEngine.GetProfileSettings()` and `SFXProfileSettings.GetLanguageText()` signatures. The local wheel SWF research shows four use/map help text fields, with a shared imported `AeroLight Shared` font, 20-pixel text, and RGB `79C9FD`. Their authored coordinates place them on the right. Extracted assets and decompiled source remain in ignored `research/local/`.

The existing `SetMapText` supplies only three assignment rows. Adding a fifth text field avoids replacing an assignment hint or changing quickslots. `EPWUpdateSwitchHint` creates `EPWSwitchHint` under the existing inner wheel, with the next free Flash depth, aligned to the use-button X coordinate and four pixels below the bottom of all four existing help rows. It uses the imported font, native text color and copied text filters. The R3 identifier is text rather than a new controller glyph asset. It shows `R3 - Alternar rueda` for ES/ESN/SPA Spanish profile codes and `R3 - Switch wheel` otherwise. Visibility follows wheel opening/closing, power mode and `m_bShowUseMapText`.

The new helper is final. `WheelVisibilityChanged` now belongs to the same `addtoclassorreplace` script list so the compiler resolves the added helper. This retains its existing opening marker and alpha reset behavior. In-memory validation passed for every manifest function against the installed package, including base/PC virtual table membership (110/110) and all EPW helpers remaining final and outside the virtual table.

## Source-based behavior and pending game validation

R3 writes `1 - nPage` as the outgoing fade target. Internal negative-value thumb calls rebuild that stored target without toggling or playing another sound; L3's remaining negative path is only an internal redraw. `Super.Update(fDeltaT)`, the pending `P` first-open redraw, icon-only fade, ordering selection and persistence are retained. Physical L3 presses are consumed while in power mode without navigating.

Compilation establishes syntax and class structure, not live rendering or audio. Check the new row in Spanish and English, occupied/empty slots and squad hover, both pages, and repeated wheel openings. Check R3 goes 0 to 1 to 0, quick repeated presses during fading do not double-switch, and opening still starts on the personalized page 0. Check pick/place/swap share the cue, cross-page LB moves retain the selected power, and closing mid-fade resets opacity. Startup recovery, overflow and save/quit/reload still have their previously recorded validation limits.

## Reproducible export and deployment

Build with `scripts/Build-Le3.ps1` using the verified local game and Mod Manager paths, then run `scripts/Export-Le3Folder.ps1`. Export: `dist/EnhancedPowerWheel-LE3-WheelToggle-v1.9.2-79792FF54380/`. Contents are `moddesc.ini` and `MergeMods/EnhancedPowerWheel.m3m`. M3M SHA256: `79792FF54380CFAD986BCB2B84B2CE32F9D1409102369204B211FF9FDFEBE212`.

No installation was performed. The installed `SFXGame.pcc` hash stayed `BABD020C6EB8FDB12FB5D612A579A145CD0A1F2AF8DC427D76F65D5C08DC6361` before and after build/export. If the owner installs through Mod Manager, the merge targets only `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc`. First verify the manager's basegame backup and record installed mods; uninstall by restoring that backup and reapplying desired mods, as described in [toolchain research](../research/toolchain.md). The build incorporates pre-existing local LB, combo and overflow changes without reverting them.
