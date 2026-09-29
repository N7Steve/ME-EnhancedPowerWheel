# Toolchain research

## Confirmed local baseline

- The repository started empty on `main`, with `origin` set to the public GitHub repository.
- LE3 `SFXGame.pcc` exists in the installed game's `Game/ME3/BioGame/CookedPCConsole` directory. Research must not modify it.
- Git, .NET, PowerShell, and Python are available. `gh`, `7z`, and `ffdec` are not on `PATH`.

## Pending

- Locate LegendaryExplorer and ME3Tweaks Mod Manager, including their actual command-line and library capabilities.
- Establish package inspection, UnrealScript decompilation/compilation, Merge Mod build, installation, and rollback workflows.
- Use `MELE_ROOT` for local install paths rather than storing machine-specific paths in repository scripts.
