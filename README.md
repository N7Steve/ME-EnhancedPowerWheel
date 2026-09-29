# Enhanced Power Wheel

Enhanced Power Wheel is an experimental mod project for the Power Wheel in Mass Effect Legendary Edition. Development starts with LE3. Longer term, the project aims to improve power capacity, ordering, navigation, and the information shown on the wheel.

## LE3 checkpoint: two-page ordering wheel

Version 1.3 confirmed a directional outline on the complementary power: hover Pull (Atracción) to pulse Flare (Bengala) red; hover Flare to pulse Pull in a dimmer blue violet. The owner found both borders too thin. Version 1.4 tests wider borders with a faster red flash and a slower violet pulse. See [Pull/Flare hover POC](docs/architecture/pull-flare-hover-poc.md). The exported Mod Manager folder is under `dist/`; build scripts do not install it.

Version 0.8's page fade was confirmed in game, but it also fades the vignette and portraits. Version 0.9 limits the fade to power icons and their mapping clips; the owner confirmed this result works in game. See [fade POC](docs/architecture/fade-poc.md) and [icon-fade POC](docs/architecture/icon-fade-poc.md).

The current LE3 proof of concept has two pages while the Power Wheel stays open:

- Page 0 shows the saved player-power arrangement immediately on opening.
- R3 (right stick click) advances to page 1.
- L3 (left stick click) returns to page 0.
- Input at either page boundary does nothing; closing and reopening starts on page 0.
- Page 1 provides eight selectable player slots and hides squad power icons.
- LT on a player power selects it; LT on another slot moves it there or swaps it with the power already there.

The project owner confirmed this behavior in game, including the personalized first page on RB, page switching, immediate icon rendering, and LT moves. The arrangement is written to the current game's plot variables and reloaded when the wheel opens; it reaches disk with the next game save. Save/quit/reload behavior has not been separately confirmed by the owner. This POC does not increase the number of powers or establish compatibility with other mods.

## Development

Prerequisites: a local LE3 installation, the pinned LegendaryExplorer source checkout, .NET SDK 10.0.401 and .NET 8 runtime, PowerShell, and ME3Tweaks Mod Manager 9.2.1.137. Copy `local.settings.example.ps1` to ignored `local.settings.ps1`, set verified local paths, then dot-source it. Run `scripts/Build-ResearchTool.ps1`, `scripts/Inspect-Le3.ps1`, `scripts/Build-Le3.ps1`, and `scripts/Export-Le3Folder.ps1`. The build validates four function replacements and the wheel's `Update` override, then creates `build/LE3/MergeMods/EnhancedPowerWheel.m3m`; export creates an import folder under `dist/`. Neither command installs anything. See [toolchain research](docs/research/toolchain.md) and [ordering implementation](docs/architecture/ordering-poc.md).

## Status

Version 0.7 is the first owner-confirmed ordering checkpoint. Its merge artifact has SHA256 `43BE9E7783774FDD70D812712882A5D2291AB3422B4BD287C3F17B185C722991`. The Git tag `checkpoint/le3-ordering-v0.7` marks the source and documentation baseline. See [ordering POC](docs/architecture/ordering-poc.md) and [LE3 findings](docs/research/le3-power-wheel.md).

## Rights

Mass Effect and its game assets belong to Electronic Arts and BioWare. This independent fan project is not affiliated with or endorsed by them. Do not redistribute extracted game packages or assets from this repository.
