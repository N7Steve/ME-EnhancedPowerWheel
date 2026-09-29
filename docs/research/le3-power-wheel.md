# LE3 Power Wheel findings

Inspected the locally installed LE3 `SFXGame.pcc` with LegendaryExplorerCore. Package SHA256: `D9322946E03355D12C4934A3CC67A6AE47E74E644856E9D4B22F7F0EAF4`. This package already has unrelated mod changes; findings below refer to its current installed state. Bulk decompilation is ignored under `research/local/LE3/`.

## Confirmed from LE3 exports

- `SFXSFHandler_PowerWheel` is native, transient, and extends `SFXGUIMovieLegacyAdapter`. `SFXSFHandler_PCPowerWheel` is its native subclass. The base handler contains dynamic `m_aPowerIconInfo` and `m_aPowerIcons` arrays plus `m_oPowerIndices` arrays for player and squadmates. Its defaults provide 18 icon descriptors: eight player icons (`Icon001` through `Icon008`) and five for each squadmate. That is a fixed authored GFx slot pool for the current UI, not evidence of an eight-element engine array limit.
- `InitDisplay()` calls `InitPowerIcons()`. The latter obtains a `SFXGUIValue_PowerIcon` for each authored path, sets its fields, clears it, updates it, and appends it to `m_aPowerIcons`. It does **not** clear the array first, so calling it again as a refresh risks duplicate entries.
- `SetupPlayerPowers()` is a native function; its internal collection/filtering algorithm cannot be recovered from UnrealScript decompilation. `SelectCurrentPower()`, `SetWheelVisible()`, and `SFXGUIValue_PowerIcon.Hide/ClearIcon/SetPower/UpdateDisplay` are also native. Native behavior needs runtime testing or deeper native analysis.
- `WheelVisibilityChanged(FALSE)` leaves the hovered icon, deselects and hides each power icon, then hides the wheel. `WheelVisibilityChanged(TRUE)` sets icon visibility individually before showing wheel chrome. These existing calls show icon visibility can be changed independently of the entire wheel.
- `HoverPowerIcon()` and `LeavePowerIcon()` manage `m_nCurrentPowerIconIndex`, hover, selection, descriptive text, and tutorial hints. A power page switch must clear the current selection. `SelectCurrentWheelItem()` calls native `SelectCurrentPower()` for power mode; the PC mouse-up path also calls it.
- The PC subclass adds a separate fixed eight-element quickslot array and `SetupQuickSlotPowers/Keys()` native methods. The POC does not modify quickslots.

## Still uncertain

- How many powers native `SetupPlayerPowers()` collects, whether it can repopulate cleared icons while the wheel stays open, and whether it refreshes cooldown and mapping state.
- Whether native wheel tick or GFx callbacks can highlight or activate an icon after it is hidden/cleared.
- Whether controller thumb clicks reach `HandleInputEvent()` while the wheel is open, despite the verified input bindings.
- Which parts of the wheel are rebuilt on each open. `InitDisplay()` has an icon-creation path; no claim is made that it runs on every open.

The compiled POC reuses the existing icon values, clears/hides their power content, calls native `SetupPlayerPowers()` to restore, and intercepts selection through the existing `SelectCurrentWheelItem()` function. It does not replace the native population algorithm or add GFx clips. Runtime testing must check these assumptions.
