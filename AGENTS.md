# Engineering rules

- Make minimal, evidence-driven changes. Reverse engineer vanilla behavior before replacing it; verify original ME3 assumptions against installed LE3 packages.
- Prefer BioWare's Power Wheel abstractions and an UnrealScript / Merge Mod solution when feasible. Optimize for the smallest working POC, not a generalized framework.
- Keep pagination and content logic separate from unrelated gameplay systems. Do not modify quickslots without an explicit task. Do not couple this project to Dynamic Time Wheels.
- Never silently alter the installed game. Research reads are safe; deployment needs a documented list of changed files, backup method, and uninstall path.
- Do not commit proprietary game assets, original PCC/UPK packages, bulk decompiled vanilla source, or extracted SWFs without clear licensing and provenance. Keep local research output ignored.
- Record useful findings in `docs/`; distinguish confirmed facts, source-based inference, and hypotheses. Check cheap hypotheses against local packages.
- Keep commits small and descriptive. Check `git status`, `git diff`, and `git diff --check` before each commit. Preserve all user or local changes not created by the agent.

## Validated checkpoint

- `checkpoint/le3-ordering-v0.7` is the owner-confirmed LE3 baseline. Preserve its opening behavior: RB immediately shows the personalized page 0, R3 shows page 1, L3 returns to personalized page 0, and all occupied and empty slots render without joystick hover.
- LT selects a player power and then moves it to an empty slot or swaps it with an occupied slot across either page. The 16-slot layout is stored in save-specific plot integers 740200–740204. The owner has confirmed ordering in game; a save/quit/reload test has not been explicitly reported.
- The first-open redraw depends on the `SFXSFHandler_PowerWheel.Update` override and the pending `P` marker in `m_aPowerIconInfo[0].Id`. Keep `Super.Update(fDeltaT)` so inherited behavior, including installed Dynamic Time Wheels behavior, continues. Rebuilding inside `WheelVisibilityChanged` alone previously showed a stale vanilla page.
- This checkpoint adds a function to a class through `addtoclassorreplace`, which recompiles that class. Validate the merge against the installed package and check interactions with other mods that edit `SFXSFHandler_PowerWheel` before broadening compatibility claims.
- Build and export scripts do not install the mod. The owner performs in-game validation from the exported Mod Manager folder. Keep a reproducible export for each checkpoint and record its M3M hash.
- Version 0.9's fade of power icons and mapping clips is owner-confirmed in game. Keep the overlay, vignette, portraits, and wheel ring outside this fade; version 0.8's whole-wheel clip fade included the vignette and portraits. The 0.9 M3M SHA256 is `9A94945FCD700254231ABCC62D4598B9518C929D3F2E8813E6C071D8022AAC08`. Edge cases such as closing mid-fade and save/quit/reload have not been separately reported.
