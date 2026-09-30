# HUD Enhancements 1.1 compatibility investigation

Date: 2026-09-30. Status: structural conflict identified; minimal bridge compiled in memory; no deployment or combined in-game validation.

Follow-up: a separate original DLC has now been compiled and exported as [compatibility POC 0.1](../architecture/hud-compatibility-poc-v0.1.md). That document records the artifact, static checks, installation and rollback. The initial in-memory experiment below remains research evidence; owner gameplay validation is still pending.

## Inputs and scope

Inspected the owner's `D:\Modding\M3Tweaks Mod Manager\LE3\HUD Enhancements` folder (DropTheSquid, moddesc version 1.1) and the currently installed LE3 `SFXGame.pcc`. The installed package contains EPW 1.9.9 opening logic and Dynamic Time Wheels code; it is not a pristine baseline. HUD Enhancements was absent from the installed game's DLC directory during inspection, so this investigation compares library content with the installed base package, rather than reproducing an active combined install.

Input SHA256:

| Input | SHA256 |
| --- | --- |
| HUD `Startup_MOD_HUDEnhance_INT.pcc` | `6F2F829EA51B9B6650F72101EAED2C1AAD344485E999B7DD792CA3A594C0323D` |
| Installed `SFXGame.pcc` | `5FA9AF960F5098B8A5C0BF5A7414A5E4C6D410C60AA05A3D17F54BED1DC823A2` |

Original manifests, config XML, class metadata, bulk decompilation, SWFs and validation output remain ignored under `research/local/LE3/HUDCompatibility/`. No proprietary or third-party implementation is included in this document.

## Confirmed package facts

1. HUD's `HudEnhancements.m3m` adds `ToggleHotkeys` to `SFXGameModeDefault` and `SFXGameModeCommand`. `dpadTextAlign.m3m` replaces `SFXGUIInteraction.ControlTokens` and its default object. Neither replaces EPW's wheel functions. Installation order of these basegame merges does not address the conflict below.
2. HUD's BioUI config removes the vanilla PC/controller `PowerWheel` movie definitions. It registers `PowerWheel` with `HUDEnhanced.SFXModHandler_HybridPowerWheel_PC`, and a separate `ConsolePowerWheel` with `HUDEnhanced.SFXModHandler_HybridPowerWheel_Console`. Each uses its own Scaleform movie. The PC handler opens the console movie.
3. The console handler extends `SFXSFHandler_PowerWheel`. Its visibility override delegates to the wheel parent after maintaining HUD state. Its inherited input/hover/leave targets reference the parent wheel functions, so EPW's replacements remain reachable there.
4. Its serialized virtual table instead maps **Update to `SFXGame.SFXGUIMovieLegacyAdapter.Update`**. The installed EPW parent maps Update to **`SFXSFHandler_PowerWheel.Update`**. Both tables contain 110 entries: matching names/counts is insufficient to establish correct dispatch.
5. The HUD PC handler implements its own Update and explicitly calls the legacy adapter, bypassing wheel Update. It also intentionally accepts visibility changes only in `PWM_PC`. It should not be redirected indiscriminately through EPW's controller logic.
6. The installed vanilla PC wheel also retains the legacy Update target. This is a broader limitation of the existing `auditwheel` check: it validates inherited membership and EPW helper final flags, not the target selected for each inherited function. Its existing PASS must not be interpreted as HUD compatibility.
7. The HUD controller SWF retains the same set of named instances as the previously extracted installed controller SWF, including `Icon001`–`Icon008`, mapping clips/backgrounds, `powerIconMC`, `sub`, the state clips, and native help fields/buttons. Script export comparison against `research/local/LE3/WheelMenu/scripts` found only a removed `SetIcon` variable declaration in the packaged loader. This makes a wholesale SWF replacement unnecessary for the first POC. Instance-name equality and similar scripts do not establish equal hierarchy, geometry, timing, or rendered appearance.
8. Existing installed Dynamic Time Wheels game-mode code obtains `PowerWheel` by tag. With HUD enabled that is the PC handler, not the new `ConsolePowerWheel`. Record this as a separate three-mod timing/input risk; this work does not change DTW or quickslots.

## Source-based explanation of the reported incompatibility

EPW's visibility override sets the pending `P` marker and, in 1.9.9, makes power/mapping clips transparent until the subsequent Update redraws the personalized page. EPW Update also advances page fades, refreshes badges and help, and draws move/combo outlines.

