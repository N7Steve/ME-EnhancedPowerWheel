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
    local int nHoveredPrimer;
    local int nHoveredDetonator;
    local int nCandidatePrimer;
    local int nCandidateDetonator;
    local bool bDetonatorOutline;
    local bool bPrimerOutline;
    local GFxValue oStateClip;
    local GFxValue oOutline;
    local string sOutlineName;
    local array<ASValue> aArgs;
    local float fPulse;
    local int nSlot;
    local int nSelectedSlot;
    local bool bMoveOutline;
    local int nVisualState;
    local int nVisualDesiredState;

    Super.Update(fDeltaT);
    if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers && m_aPowerIconInfo.Length > 0 && m_aPowerIconInfo[0].Id == "P")
    {
        HandleInputEvent(BioGuiEvents.BIOGUI_EVENT_BUTTON_LTHUMB, -1.0);
    }
    if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers && m_aPowerIcons.Length > 0 && m_aPowerIconInfo.Length > 0 && Len(m_aPowerIconInfo[0].Id) >= 18 && m_aPowerIcons[0].GetBool("EPWOpeningPending"))
    {
        // Reveal the opening only after the saved page and badges are ready.
        for (nIcon = 0; nIcon < m_aPowerIcons.Length; ++nIcon)
        {
            oDisplay = m_aPowerIcons[nIcon].GetDisplayInfo();
            oDisplay.hasAlpha = TRUE;
            oDisplay.Alpha = 100.0;
            m_aPowerIcons[nIcon].SetDisplayInfo(oDisplay);
            m_aPowerIcons[nIcon].SetBool("EPWOpeningPending", FALSE);

            oMapped = GetVariableObject(m_aPowerIcons[nIcon].oMappedIcon.sPath);
            if (oMapped != None)
            {
                oDisplay = oMapped.GetDisplayInfo();
                oDisplay.hasAlpha = TRUE;
                oDisplay.Alpha = 100.0;
                oMapped.SetDisplayInfo(oDisplay);
            }
            oMapped = GetVariableObject(m_aPowerIcons[nIcon].sMappedBGPath);
            if (oMapped != None)
            {
                oDisplay = oMapped.GetDisplayInfo();
                oDisplay.hasAlpha = TRUE;
                oDisplay.Alpha = 100.0;
                oMapped.SetDisplayInfo(oDisplay);
            }
        }
    }
    EPWUpdateSwitchHint(m_aPowerIconInfo.Length > 0 && m_aPowerIconInfo[0].Id != "");
    EPWTraceHelp();
    if (m_ePowerWheelMode != SFXPowerWheelMode.PWM_Powers)
    {
        return;
    }
    if (m_aPowerIconInfo.Length == 0)
    {
        return;
    }
    sState = m_aPowerIconInfo[0].Id;
    if (sState == "")
    {
        return;
    }
    EPWUpdateSuggestedDisplay();
    EPWRefreshMappingIcons();
    sPhase = Mid(sState, 18, 1);

    // The SWF border shape is unnamed, so an empty clip traces its authored
    // geometry above the state. A red candidate detonates the hovered primer;
    // a violet candidate primes a combo the hovered power can detonate.
    if (m_nCurrentPowerIconIndex >= 0 && m_nCurrentPowerIconIndex < m_aPowerIcons.Length && m_aPowerIcons[m_nCurrentPowerIconIndex].pPower != None)
    {
        nmHovered = m_aPowerIcons[m_nCurrentPowerIconIndex].pPower.PowerName;
        nHoveredPrimer = EPWPrimerMask(nmHovered);
        nHoveredDetonator = EPWDetonatorMask(m_aPowerIcons[m_nCurrentPowerIconIndex].pPower);
        for (nIcon = 0; nIcon < m_aPowerIcons.Length; ++nIcon)
        {
            if (nIcon == m_nCurrentPowerIconIndex || m_aPowerIcons[nIcon].pPower == None || !m_aPowerIcons[nIcon].bVisible)
            {
                continue;
            }
            nmCandidate = m_aPowerIcons[nIcon].pPower.PowerName;
            nVisualState = int(m_aPowerIcons[nIcon].GetNumber("EPWVisualState"));
            nVisualDesiredState = int(m_aPowerIcons[nIcon].GetNumber("EPWVisualDesiredState"));
            // The game refuses to detonate a primer from the same PowerName.
            if (nmCandidate == nmHovered)
            {
                continue;
            }
            nCandidatePrimer = EPWPrimerMask(nmCandidate);
            nCandidateDetonator = EPWDetonatorMask(m_aPowerIcons[nIcon].pPower);
            bDetonatorOutline = (nHoveredPrimer & nCandidateDetonator) != 0;
            bPrimerOutline = (nCandidatePrimer & nHoveredDetonator) != 0;
            if (!bDetonatorOutline && !bPrimerOutline)
            {
                continue;
            }
            if (bDetonatorOutline)
            {
                fPulse = 0.5 + 0.5 * Sin(m_pPlayerController.WorldInfo.RealTimeSeconds * 7.5);
                fPulse *= fPulse;
            }
            else
            {
                fPulse = 0.5 + 0.5 * Sin(m_pPlayerController.WorldInfo.RealTimeSeconds * 2.2);
            }
            for (nState = 0; nState < 8; ++nState)
            {
                if (nState != nVisualState && nState != nVisualDesiredState)
                {
                    continue;
                }
                oStateClip = GetVariableObject(m_aPowerIcons[nIcon].sPath $ ".powerIconMC.sub." $ m_aPowerIcons[nIcon].m_aPowerStatePaths[nState]);
                if (oStateClip == None)
                {
                    continue;
                }
                sOutlineName = bDetonatorOutline ? "EPWComboOutlineRed" : "EPWComboOutlineViolet";
                oOutline = oStateClip.GetObject(sOutlineName);
                if (oOutline == None)
                {
                    oOutline = oStateClip.CreateEmptyMovieClip(sOutlineName, bDetonatorOutline ? 100 : 101);
                    if (oOutline == None)
                    {
                        continue;
                    }
                    // Line thickness is in Flash pixels. Colors are 0xRRGGBB.
                    aArgs.Length = 3;
                    aArgs[0].Type = ASType.AS_Number;
                    aArgs[1].Type = ASType.AS_Number;
                    aArgs[2].Type = ASType.AS_Number;
                    aArgs[0].N = bDetonatorOutline ? 2.0 : 1.8;
                    aArgs[1].N = bDetonatorOutline ? 15222349.0 : 11177210.0;
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
                oDisplay.Alpha = bDetonatorOutline ? 56.0 + 28.0 * fPulse : 44.0 + 20.0 * fPulse;
                oOutline.SetDisplayInfo(oDisplay);
            }
        }
    }
    // Keep the picked power marked while the joystick moves or the page changes.
    // The eight player clips are reused across pages, so update visibility by
    // physical slot every frame rather than storing a GFx clip reference.
    nSelectedSlot = InStr("ABCDEFGHIJKLMNOP", Mid(sState, 16, 1));
    for (nSlot = 0; nSlot < 8; ++nSlot)
    {
        nIcon = m_oPowerIndices.aPlayer[nSlot];
        nVisualState = int(m_aPowerIcons[nIcon].GetNumber("EPWVisualState"));
        nVisualDesiredState = int(m_aPowerIcons[nIcon].GetNumber("EPWVisualDesiredState"));
        bMoveOutline = sPhase != "O" && nSelectedSlot == nSlot + int(Mid(sState, 17, 1)) * 8;
        for (nState = 0; nState < 8; ++nState)
        {
            oStateClip = GetVariableObject(m_aPowerIcons[nIcon].sPath $ ".powerIconMC.sub." $ m_aPowerIcons[nIcon].m_aPowerStatePaths[nState]);
            if (oStateClip == None)
            {
                continue;
            }
            oOutline = oStateClip.GetObject("EPWMoveOutlineGreen");
            if (oOutline == None && bMoveOutline && (nState == nVisualState || nState == nVisualDesiredState))
            {
                oOutline = oStateClip.CreateEmptyMovieClip("EPWMoveOutlineGreen", 102);
                if (oOutline == None)
                {
                    continue;
                }
                aArgs.Length = 3;
                aArgs[0].Type = ASType.AS_Number;
                aArgs[1].Type = ASType.AS_Number;
                aArgs[2].Type = ASType.AS_Number;
                aArgs[0].N = 2.2;
                aArgs[1].N = 44409.0; // 0x00AD79, distinct from combo red/violet.
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
            if (oOutline != None)
            {
                oOutline.SetVisible(bMoveOutline && (nState == nVisualState || nState == nVisualDesiredState));
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
