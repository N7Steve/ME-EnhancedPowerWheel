# Character-compatible green move targets v1.9.30

The owner clarified that green destination borders must only appear on slots
compatible with the power being moved. This supersedes v1.9.28's all-section
hover marker. The source retains its existing green marker.

Confirmed source: LB reorders Shepard within aPlayer across both pages, and
squad powers within the selected companion's aHench1 or aHench2 indices. Pressing
LB in another character's section changes selection instead of transferring the
power. Update now mirrors those destination memberships: active Shepard selection
requires aPlayer membership; active squad selection requires source/destination
membership in the same hench array. Empty slots in the matching section qualify.
Hover and visibility remain required, and existing fade-out suppression remains.
No LB behavior, gameplay, save data, quickslots or icon animation is changed.

Only Update's destination predicate/local bools plus version/export/install docs
changed for this request. Prior ammo proxy repair, combo fades, static empty slots,
source borders, P redraw/reveal and Super.Update are preserved. Local LE2/README
and earlier squad changes are preserved.

All 18 manifest functions compile/decompile against installed LE3. Decompiled
Update retains both hench membership checks and player membership. Inheritance
passes 110/110; eleven helpers remain final/nonvirtual; only listed class exports
change; git diff --check passes. Runtime visual verification is pending.

Installed SFXGame.pcc hash before/after build/export:
`A2BD8097E964502FB78D7A7A1E4899B0FA0C48D8C617D6AE62A072BFF7BA501D`.
No installation performed. Local validation output stays ignored.

Export: `dist/EnhancedPowerWheel-LE3-MoveTargets-v1.9.30-1C8FE8370882/`.
M3M SHA256:
`1C8FE8370882203DD96C700F52380E5DFA8160E135E322D7A8873E66093AA543`.
Reproduce using scripts/Build-Le3.ps1 with installed game/pinned Mod Manager paths,
then scripts/Export-Le3Folder.ps1.

Check Shepard source -> Shepard occupied/empty hover on both pages: green.
Shepard source -> either companion: no destination green. Each companion source
-> its own occupied/empty slots: green; -> Shepard or the other companion: no
destination green. Source stays green. Check place/swap/cancel, LB selection of
another character, page changes and close/reopen for stale destination borders.

Install through Mod Manager, merging only Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc.
Retain its managed basegame backup, record installed mods and a pre-test save.
Uninstall by restoring that backup and reapplying desired mods/the previous
checkpoint; restore the save copy to undo ordering. Exported INSTALL.txt includes
the changed file, backup and uninstall instructions.
