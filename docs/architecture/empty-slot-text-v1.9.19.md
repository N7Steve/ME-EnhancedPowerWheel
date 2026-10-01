# Empty-slot central text, version 1.9.19

The owner reports that hovering an empty player slot displays the name of a power occupying the same position on the other page, including Marksman. This is a reported gameplay defect; the correction below awaits owner validation in game.

Confirmed by read-only inspection of the currently installed LE3 package: `UpdateTextDisplayForIcon` suppresses use/map strings for empty states but still calls `UpdatePowerInformationText`. The latter passes `oIcon.sName` and `oIcon.sDescription` to the central information display. The installed page-rebuild branch clears power/pawn references and sets the empty state without explicitly clearing text metadata. `ClearIcon` is native; its internals were not decompiled. Retained text after native setup/page reuse is the source-based explanation consistent with the reported symptom.

The minimal correction adds three assignments only to the final empty-slot branch in `HandleInputEvent`: clear `nmPowerName`, `sName`, and `sDescription`. Both pages, opening rebuilds and reorder refreshes share this branch. Occupied slots still receive native power metadata. No new function replacement, class fields or gameplay systems are introduced. Existing local LE2 and LE3 work is preserved.

Validation: all 16 manifest functions compile against the installed LE3 `SFXGame.pcc`; only explicitly listed class exports change; base/PC virtual inheritance passes (110/110); all nine EPW helpers remain final/nonvirtual. `git diff --check` passes. Installed package SHA256 before and after inspection/build/export is unchanged: `BC91B6E7D820158ACBACB811A7EE023A6192EED1526173F459ACEF0BE366380E`.

Reproduce with `scripts/Build-Le3.ps1` using the pinned toolchain, followed by `scripts/Export-Le3Folder.ps1`. Export: `dist/EnhancedPowerWheel-LE3-EmptySlotText-v1.9.19-F9BEE290C932/`. M3M SHA256: `F9BEE290C9327C1942684F6BA9273DC383524EE17FC36FC6D4886F997A447E03`.

No installation performed. Owner installation through Mod Manager merges only `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc`. Before installation, retain Mod Manager's managed basegame backup and record installed mods. Uninstall by restoring that backup and reapplying desired mods; see [toolchain research](../research/toolchain.md).

Pending gameplay checks: hover an empty slot opposite Marksman on each page and verify the central name is blank; hover an occupied slot and verify its correct name; move a power into an empty slot and confirm the vacated slot stays blank; switch pages with hover preserved and close/reopen. Save/quit/reload remains separately unconfirmed.
