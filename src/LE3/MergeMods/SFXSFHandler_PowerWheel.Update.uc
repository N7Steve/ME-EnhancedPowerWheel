public event function Update(float fDeltaT)
{
    local GFxValue oIcon;
    local GFxValue oMapped;
    local ASDisplayInfo oDisplay;
    local string sState;
    local string sPhase;
    local float fAlpha;
    local int nIcon;

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

    if (m_aPowerIcons.Length > 0)
    {
        oIcon = m_aPowerIcons[0];
    }
    if (oIcon == None)
    {
        // If the authored icons are missing, keep page switching functional.
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

    oDisplay = oIcon.GetDisplayInfo();
    fAlpha = oDisplay.Alpha;
    if (sPhase == "O")
    {
        fAlpha -= fDeltaT * 600.0;
        if (fAlpha <= 0.0)
        {
            fAlpha = 0.0;
            if (Mid(sState, 17, 1) == "1")
            {
                HandleInputEvent(BioGuiEvents.BIOGUI_EVENT_BUTTON_RTHUMB, -1.0);
            }
            else
            {
                HandleInputEvent(BioGuiEvents.BIOGUI_EVENT_BUTTON_LTHUMB, -1.0);
            }
            m_aPowerIconInfo[0].Id $= "I";
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
    // The inner wheel clip also contains portraits and the screen overlay.
    // Fade only the power icons and their separate mapping clips.
    for (nIcon = 0; nIcon < m_aPowerIcons.Length; ++nIcon)
    {
        oDisplay = m_aPowerIcons[nIcon].GetDisplayInfo();
        oDisplay.hasAlpha = TRUE;
        oDisplay.Alpha = fAlpha;
        m_aPowerIcons[nIcon].SetDisplayInfo(oDisplay);

        oMapped = GetVariableObject(m_aPowerIcons[nIcon].oMappedIcon.sPath);
        if (oMapped != None)
        {
            oDisplay = oMapped.GetDisplayInfo();
            oDisplay.hasAlpha = TRUE;
            oDisplay.Alpha = fAlpha;
            oMapped.SetDisplayInfo(oDisplay);
        }
        oMapped = GetVariableObject(m_aPowerIcons[nIcon].sMappedBGPath);
        if (oMapped != None)
        {
            oDisplay = oMapped.GetDisplayInfo();
            oDisplay.hasAlpha = TRUE;
            oDisplay.Alpha = fAlpha;
            oMapped.SetDisplayInfo(oDisplay);
        }
    }
}
