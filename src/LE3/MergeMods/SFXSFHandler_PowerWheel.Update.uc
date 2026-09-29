public event function Update(float fDeltaT)
{
    local GFxValue oIcon;
    local GFxValue oMapped;
    local ASDisplayInfo oDisplay;
    local string sState;
    local string sPhase;
    local float fAlpha;
    local int nIcon;
    local int nState;
    local Name nmHovered;
    local Name nmCandidate;
    local GFxValue oStateClip;
    local ASColorTransform oTint;
    local float fPulse;

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

    // Reapply after the native update: the SWF can dim a different state on hover.
    // Real time keeps the pulse moving while the power wheel slows game time.
    if (m_nCurrentPowerIconIndex >= 0 && m_nCurrentPowerIconIndex < m_aPowerIcons.Length && m_aPowerIcons[m_nCurrentPowerIconIndex].pPower != None)
    {
        nmHovered = m_aPowerIcons[m_nCurrentPowerIconIndex].pPower.PowerName;
        if (nmHovered == 'Pull' || nmHovered == 'Flare')
        {
            fPulse = 0.5 + 0.5 * Sin(m_pPlayerController.WorldInfo.RealTimeSeconds * 5.2);
            oTint.Multiply.A = 1.0;
            for (nIcon = 0; nIcon < m_aPowerIcons.Length; ++nIcon)
            {
                if (m_oPowerIndices.aPlayer.Find(nIcon) == -1 || m_aPowerIcons[nIcon].pPower == None)
                {
                    continue;
                }
                nmCandidate = m_aPowerIcons[nIcon].pPower.PowerName;
                if (nmCandidate != 'Pull' && nmCandidate != 'Flare')
                {
                    continue;
                }
                // GFx additive terms use 0-255 color units. A fixed RGB target
                // gives the same brightness across the SWF's different states.
                oTint.Multiply.R = 0.0;
                oTint.Multiply.G = 0.0;
                oTint.Multiply.B = 0.0;
                oTint.Add.R = nmCandidate == 'Pull' ? 0.0 : 190.0 + 40.0 * fPulse;
                oTint.Add.G = nmCandidate == 'Pull' ? 75.0 + 25.0 * fPulse : 0.0;
                oTint.Add.B = nmCandidate == 'Pull' ? 190.0 + 40.0 * fPulse : 0.0;
                for (nState = 0; nState < 8; ++nState)
                {
                    if (nState != int(m_aPowerIcons[nIcon].eState) && nState != int(m_aPowerIcons[nIcon].eDesiredState))
                    {
                        continue;
                    }
                    oStateClip = GetVariableObject(m_aPowerIcons[nIcon].sPath $ ".powerIconMC.sub." $ m_aPowerIcons[nIcon].m_aPowerStatePaths[nState]);
                    if (oStateClip != None)
                    {
                        oStateClip.SetColorTransform(oTint);
                    }
                }
            }
        }
    }
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
