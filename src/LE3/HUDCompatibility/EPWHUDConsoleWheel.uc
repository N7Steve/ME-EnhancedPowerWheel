// Original compatibility subclass. HUD's visibility/input behavior stays inherited.
class EPWHUDConsoleWheel extends SFXModHandler_HybridPowerWheel_Console
    config(UI);

public event function Update(float fDeltaT)
{
    // HUD's serialized inherited Update targets the legacy adapter.
    // Call EPW's implementation explicitly; it retains its own Super.Update.
    Super(SFXSFHandler_PowerWheel).Update(fDeltaT);
}

defaultproperties
{
}
