# Separate HUD Enhancements compatibility POC 0.1

Date: 2026-09-30. Compiled and exported; owner in-game confirmation pending.

**Retired after owner test:** the owner reported that both power and weapon wheels showed no UI with this patch. Do not use 0.1. See [loading revision 0.2](hud-compatibility-poc-v0.2.md). The static checks below did not establish runtime class loading.

## Change

Adds `DLC_MOD_EPWHUDCompat` as a separate custom DLC. Its original class `EPWHUDCompat.EPWHUDConsoleWheel` extends HUD Enhancements' controller handler and implements one event:

```unrealscript
public event function Update(float fDeltaT)
{
    Super(SFXSFHandler_PowerWheel).Update(fDeltaT);
}
```

The explicit ancestor call reaches EPW's Update despite HUD's old serialized dispatch target. EPW retains its own Super call. HUD's visibility override, input behavior, PC handler and Scaleform resource remain inherited/referenced. No quickslot implementation or assignments are edited.

The generated coalesced removes the exact HUD 1.1 `ConsolePowerWheel` registration extracted from its local config and adds the same registration with only MovieClass changed. It registers `Startup_MOD_EPWHUDCompat` and its seek-free path. Mount priority is 5088, immediately above the inspected HUD priority 5087. No basegame merge is included. This POC does not modify the main EPW export.

The descriptor uses `requireddlc = DLC_MOD_HUDEnhance`; this is a documented [M3 dependency field](https://github.com/ME3Tweaks/ME3TweaksModManager/blob/staticfiles/documentation/moddesc.ini.md). EPW is a basegame merge, so its installation cannot be asserted by this DLC folder requirement. Install HUD Enhancements 1.1 and EPW 1.9.9 before this patch. The builder refuses a different HUD startup hash and checks for installed EPW functions; the exported descriptor itself does not enforce exact versions.

## Build and validation

`tools/PackageResearch/HudCompatibilityBuilder.cs` compiles an empty LE3 package using explicit local HUD/SFXGame symbol resolvers. Input PCCs/config/mount are read-only; only the new output package is saved. The source class and descriptor are under `src/LE3/HUDCompatibility/`.

```powershell
# Configure the pinned toolchain as described in docs/research/toolchain.md.
./scripts/Build-ResearchTool.ps1
./scripts/Build-HudCompatibility.ps1 -MeleRoot 'E:\Mass Effect Legendary Edition' -Destination build/HUDCompatibility-v0.1-new
./scripts/Export-HudCompatibility.ps1 -BuildDirectory build/HUDCompatibility-v0.1-new
```

Both build and export refuse existing destinations. Neither installs the mod. Build evidence contains dependency hashes, original/replacement registrations, decompiled original bridge source, exports, resolved imports and file hashes.

Passed checks:

- Pinned toolchain build: no compiler errors or warnings.
- Bridge class compilation and source decompilation; explicit parent Update import present.
- VFT selects the compatibility class's own Update, while visibility points to HUD's console override and input points to the wheel parent.
- Five exports, all original: package, class, Update, its float parameter and class default object. No HUD/game code, SWF, texture or dependency export is copied. Exports are marked ForcedExport for their `EPWHUDCompat` logical package.
- 120 non-package imports checked: 117 resolve to the supplied HUD or installed base packages; three Core native reflection types have no script export and are handled explicitly (`Package`, `Function`, `FloatProperty`).
- Saved PCC and mount read-back; coalesced compile/decompile round-trip.
- In-memory config merge against HUD: exactly one active ConsolePowerWheel entry remains; other active movie registrations are preserved.
- Input hashes unchanged; exported payload hashes equal build evidence. `git diff --check` passed.

These are static checks, not confirmation that LE3 loads the new startup/class or renders correctly at runtime. Mod Manager's actual import/install and startup loading remain part of the owner's POC test.

## Delivered artifact

Final folder: `dist/EPW-HUDEnhancements-Compatibility-v0.1-POC-21CDD1729138`.

ZIP: `dist/EPW-HUDEnhancements-Compatibility-v0.1-POC-21CDD1729138.zip`.

- Startup PCC SHA256: `21CDD17291383D9EAE18E01061AB06E4FDEFE225717A58A89F31589BD0B0A59A`.
- ZIP SHA256: `56AC3E297EF6DDF8A46A1C2091DBC1FBCF6CE621865ED60A6DD3C19D33C9DCA5`.
- Installed SFXGame remained `5FA9AF960F5098B8A5C0BF5A7414A5E4C6D410C60AA05A3D17F54BED1DC823A2`.
- There is no M3M: the patch is an original custom DLC, so the startup/payload hashes identify this checkpoint instead.

Binary output remains ignored. The archive contains only this original DLC, moddesc, installation instructions and build evidence.

## Installation, backup and removal

Close LE3. Keep the existing M3 basegame backup for EPW/HUD and copy the test save. Install both prerequisites, import the POC ZIP/folder in M3, then install this patch last. The complete procedure is shipped as `INSTALL.txt`.

The patch adds only `BIOGame/DLC/DLC_MOD_EPWHUDCompat/CookedPCConsole/`: startup PCC, Default bin, Mount.dlc and eight localized TLKs. M3 may also generate its metadata and maintain config infrastructure. It does not overwrite SFXGame, HUD's startup or saves. On a first install there are no existing patch files to back up; before a patch upgrade, copy the existing patch DLC folder.

To remove only the patch, close LE3 and remove/disable `DLC_MOD_EPWHUDCompat` through M3's installed DLC management. Manual fallback is removal of that exact new folder. Keep the prerequisites installed. On next launch HUD's original registration applies again. Restore the copied patch folder if reverting to a prior patch version.

## Owner test

First check that the game reaches the menu and loads a save. Open with RB: personalized page 0 and all occupied/empty icons should appear without joystick movement. Toggle R3 repeatedly and verify completed fades; use LB to move/swap across pages; check badges, help, combo outlines, closing mid-fade and reopening. Check weapons/squad powers and existing HUD behavior when changing input device. Then save/quit/reload. Record the exact symptom if any step fails. Mouse/keyboard pagination and three-mod compatibility are not established by this controller POC; installed DTW code was not changed.
