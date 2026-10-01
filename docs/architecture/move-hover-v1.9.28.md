# Green hover outline while moving v1.9.28

The owner requested the same green outline on every hovered slot while a power
is picked for moving. The picked source keeps its existing green marker.

Confirmed from current source: Shepard selection is encoded in character 16 of
m_aPowerIconInfo[0].Id; squad selection uses the wheel's EPWSquadSelected property.
Update already traverses every physical icon/state, including empty states, and
renders EPWMoveOutlineGreen in current/desired visual states. The suggested-state
helper caches empty-state values as well, so no native selection animation is
needed to draw the empty destination border.

Update now computes bMovingPower from either an active Shepard selection or a
valid visible occupied squad source. Its existing outline predicate additionally
accepts the current hovered visible icon whenever that selection is active.
There is no power-presence filter on the destination: empty slots participate.
The same existing clip, depth 102, 2.2-pixel width, #00AD79 color and geometry are
reused. Hover changes hide previous destination markers on the next Update;
place/swap/cancel removes the selection and therefore the hover marker. The
existing page fade-out suppression remains. Every visible hovered section is
marked as requested; this is visual feedback and does not change the existing
LB rules that prevent transferring powers between characters.

Only Update's green visibility predicate and a local bool were changed for this
request, plus version/export/installation documentation. Static empty hover,
combo fades, Super.Update, opening P redraw/reveal, saved layouts and quickslot
behavior are retained. Previous local LE2/README/squad changes are preserved.

All 18 manifest functions compile/decompile against installed LE3. Decompiled
Update retains bMovingPower and its visible current-hover alternative. Virtual
inheritance passes 110/110; eleven helpers stay final/nonvirtual; only explicitly
listed class exports change. git diff --check passes. Actual visible hover border
behavior remains pending owner runtime verification.

Installed SFXGame.pcc SHA256 before and after build/export:
`C25632A04B920EBD5ACEF4C8E61FDA182EA72530B8D2D8FBC35DE795C784B28A`.
No installation performed. Compiler evidence remains ignored under
research/local/LE3/Validation.

Export: `dist/EnhancedPowerWheel-LE3-MoveHover-v1.9.28-1A2B44A049AF/`.
M3M SHA256:
`1A2B44A049AFA1662793EA40E0115A29C23B884B9ABD59E89123EA6B60DAF89C`.
Reproduce with scripts/Build-Le3.ps1 using installed LE3/pinned Mod Manager paths,
then scripts/Export-Le3Folder.ps1.

Check Shepard LB pick: source remains green and occupied/empty hovered slots
receive the same green outline, with previous hover borders clearing. Check both
pages while the source is on the other page. Repeat for each squad member and
hover another character's section. Existing LB behavior there still applies.
Check place, swap, cancel, no green hover outside move mode, R3 squad cancellation,
close/reopen and static empty slots. Existing combo/flicker changes still require
owner visual confirmation.

Installation merges only Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc through
Mod Manager. Keep its managed LE3 basegame backup, record installed mods and a
pre-test save. Uninstall by restoring that backup and reapplying desired mods or
the prior checkpoint; restore the save copy to undo ordering. Exported INSTALL.txt
contains the changed file, backup and uninstall instructions.
