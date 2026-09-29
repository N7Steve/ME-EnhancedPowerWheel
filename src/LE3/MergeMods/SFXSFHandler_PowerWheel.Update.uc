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
    local GFxValue oOutline;
    local array<ASValue> aArgs;
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

    // Draw only the complementary power's outline. The SWF border shape is
    // unnamed, so an empty clip traces its authored geometry above the state.
    if (m_nCurrentPowerIconIndex >= 0 && m_nCurrentPowerIconIndex < m_aPowerIcons.Length && m_aPowerIcons[m_nCurrentPowerIconIndex].pPower != None)
    {
        nmHovered = m_aPowerIcons[m_nCurrentPowerIconIndex].pPower.PowerName;
        if (nmHovered == 'Pull' || nmHovered == 'Flare')
        {
            fPulse = 0.5 + 0.5 * Sin(m_pPlayerController.WorldInfo.RealTimeSeconds * 5.2);
            for (nIcon = 0; nIcon < m_aPowerIcons.Length; ++nIcon)
            {
                if (m_oPowerIndices.aPlayer.Find(nIcon) == -1 || m_aPowerIcons[nIcon].pPower == None)
                {
                    continue;
                }
                nmCandidate = m_aPowerIcons[nIcon].pPower.PowerName;
                if ((nmHovered == 'Pull' && nmCandidate != 'Flare') || (nmHovered == 'Flare' && nmCandidate != 'Pull'))
                {
                    continue;
                }
                for (nState = 0; nState < 8; ++nState)
                {
                    if (nState != int(m_aPowerIcons[nIcon].eState) && nState != int(m_aPowerIcons[nIcon].eDesiredState))
                    {
                        continue;
                    }
                    oStateClip = GetVariableObject(m_aPowerIcons[nIcon].sPath $ ".powerIconMC.sub." $ m_aPowerIcons[nIcon].m_aPowerStatePaths[nState]);
                    if (oStateClip == None)
                    {
                        continue;
                    }
                    oOutline = oStateClip.GetObject("EPWComboOutline");
                    if (oOutline == None)
                    {
                        oOutline = oStateClip.CreateEmptyMovieClip("EPWComboOutline", 100);
                        if (oOutline == None)
                        {
                            continue;
                        }
                        // Line thickness is in Flash pixels. Colors are 0xRRGGBB.
                        aArgs.Length = 3;
                        aArgs[0].Type = ASType.AS_Number;
                        aArgs[1].Type = ASType.AS_Number;
                        aArgs[2].Type = ASType.AS_Number;
                        aArgs[0].N = 0.85;
                        aArgs[1].N = nmCandidate == 'Flare' ? 15222349.0 : 9072854.0;
                        aArgs[2].N = 100.0;
                        oOutline.Invoke("lineStyle", aArgs);
                        aArgs.Length = 2;
                        aArgs[0].N = -37.0;
                        aArgs[1].N = -6.45;
                        oOutline.Invoke("moveTo", aArgs);
                        aArgs.Length = 4;
                        aArgs[2].Type = ASType.AS_Number;
                        aArgs[3].Type = ASType.AS_Number;
                        aArgs[0].N = -10.2;
                        aArgs[1].N = -11.25;
                        aArgs[2].N = 16.65;
                        aArgs[3].N = -4.95;
                        oOutline.Invoke("curveTo", aArgs);
                        aArgs.Length = 2;
                        aArgs[0].N = 16.65;
                        aArgs[1].N = 22.9;
                        oOutline.Invoke("lineTo", aArgs);
                        aArgs[0].N = 6.05;
                        aArgs[1].N = 33.55;
                        oOutline.Invoke("lineTo", aArgs);
                        aArgs[0].N = -33.6;
                        aArgs[1].N = 33.55;
                        oOutline.Invoke("lineTo", aArgs);
                        aArgs[0].N = -44.25;
                        aArgs[1].N = 22.9;
                        oOutline.Invoke("lineTo", aArgs);
                        aArgs[0].N = -44.25;
                        aArgs[1].N = -4.95;
                        oOutline.Invoke("lineTo", aArgs);
                        aArgs[0].N = -37.0;
                        aArgs[1].N = -6.45;
                        oOutline.Invoke("lineTo", aArgs);
                    }
                    oOutline.SetVisible(TRUE);
                    oDisplay = oOutline.GetDisplayInfo();
                    oDisplay.hasAlpha = TRUE;
                    oDisplay.Alpha = nmCandidate == 'Flare' ? 38.0 + 16.0 * fPulse : 18.0 + 10.0 * fPulse;
                    oOutline.SetDisplayInfo(oDisplay);
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
