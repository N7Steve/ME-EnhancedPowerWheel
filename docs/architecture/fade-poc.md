# LE3 page-fade proof of concept (0.8)

## Confirmed locally

The installed LE3 `GFxValue` exposes `GetDisplayInfo()` and `SetDisplayInfo()` with `ASDisplayInfo.Alpha` and `hasAlpha`. The existing power-wheel handler resolves the authored `mainContent.Wheel.Wheel` clip as `m_sWheelInnerPath`; its eight player icon clips are reused for both pages. [Scaleform's alpha convention](https://help.autodesk.com/cloudhelp/ENU/Scaleform-Help/scaleform_help/best_practices/content_creation.html) is 0–100. No SWF or game package was extracted into the mod.

The POC keeps the owner-confirmed 0.7 ordering code. R3/L3 now mark the target page and an outgoing fade in the existing `m_aPowerIconInfo[0].Id` state. `Update` fades the inner wheel over approximately 0.17 seconds, invokes the existing page rebuild at alpha 0, then fades the new page in over approximately 0.17 seconds. Input to the wheel is consumed during the transition. The first-open `P` redraw and LT moves remain immediate. Closing or opening restores alpha 100, so a close during the fade cannot leave the clip transparent. If the GFx clip is unavailable, the page rebuild happens immediately.

The Merge Mod adds no class fields and changes no quickslots. The manifest now adds the `Update` override before compiling the four replacement functions. On the current installed `SFXGame.pcc`, the local validator failed to add even an empty `Update` when this class addition was last; with it first, all five changes compiled in memory. This is a confirmed toolchain/order dependency for this installed package, not evidence that the animation works in game.

## Build and installation boundary

- Installed LE3 `SFXGame.pcc` inspected for this build: SHA256 `1D8F7ACB6F28E78030982C9F2D935CDDEC16877272ABA314CE1C21DFF5ED2D18`. It differs from the earlier research hash; the wheel class's decompiled source was unchanged.
- Version 0.8 M3M SHA256: `DC4CC600FD69521F3ABA49185A2FAF0F177CDA0FBE4A0EF0472EA00B3A25D5E5`.
- Export: `dist/EnhancedPowerWheel-LE3-Fade-POC-DC4CC600FD69/`, containing only `moddesc.ini` and `MergeMods/EnhancedPowerWheel.m3m`. Build and export did not install the mod.
- If installed through Mod Manager, the merge targets `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc`. Use Mod Manager's basegame backup/restore workflow to revert that file and reapply desired mods; do not manually overwrite it with an unrelated PCC.

## Gameplay validation needed

The owner confirmed that the fade-out/fade-in looks good in game, but the chosen `mainContent.Wheel.Wheel` target also fades a blue screen vignette and character portraits. That scope is broader than desired. Version 0.9 tests a narrower target in [the icon-fade POC](icon-fade-poc.md).
