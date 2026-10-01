# Help row order and destination Y size, version 1.9.18

The owner confirms that 1.9.17 is much improved, with visible destination icons and blue text. The new screenshot shows a smaller right-hand Y than its native leading Y. This is owner confirmation of the basic tooltip correction, not separate confirmation of all controller variants or long-hover edge cases.

Only the presentation helper changes. The requested top-to-bottom order is Switch wheel, contextual LB Reorder/Place/Swap, A Use power, Y Map, B Map, X Map. The top anchor and 30-pixel spacing remain; unavailable actions leave no empty rows. Source/proxy/target indices are preserved (Y=0, B=1, X=2, A=3); only layout traversal changes to A/Y/B/X after Switch and optional ordering. Mapping metadata and diagnostic record indexing therefore remain unchanged.

The destination Y image changes from 32 to 50 pixels, matching the previously inspected native leading Y's texture extent. The screenshot's approximate visible diameter ratio supports this adjustment. Its field dimensions and horizontal center offset account for the larger image. All other destination images and custom action icons remain at 32; text remains AeroLight Shared, size 18, blue `#79c9fd`. Exact visual size parity remains an owner check.

No tooltip data, input, quickslot, pagination, opening, fade or save-persistence logic changes. The quiet in-memory trace is retained from 1.9.17 for verification. Existing local LE2 and earlier LE3 work is preserved.

All 16 manifest functions compile against installed LE3. Base/PC virtual inheritance passes (110/110); all nine EPW helpers remain final/nonvirtual; only explicitly listed class exports change. `git diff --check` passes. Installed `SFXGame.pcc` SHA256 before/after build/export is unchanged: `04BC14031415146E490A498FCEB888AC6780AC1079AFA7336AD5C38A37A47D6D`. No installation performed.

Reproduce with the pinned `scripts/Build-Le3.ps1` and `scripts/Export-Le3Folder.ps1` workflow. Export: `dist/EnhancedPowerWheel-LE3-HelpOrder-v1.9.18-AE4C2A41774C/`. M3M SHA256: `AE4C2A41774C292C425615506575BC6CB907CBE157D14FCAF3B195C12BC6007A`.

Owner installation merges only `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc`. Use Mod Manager's managed basegame backup and record installed mods first. Uninstall by restoring that backup and reapplying desired mods; see [toolchain research](../research/toolchain.md).

Pending game checks: compare left/right Y size and vertical centering; confirm requested row order with all actions and with hidden ordering/mapping rows; verify occupied/empty/squad slots, page switches and closing/reopening. This layout revision is compiler-validated, not yet owner-validated. Save/quit/reload remains separately unconfirmed.
