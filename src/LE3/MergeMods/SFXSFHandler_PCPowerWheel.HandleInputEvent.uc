public event function bool HandleInputEvent(BioGuiEvents Event, optional float fValue = 1.0)
{
    if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_PC)
    {
        // The PC movie also remains loaded for the gameplay HUD.
        if (!m_bVisible) { return Super(SFXGUIMovie).HandleInputEvent(Event, fValue); }
        if (Event == BioGuiEvents.BIOGUI_EVENT_MOUSE_BUTTON_LEFT_RELEASE)
        {
            EPWPCFinishDrag();
        }
        // Only EPW's internal redraw/order/page requests enter the shared engine.
        // Mouse, Escape and native keyboard shortcuts remain available mid-fade.
        if (Event == BioGuiEvents.BIOGUI_EVENT_BUTTON_LTHUMB || Event == BioGuiEvents.BIOGUI_EVENT_BUTTON_RTHUMB || (Event == BioGuiEvents.BIOGUI_EVENT_BUTTON_LB && fValue < 0.0))
        {
            return Super.HandleInputEvent(Event, fValue);
        }
        return Super(SFXGUIMovie).HandleInputEvent(Event, fValue);
    }
    return Super.HandleInputEvent(Event, fValue);
}
