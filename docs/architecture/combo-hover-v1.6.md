# Combo hover v1.6 (LE3)

## Behavior

The visible wheel icons are evaluated by their live `pPower` instances, including both squad members. Hovering a primer draws a pulsing red outline around compatible detonators. Hovering a detonator draws a slower violet outline around compatible primers. If both directions apply to a pair, red takes precedence. The hovered icon is not outlined. Icons on the other player page and hidden squad icons are ignored. Leaving an icon, changing page, or closing clears every outline, including squad outlines.

`EPWPrimerMask` stores the single-player primer types from the owner's combo analysis: Biotic, Cryo, Electric, and Fire. `EPWDetonatorMask` reads the loaded `SFXPowerCustomAction.ComboDetonators` array rather than using a static detonator list. `CheckForPowerCombo` in the installed LE3 `SFXGame.pcc` checks that same array against the target's combo effect and rejects the same `PowerName` as the effect's source. The hover code mirrors that name check. It does not change combat behavior, quickslots, ordering, or saved data.

These outlines show *potential* pairings. Lift and freeze resistance, armor/shields, ammo selection, evolution requirements, target type, effect timing, and whether a deployed actor is destroyed are only known in combat. The wheel cannot guarantee an explosion. Conditional primers in the table therefore show their possible types, including Concussive Shot with Amplification/ammo, Sentry Turret with its ammo evolution, and Sticky Grenade with ammo. The attached analysis explicitly excludes the bugged Concussive Shot + Disruptor Ammo tech primer. Unknown modded primer names return no primer type, while their loaded detonator arrays can still be recognized.

The owner's example of Pull and Garrus's Incinerate should not receive a direct pair outline: Pull primes Biotic and Incinerate's installed detonator array lacks Biotic. Garrus's Incinerate participates with compatible powers such as Overload and Throw. Liara's Singularity primes Biotic when it lifts a target and participates with Throw, Warp, Flare, and other compatible detonators. `PowerName` is read from each squad icon's actual `pPower`, so the wheel does not need a separate roster of squadmates.

## Evidence and validation

- Confirmed in installed package research: `SFXPowerCustomAction.CheckForPowerCombo` uses `ComboDetonators.Find(ComboEffect.Class)` and compares source `PowerName`; Incinerate has Electric, Fire, Cryo; Throw has all four; Singularity applies Biotic; Flare's array has Biotic and Cryo. Local decompilation stays in ignored `research/local/LE3/`.
- Source-based inference: all actual `SFXGUIValue_PowerIcon.pPower` instances, including squad icons, expose their loaded detonator array through `SFXPowerCustomAction`. The renderer tests `bVisible` so page 1 does not mark hidden squad icons.
- The UnrealScript validator and Mod Manager compiler passed against the installed `SFXGame.pcc`. The export is a Mod Manager import folder, not an installation. In-game visual behavior and the conditional primer cases remain to be checked by the owner.

Final M3M v1 SHA256: `DDB96EE7A2E2FDB5CB29F8B0AF58ADAD40B916EE131280378691118453FA659D`. Export: `dist/EnhancedPowerWheel-LE3-ComboOutline-v1.6-DDB96EE7A2E2/`. Installed `SFXGame.pcc` SHA256 after export: `23543F41B0E986D5962B66E7C2700B411D88C7DE01A72D09C41934993CB91A7E`. The build and export did not modify the installed package.

Suggested in-game checks: hover Liara Singularity with Shepard Throw, hover Shepard Overload with Garrus Incinerate, reverse each hover, and switch player pages while a squad outline is active. Check Pull + Garrus Incinerate for no direct outline. Check close/reopen and a power with two roles (Warp or Incinerate) for stale or incorrectly colored outlines.

Deployment through Mod Manager targets `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc`. Before installing, record that file's hash and installed mods, verify Mod Manager's basegame backup, and retain the backup for uninstall/reapply. Do not copy a package over the game manually. The Merge Mod recompiles `SFXSFHandler_PowerWheel`; interaction with other mods that edit this class needs an in-game check.

## v1.7 outline closure

The owner confirmed the v1.6 combo hovers work in game but reported a gap at the upper-left of the violet outline. Inspection of the drawing commands confirmed the path stopped at `(-44.25, -4.95)` without a final `lineTo` back to its starting point `(-37.0, -6.45)`. Version 1.7 adds that segment to both outline clips. No combo classification, colors, pulse, or wheel behavior changed. Compilation passed; the closed appearance still needs an in-game check.

v1.7 M3M v1 SHA256: `CF107B1BA1141AA14F0827F269EEA2FAF08D92A67F3567731CD5DD69E6EE792A`. Export: `dist/EnhancedPowerWheel-LE3-ComboOutline-v1.7-CF107B1BA114/`. The installed `SFXGame.pcc` SHA256 after export was `693A86BBF3FECC303A1F69AE4A6B01CF21A9FF3632EB16A0D8FCBB84D4D99615`; this reflects the game state at the time of the build, not a change made by the scripts.
