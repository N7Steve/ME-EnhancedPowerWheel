# LE3 power-icon fade proof of concept (0.9)

## Evidence and implementation

The owner confirmed that version 0.8's timing and two-phase fade look good in game. The problem is its GFx target: fading `mainContent.Wheel.Wheel` also fades the vignette and character portraits. The installed handler's `InitPowerIcons()` resolves separate GFx values for every power icon, mapped button icon, and mapping background. Its defaults place the portrait clips elsewhere under the shared wheel path. These are confirmed script paths; the complete SWF clip tree has not been inspected.

Version 0.9 keeps the 0.8 page state and timing, but applies alpha only to `m_aPowerIcons` and their mapped icon/background clips. The wheel ring, portrait clips, and screen overlay are not targeted. The old page is rebuilt at alpha 0, after which the new power clips fade in. Opening or closing restores all affected clips to alpha 100. If power icons are unavailable, page switching falls back to an immediate redraw. No SWF edit, new class field, quickslot change, or game installation is involved.

## Build and installation boundary

- Current installed LE3 `SFXGame.pcc` used for validation: SHA256 `C6F52C053FE0F66DE5E9216B1EC91B6F799EFACD855E275241E47DE4E2E6CE86`. It differs from the package used for the 0.8 build; the owner tested 0.8 in game.
- The class addition and all four function replacements compiled in memory against that package, with the class addition first in the manifest. Mod Manager produced M3M SHA256 `9A94945FCD700254231ABCC62D4598B9518C929D3F2E8813E6C071D8022AAC08`.
- Export: `dist/EnhancedPowerWheel-LE3-IconFade-POC-9A94945FCD70/`, containing only `moddesc.ini` and `MergeMods/EnhancedPowerWheel.m3m`. Build and export did not install the mod.
- If installed through Mod Manager, the merge targets `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc`. Use Mod Manager's basegame backup/restore workflow to revert that file and reapply desired mods; do not manually replace the PCC.

## Gameplay result and remaining checks

The owner confirmed version 0.9 works in game and that the icon-only fade resolves the unwanted vignette and portrait fade. This is the preferred visual checkpoint. Separate results were not reported for closing mid-fade, rapid repeated presses, save/quit/reload, or interactions with other mods that edit the wheel handler; those remain open compatibility and edge-case checks. The 0.8 source remains at commit `4780853` if a comparison build is needed.
