# LE2 overlay lifetime and dynamic help 0.3.4

The owner subsequently confirms this version works very well. Its visual behavior is the accepted baseline for [save persistence 0.4](le2-save-ordering-v0.4.md). Individual alternative-layout edge cases were not separately reported.

## Owner feedback

The owner reports that 0.3.3's assignment overlays remain visible in normal gameplay after closing the wheel, and its red warning remains faint when unhovered and clear when hovered. The supplied screenshot shows a missing native mapping row leaving a gap above Use power, followed by the two EPW actions. These are runtime failures of 0.3.3; compilation did not validate their presentation. No new hover confirmation is inferred from this report.

## Confirmed evidence and changes

Read-only reinspection of the installed SFXGame (SHA256 `F2924BC4C0FBB062FC1218F10DCCBE07D24B2A022B18D340E85DE6ADB189BFA0`) confirms the 0.3.3 helpers are present. The extracted LE2 controller movie places `notSuggested` as a separate tinted child of `powerIconMC.sub`, with its own alpha/color transform. The overlay is therefore independently addressable. Native state/selection setters remain native; their exact call order and alpha writes are not established by decompilation.

`EPWUpdateSuggestedDisplay` now sets the warning child's own alpha to zero when its default boolean is FALSE, including hidden icons. The TRUE option restores 100. Native visibility changes and parent grow/shrink alpha can no longer reveal a child whose own alpha remains zero. Existing selected/selectable substitution and native evaluation fields remain unchanged. Whether native code independently overwrites this child alpha is a runtime check, not a confirmed implementation fact.

`EPWRefreshMappingIcons(FALSE)` explicitly hides and zeroes alpha for all mapping symbols and their real `mainContent` background paths at the end of power-wheel close, after SetupPlayerPowers/HidePowerIconByIndex. This covers squad as well as Shepard. The normal helper also refuses to show badges when `EPWLE2Open` is false. Opening retains the existing alpha reset to 100. This addresses the real backgrounds introduced by 0.3.3, whose short-path native cleanup cannot be assumed to reach those siblings. No controller assignment is written.

## Dynamic help

The movie's root `ButtonUse`, `ButtonMap1` and `ButtonMap2` are aliases of mainContent clips. Its input-configuration callback swaps the Use/Map1 aliases when menu advance is swapped. The layout uses these aliases rather than hardcoding their glyph objects. Authored text baselines are approximately 198.55, 225.10 and 253.90, and all text fields share X = 179.05.

The final `EPWLayoutHelp` helper caches authored text/button/target positions on the Flash objects before moving them. It retains authored top-to-bottom action order (`m_sMapText2Path`, `m_sMapText1Path`, Use), packs only nonempty native labels from the original top baseline, then appends Switch wheel and Reorder power/Place-Swap. Every row uses a 28-pixel baseline interval and a shared text/action-glyph X. Trailing LB/RB mapping glyphs follow their row's vertical displacement while their native localized-width X remains untouched. Thus 0, 1 or 2 mapping options do not reserve blank rows.

The helper runs after EPW text creation/content updates and restores native positions when EPW UI is hidden, including close/open and other wheel modes. It does not change localized native text, action availability, movie FPS or fade speed.

## Validation and export

Compilation/round-trip and class/struct layout checks pass against installed SFXGame and the registered vanilla backup. All EPW helpers are final. The build verifies the installed package hash remains unchanged and embedded M3M scripts match the source manifest. `git diff --check` passes. No proprietary research assets are tracked.

Export: `dist/EnhancedPowerWheel-LE2-OverlayHelp-v0.3.4-B1CCA3737DEE`.

M3M SHA256: `B1CCA3737DEE51B24C77E3CAA7A1E2EB99D7DFD3C4ACF7F643C06A58FC83810F`.

Only SFXGame.pcc is a deployment target. Build/export do not install. INSTALL.txt preserves the verified-backup requirement and removal by restoring SFXGame through Mod Manager and reapplying desired mods. Historical 0.3.1 Startup recovery remains documented. Same-handler mod compatibility still needs separate validation.

## Pending owner checks

Close normally and midway through both fade phases: no badge symbol/background should remain in gameplay. Reopen and check badges reset correctly, then check the weapon wheel. Test warning-prone powers with/without hover on both pages and squad; compare the optional TRUE build for restored red presentation. Check help with 0/1/2 mapping rows and unavailable Use, ordinary and swapped menu-advance controls, English/Spanish labels and trailing mapping symbols. Confirm no blank rows, alignment, no drift after repeated reopening, and retained green hover/blue selection outline after moving/swapping. New runtime results are pending.
