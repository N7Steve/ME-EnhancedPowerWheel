public event function Update(float fDeltaT)
{
    Super.Update(fDeltaT);
    if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers && m_aPowerIconInfo.Length > 0 && m_aPowerIconInfo[0].Id == "P")
    {
        HandleInputEvent(BioGuiEvents.BIOGUI_EVENT_BUTTON_LTHUMB, -1.0);
    }
}
