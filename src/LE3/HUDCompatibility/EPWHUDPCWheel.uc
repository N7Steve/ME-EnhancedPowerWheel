// Original compatibility subclass; retain HUD radar, quickslots and camera handling.
class EPWHUDPCWheel extends SFXModHandler_HybridPowerWheel_PC
    config(UI);

public event function Update(float fDeltaT)
{
    // HUD maintains its private radar/quickslot state here. Its adapter Update
    // is empty in the supported package, which the builder verifies.
    Super.Update(fDeltaT);
    // Run EPW opening redraw, reveal, fade and PC drag/Space processing.
    Super(SFXSFHandler_PCPowerWheel).Update(fDeltaT);
}

public event function bool HandleInputEvent(BioGuiEvents Event, optional float fValue = 1.0)
{
    // HUD owns right-button camera look and non-PC wheel input.
    if (m_ePowerWheelMode != SFXPowerWheelMode.PWM_PC || Event == BioGuiEvents.BIOGUI_EVENT_MOUSE_BUTTON_RIGHT || Event == BioGuiEvents.BIOGUI_EVENT_MOUSE_BUTTON_RIGHT_RELEASE)
    {
        return Super.HandleInputEvent(Event, fValue);
    }
    // HUD's default route bypasses EPW's PC release and fade-safe input handling.
    return Super(SFXSFHandler_PCPowerWheel).HandleInputEvent(Event, fValue);
}

defaultproperties
{
}
