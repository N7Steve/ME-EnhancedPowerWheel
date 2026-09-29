# Enhanced Power Wheel

Enhanced Power Wheel is an experimental mod project for the Power Wheel in Mass Effect Legendary Edition. Development starts with LE3. Longer term, the project aims to improve power capacity, ordering, navigation, and the information shown on the wheel.

## First experiment

The initial proof of concept has two pages while the Power Wheel stays open:

- Page 0 shows the vanilla powers and behavior.
- R3 (right stick click) advances to page 1, where the wheel remains visible but no powers can be selected.
- L3 (left stick click) returns to page 0.
- Input at either page boundary does nothing; closing and reopening starts on page 0.

This behavior now has a **compiled Merge Mod experiment**, but it has not been deployed or tested in game. No increased power count or mod compatibility is claimed.

## Development

Prerequisites: a local LE3 installation, the pinned LegendaryExplorer source checkout, .NET SDK 10.0.401 and .NET 8 runtime, PowerShell, and ME3Tweaks Mod Manager 9.2.1.137. Copy `local.settings.example.ps1` to ignored `local.settings.ps1`, set verified local paths, then dot-source it. Run `scripts/Build-ResearchTool.ps1`, `scripts/Inspect-Le3.ps1`, `scripts/Build-Le3.ps1`, and `scripts/Export-Le3Folder.ps1`. The build validates UnrealScript and creates `build/LE3/MergeMods/EnhancedPowerWheel.m3m`; export creates an import folder under `dist/`. Neither command installs anything. See [toolchain research](docs/research/toolchain.md) and [POC plan](docs/architecture/pagination-poc.md).

## Status

Repository setup and static LE3 investigation are complete. The source and compiled experiment need a clean, restorable LE3 test target and gameplay validation. See [current findings](docs/research/le3-power-wheel.md).

## Rights

Mass Effect and its game assets belong to Electronic Arts and BioWare. This independent fan project is not affiliated with or endorsed by them. Do not redistribute extracted game packages or assets from this repository.