HUD's controller class was compiled with an inherited Update target that bypasses this implementation. If runtime dispatch uses that serialized target, opening leaves the reveal pending and page fades cannot complete. This explains invisible icons or stuck transitions without requiring missing Scaleform clips. The table mismatch and EPW dependence are confirmed; the exact runtime symptoms and whether they account for every owner-reported error still require a combined in-game reproduction.

## Minimal bridge experiment

Added this original member to HUD's console class **in memory only**:

```unrealscript
public event function Update(float fDeltaT)
{
    Super.Update(fDeltaT);
}
```

The compiler parsed, compiled and decompiled the modified class successfully against the installed LE3 symbol environment. The rebuilt console virtual table selects its own Update export (123), and the package gains an import of `SFXGame.SFXSFHandler_PowerWheel.Update` (-307). Only the explicitly recompiled class changed class-export data. No PCC was saved, no M3M was exported, and nothing was installed. These checks verify the bridge structure, not gameplay compatibility. Preserve EPW's own `Super.Update(fDeltaT)`.

The `Bridge.json` generated for this experiment is a **research validator input, not a distributable M3 merge mod**. M3's [documented merge target list](https://github.com/ME3Tweaks/ME3TweaksModManager/blob/staticfiles/documentation/merge_mods.md) covers specified basegame packages and excludes `Startup_MOD_HUDEnhance_INT.pcc`. A successful LegendaryExplorer compile does not establish that Mod Manager accepts that deployment format.

## Compatibility options

| Option | Assessment |
| --- | --- |
| Change installation order only | Does not repair the DLC's serialized Update target. |
| Separate small compatibility DLC | Preferred first distribution POC: an original subclass of HUD's console handler, with the bridge above, and a BioUI delta replacing only the `ConsolePowerWheel` registration. Retain HUD's GFx resource and inherited behavior. Requires confirming startup loading, import resolution, mount order, exact config removal/addition and dependencies. |
| Include that module as an EPW installer option | Same technical solution with no separately installed patch. Activate only when the required HUD version is present; establish M3 conditional/dependency support before implementing. Keep the standalone EPW installation independent. |
| Author integrates the bridge into HUD | Could remove the extra compatibility DLC. Must confirm parent Update resolution when EPW is absent and compile against the intended parent packages. Requires collaboration/permission before sending anything to the author. |
| Locally patch HUD's original startup package | Suitable for a controlled diagnostic copy once a build/save workflow and rollback are documented. Version-specific and overwritten by HUD reinstall. Do not distribute its full package without author permission/provenance. |
| Refactor EPW to work only through current basegame merges | No verified minimal route yet. Moving redraw back into visibility repeats the known stale-first-page problem, and input callbacks alone cannot drive a continuous fade. An alternate inherited frame callback would need evidence; changing a shared UI adapter would broaden scope substantially. |

Recommendation: validate the console Update bridge first, then prefer an original compatibility subclass/config module if it resolves the observed errors. Do not modify the HUD PC Update, quickslots, HUD transition logic or SWFs merely to address the identified controller dispatch conflict. Do not claim keyboard/mouse pagination support from a controller test.

## Reproduction and next validation

After building the research helper with the pinned toolchain:

```powershell
./scripts/Inspect-HudCompatibility.ps1 -MeleRoot 'E:\Mass Effect Legendary Edition'
```

The script reads library/game files, records hashes, extracts manifests/config/class metadata, and performs the in-memory bridge experiment. It verifies input hashes remain unchanged. The helper's `classinfo` reports full virtual target paths and indexed default strings/objects; `configdump` exports LE3 coalesced XML. Validation records rebuilt virtual targets, class decompilation and imports.

SWF inspection was performed with PackageResearch `extractswf` and the existing local JPEXS 26.3 tool. This optional inspection is not run by the script. All output must stay ignored.

Before a test deployment, record the owner's actual errors, input device, versions, prompt option and installation order. Then build an isolated compatibility artifact and document its exact changed files, hash, backup and uninstall procedure. No such deployment is authorized or performed by this research script.

In-game checks should cover immediate personalized page 0 on RB, all empty/occupied icons visible without stick motion, repeated R3 toggles/fade completion, LB move/swap across pages, assignment badges/help/outlines, close during fade and reopen, save/quit/reload, weapon wheel, squad icons, and alternating controller/keyboard input under HUD's three prompt options. Observe existing quickslot behavior for regression without changing assignments. Repeat without DTW first to isolate the two-mod conflict, then with the owner's other installed mods. Owner validation remains necessary.
