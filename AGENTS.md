# Engineering rules

- Make minimal, evidence-driven changes. Reverse engineer vanilla behavior before replacing it; verify original ME3 assumptions against installed LE3 packages.
- Prefer BioWare's Power Wheel abstractions and an UnrealScript / Merge Mod solution when feasible. Optimize for the smallest working POC, not a generalized framework.
- Keep pagination and content logic separate from unrelated gameplay systems. Do not modify quickslots without an explicit task. Do not couple this project to Dynamic Time Wheels.
- Never silently alter the installed game. Research reads are safe; deployment needs a documented list of changed files, backup method, and uninstall path.
- Do not commit proprietary game assets, original PCC/UPK packages, bulk decompiled vanilla source, or extracted SWFs without clear licensing and provenance. Keep local research output ignored.
- Record useful findings in `docs/`; distinguish confirmed facts, source-based inference, and hypotheses. Check cheap hypotheses against local packages.
- Keep commits small and descriptive. Check `git status`, `git diff`, and `git diff --check` before each commit. Preserve all user or local changes not created by the agent.
