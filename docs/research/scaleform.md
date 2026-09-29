# LE3 Scaleform mapping

The installed LE3 `SFXGUIInteraction` movie table maps controller `SFXSFHandler_PowerWheel` to `GUI_SF_ME2_PowerWheel.ME2_PowerWheel` and `SFXSFHandler_PCPowerWheel` to `GUI_SF_PC_ME2_PowerWheel.PC_ME2_PowerWheel`. Both `GFxMovieInfo` exports are in the installed `Startup.pcc`, alongside their package and texture exports. The POC does not extract or modify their SWFs.

The controller handler's LE3 defaults specify paths `mainContent.Wheel.Wheel.Icon001` through `Icon008` for player powers and `Icon101`–`Icon105` / `Icon201`–`Icon205` for squadmates, with paired `mapIcon*` and `mappingBG*` paths. `InitPowerIcons()` resolves these paths to GFx values. The paths prove a fixed authored set of 18 slots in the currently used interface. Direct SWF timeline/ActionScript inspection has not yet been done, so the exact clip tree and hit regions are not independently verified.

Existing `Hide()` / `SetVisible(TRUE)` calls target icon values, while `AS_ShowWheel()` controls overall wheel visibility. This supports an icon-only experiment without an SWF edit. Whether hidden clips retain active hit areas requires gameplay testing.
