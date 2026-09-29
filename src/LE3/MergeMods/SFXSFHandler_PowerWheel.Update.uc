public event function Update(float fDeltaT)
{
    local GFxValue oWheel;
    local ASDisplayInfo oDisplay;
    local string sState;
    local string sPhase;
    local float fAlpha;

    Super.Update(fDeltaT);
    if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers && m_aPowerIconInfo.Length > 0 && m_aPowerIconInfo[0].Id == "P")
    {
        HandleInputEvent(BioGuiEvents.BIOGUI_EVENT_BUTTON_LTHUMB, -1.0);
    }
    if (m_ePowerWheelMode != SFXPowerWheelMode.PWM_Powers)
    {
        return;
    }
    if (m_aPowerIconInfo.Length == 0)
    {
        return;
    }
    sState = m_aPowerIconInfo[0].Id;
    sPhase = Mid(sState, 18, 1);
    if (sPhase != "O" && sPhase != "I")
    {
        return;
    }

    oWheel = GetVariableObject(m_sWheelInnerPath);
    if (oWheel == None)
    {
        // If the authored clip is missing, keep page switching functional.
        if (sPhase == "O")
        {
            if (Mid(sState, 17, 1) == "1")
            {
                HandleInputEvent(BioGuiEvents.BIOGUI_EVENT_BUTTON_RTHUMB, -1.0);
            }
            else
            {
                HandleInputEvent(BioGuiEvents.BIOGUI_EVENT_BUTTON_LTHUMB, -1.0);
            }
        }
        m_aPowerIconInfo[0].Id = Left(m_aPowerIconInfo[0].Id, 18);
        return;
    }

    oDisplay = oWheel.GetDisplayInfo();
    oDisplay.hasAlpha = TRUE;
    fAlpha = oDisplay.Alpha;
    if (sPhase == "O")
    {
        fAlpha -= fDeltaT * 600.0;
        if (fAlpha <= 0.0)
        {
            oDisplay.Alpha = 0.0;
            oWheel.SetDisplayInfo(oDisplay);
            if (Mid(sState, 17, 1) == "1")
            {
                HandleInputEvent(BioGuiEvents.BIOGUI_EVENT_BUTTON_RTHUMB, -1.0);
            }
            else
            {
                HandleInputEvent(BioGuiEvents.BIOGUI_EVENT_BUTTON_LTHUMB, -1.0);
            }
            m_aPowerIconInfo[0].Id $= "I";
            return;
        }
    }
    else
    {
        fAlpha += fDeltaT * 600.0;
        if (fAlpha >= 100.0)
        {
            fAlpha = 100.0;
            m_aPowerIconInfo[0].Id = Left(sState, 18);
        }
    }
    oDisplay.Alpha = fAlpha;
    oWheel.SetDisplayInfo(oDisplay);
}
