# Mapping source correction, version 1.9.7

## Confirmed findings

The owner reported that 1.9.6 did not correct the missing badges. Its approach reused `bMapped`/`eIcon` from isolated native icon setup; the report invalidates the assumption that invoking the native visual setter on that snapshot would be sufficient. The precise native failure was not traced live.

Read-only inspection of installed LE3 confirmed:

- `BioHintSystem.Tick` reads `BioPlayerInput.m_nmMappedPower`, `m_nmMappedPower2`, and `m_nmMappedPower3` as left, right and class-power assignments.
- `SFXPawn_Player.AutoMapXbox` normalizes those stored names to actual power class names. Save/load code persists the same three fields. The mod never calls AutoMapXbox or writes those fields.
- The wheel SWF mapping badge contains all button symbols as named child clips in one frame, including LB/RB/Y. The handler's `m_aMappingIconPaths` provides their native names.

## Correction

`EPWRefreshMappingIcons` reads current input assignments and matches each displayed player power by class name or power name. It derives GUI mapping metadata from that match and explicitly enables only the corresponding native badge child, root and background. Empty/unmapped slots are cleared. Shoulder/trigger swap and southpaw flags are read to choose physical side/button labels; alternate layouts require their own game check.

This replaces the 1.9.6 setter refresh and removes mapping metadata snapshots from isolated `SetupPlayerPowers` calls. The helper runs after rebuilding and during normal wheel updates, before interpreting mapping-dependent contextual help on a preserved hover. Mapping clips retain their existing fade behavior.

Only GUI metadata and clip visibility are written. Existing controller assignments, quickslots, save fields and input bindings are read-only. All unrelated local changes are retained. There is no claim that the isolated snapshot failure or alternate-layout semantics have been independently instrumented in game.

## Validation and export

All manifest functions compiled against installed LE3. Base/PC virtual inheritance passed (110/110); all EPW helpers remain final and outside the virtual table. `git diff --check` passed. No installation occurred, and installed `SFXGame.pcc` SHA256 stayed `D5E27CB428C9DAC0F666206F4D6B13BC99437869020ED01EAD94412F78AAF62D`.

Reproduce with `scripts/Build-Le3.ps1` and `scripts/Export-Le3Folder.ps1`. Export: `dist/EnhancedPowerWheel-LE3-MappingBadges-v1.9.7-A6D7EFA5A6C9/`. Contents: `moddesc.ini` and `MergeMods/EnhancedPowerWheel.m3m`. SHA256: `A6D7EFA5A6C9228DC35468F20BB2B605BE368957EDF2E18D9E9CA85AEF3A87D0`.

The owner installs and checks in game. The sole merge target is `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc`; verify Mod Manager's basegame backup and record existing mods before installation. Restore that backup and reapply desired mods to uninstall; see [toolchain research](../research/toolchain.md).

Pending: badges should appear on first open without reassignment or hover, survive page return and close/reopen, follow moved powers to page 1, and disappear from the old power after reassignment. Check real LB/Y/RB activation remains unchanged, plus alternate controller layouts if used. Save/quit/reload remains a separate item.
