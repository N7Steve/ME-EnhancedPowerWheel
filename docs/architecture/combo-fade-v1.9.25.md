# Primer hover and detonator outline fade v1.9.25

## Requested behavior

Combo outlines now appear only when hovering a primer. Compatible visible
candidate detonators receive the existing red outline; hovering a detonator
no longer draws violet outlines around primers. A power with both roles still
acts as a primer for this display. The hovered icon is not outlined.

## Evidence and implementation

Confirmed from the existing implementation: Update computed both directional
mask intersections, drew independent red/violet runtime clips and pulsed their
alpha. LeavePowerIcon hides both clip types across every icon/state. Existing
page reconstruction and wheel closing call that cleanup. The existing primer
classification and each live power's ComboDetonators array remain unchanged,
including the same-PowerName exclusion and visible squad participation.

The change removes the reverse-direction drawing branch. HoverPowerIcon records
WorldInfo.RealTimeSeconds in the icon's transient GFx EPWComboHoverStart property
only when entering a different hover. Update multiplies the unchanged red pulse
(alpha 56-84 percent, 7.5 radians/second) by smoothstep over 0.2 real-time seconds.
This clock is already used by the existing pulse and advances while paused.
Repeated callbacks for the same current icon do not restart the fade. Leaving,
changing page or closing retains immediate cleanup; the next hover restarts it.
No new class properties, save data, gameplay or quickslot logic are added.
Super.Update, pending P opening redraw, opening reveal and existing page/icon
fade are preserved. Previous local LE2, README and LE3 squad changes are retained.

## Verification

All 18 manifest functions compile against the installed LE3 package. The
compiled/decompiled Update retains the 0.2-second smoothstep multiplier and
creates only red combo clips; the compiled hover retains its timestamp write.
Virtual inheritance passes 110/110, all eleven helpers remain final/nonvirtual,
and only explicitly listed class exports change. git diff --check passes.
In-game appearance and timing are not yet owner-confirmed.

Installed SFXGame.pcc SHA256 before and after build/export:
`A6171D44FBED1A58EB3C3DBEF3AEFDAD450364B20CC636726474F02DC11AEE7E`.
No installation was performed. Local compiler/decompilation evidence remains
ignored under research/local/LE3/Validation.

Export: `dist/EnhancedPowerWheel-LE3-ComboFade-v1.9.25-1A8A0AF569D6/`.
M3M SHA256:
`1A8A0AF569D6428ACDE11C54DADB1ECF8A1CEEADFD6C88381F831BC5557F7A82`.
Reproduce with scripts/Build-Le3.ps1 then scripts/Export-Le3Folder.ps1, providing
the installed game and pinned Mod Manager paths to the build script.

## Owner checks and deployment

Check a primer with compatible Shepard/squad detonators: entry should rise
smoothly before settling into the existing pulse. Hover a detonator-only power:
no primer outlines. Check a dual-role primer, rapid hover changes, returning to
the same primer, empty slots, both player pages, R3 during fade and close/reopen.
Check no stale red/violet outlines and retained green LB move outline. Existing
cooldown, squad image and save/quit/reload checks remain separately pending.

Installation merges only Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc through
Mod Manager. Retain the managed LE3 basegame backup, record installed mods and
keep a pre-test save. Uninstall by restoring that backup and reapplying desired
mods/the previous checkpoint; restore the pre-test save to undo ordering. The
export includes INSTALL.txt with the changed file, backup and uninstall path.
