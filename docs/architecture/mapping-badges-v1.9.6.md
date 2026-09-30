# Mapping badge refresh, version 1.9.6

## Evidence

The owner confirmed the 1.9.5 result works correctly, then reported LB/Y/RB power-assignment badges appear immediately on assignment but disappear after page switching or closing/reopening the wheel. The supplied screenshot shows the expected native button badges.

The page rebuild saves and restores `bMapped` and `oMappedIcon.eIcon` from native power setup. It previously assigned the enum directly after clearing the physical GFx icon. That restores internal metadata but does not explicitly redraw the badge. Installed LE3 exposes `SetMappingIcon(out SFXPowerWheelButtonIcon, SFXPowerWheelMapButtonIcon, optional bool bClear)` and uses native mapping clip names for Y, LB, RB and the other supported controls. The possibility that this native setter skips unchanged enum values is an inference, not a decompiled native implementation fact.

## Minimal correction

After each physical player icon is rebuilt and made visible, occupied mapped slots reset the local badge's cached enum to NONE and invoke `SetMappingIcon` with the saved button value. Empty or unmapped slots clear their badge. Badge and mapping-background visibility are restored explicitly. The existing icon-only fade still includes these mapping clips.

This code refreshes display only. It does not call `MapCurrentPower` or `SFXGUIValue_PowerIcon.Map`, alter controller bindings, assign powers, or write quickslot data. Saved power ordering and the native assignment metadata are retained. The refresh applies to first opening, page changes and move/swap rebuilds.

## Validation and reproducible export

All manifest functions compiled against installed LE3. Virtual inheritance validation passed (base/PC 110/110), EPW helpers remain final, and `git diff --check` passed. No installation occurred. Installed `SFXGame.pcc` SHA256 stayed `7483CD0DA350D63E22C92B4B3CB0413FE59CC07027FB3AC6D68A16EE5F43D404` before and after build/export.

Reproduce with `scripts/Build-Le3.ps1`, then `scripts/Export-Le3Folder.ps1`. Export: `dist/EnhancedPowerWheel-LE3-MappingBadges-v1.9.6-15460684F974/`. Contents: `moddesc.ini` and `MergeMods/EnhancedPowerWheel.m3m`. M3M SHA256: `15460684F9747EC66D2EA5032EFDB3E89FEE1037FEA6827291B777F6210AA3E3`.

The owner performs installation. Only `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc` is targeted by the merge. Verify Mod Manager's basegame backup and record existing mods first. Uninstall by restoring that backup and reapplying desired mods; see [toolchain research](../research/toolchain.md).

Pending in-game checks: assign LB/Y/RB, switch 0 to 1 to 0, close/reopen without hovering, and confirm the same badges immediately. Move/swap mapped powers within and across pages; badges should follow the power and leave empty slots clear. Reassign a button and verify the old power loses its badge. Confirm actual quickslot actions remain as assigned, including alternate controller layouts if used. Save/quit/reload remains a separate validation item.
