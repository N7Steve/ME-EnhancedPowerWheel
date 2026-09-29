# Enhanced Power Wheel

Enhanced Power Wheel is an experimental mod project for the Power Wheel in Mass Effect Legendary Edition. Development starts with LE3. Longer term, the project aims to improve power capacity, ordering, navigation, and the information shown on the wheel.

## First experiment

The initial proof of concept has two pages while the Power Wheel stays open:

- Page 0 shows the vanilla powers and behavior.
- R3 (right stick click) advances to page 1, where the wheel remains visible but no powers can be selected.
- L3 (left stick click) returns to page 0.
- Input at either page boundary does nothing; closing and reopening starts on page 0.

This behavior is a target, **not yet an implemented or tested feature**. The first engineering question is whether LE3 can change the displayed power entries in place using UnrealScript and a Merge Mod. No increased power count or mod compatibility is claimed.

## Development

Prerequisites under investigation: a local LE3 installation, LegendaryExplorer tools, and ME3Tweaks Mod Manager. Research must read the installed game without changing it. Set `MELE_ROOT` to the Legendary Edition installation root for local scripts; do not commit local paths or game assets. See [toolchain research](docs/research/toolchain.md) and [POC plan](docs/architecture/pagination-poc.md).

## Status

Repository setup is complete. LE3 package, controller input, and Scaleform investigation are in progress. There is no installable mod yet.

## Rights

Mass Effect and its game assets belong to Electronic Arts and BioWare. This independent fan project is not affiliated with or endorsed by them. Do not redistribute extracted game packages or assets from this repository.
