public event function Update(float fDeltaT)
{
    local array<GFxValue> aEPWTemps;
    local GFxValue oIcon;
    local ASDisplayInfo oDisplay;
    local string sState;
    local string sPhase;
    local float fAlpha;
    local int nIcon;
    local int nState;
    local Name nmHovered;
    local Name nmCandidate;
    local int nHoveredPrimer;
    local int nCandidateDetonator;
    local bool bDetonatorOutline;
    local GFxValue oStateClip;
    local GFxValue oOutline;
    local float fComboFade;
    local array<ASValue> aArgs;
    local float fPulse;
    local int nSlot;
    local int nSelectedSlot;
    local bool bMoveOutline;
    local bool bSquadMoving;
    local bool bMoveTarget;
    local bool bMoveVisible;
    local int nVisualState;
    local int nVisualDesiredState;
    local int nSquadSelected;
    local string sStatePath;
    local string sOutlinePath;

    Super.Update(fDeltaT);
    // Closed movies can still Advance (including inactive input-device movies).
    if (!m_bVisible) { EPWReleaseTemps(aEPWTemps); return; }
    if ((m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers || m_ePowerWheelMode == SFXPowerWheelMode.PWM_PC) && m_aPowerIconInfo.Length > 0 && m_aPowerIconInfo[0].Id == "P")
    {
        HandleInputEvent(BioGuiEvents.BIOGUI_EVENT_BUTTON_LTHUMB, -1.0);
    }
    if ((m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers || m_ePowerWheelMode == SFXPowerWheelMode.PWM_PC) && m_aPowerIcons.Length > 0 && m_aPowerIconInfo.Length > 0 && Len(m_aPowerIconInfo[0].Id) >= 18 && m_aPowerIcons[0].GetBool("EPWOpeningPending"))
    {
        // Reveal the opening only after the saved page and badges are ready.
        for (nIcon = 0; nIcon < m_aPowerIcons.Length; ++nIcon)
        {
            oDisplay = m_aPowerIcons[nIcon].GetDisplayInfo();
            oDisplay.hasAlpha = TRUE;
            oDisplay.Alpha = 100.0;
            m_aPowerIcons[nIcon].SetDisplayInfo(oDisplay);
            m_aPowerIcons[nIcon].SetBool("EPWOpeningPending", FALSE);

            if (m_aPowerIcons[nIcon].oMappedIcon.sPath != "") { SetVariableNumber(m_aPowerIcons[nIcon].oMappedIcon.sPath $ "._alpha", 100.0); }
            if (m_aPowerIcons[nIcon].sMappedBGPath != "") { SetVariableNumber(m_aPowerIcons[nIcon].sMappedBGPath $ "._alpha", 100.0); }
        }
    }
    EPWUpdateSwitchHint(m_aPowerIconInfo.Length > 0 && m_aPowerIconInfo[0].Id != "");
    EPWTraceHelp();
    if (m_ePowerWheelMode != SFXPowerWheelMode.PWM_Powers && m_ePowerWheelMode != SFXPowerWheelMode.PWM_PC)
    {
        EPWReleaseTemps(aEPWTemps); return;
    }
    if (m_aPowerIconInfo.Length == 0)
    {
        EPWReleaseTemps(aEPWTemps); return;
    }
    sState = m_aPowerIconInfo[0].Id;
    if (sState == "")
    {
        EPWReleaseTemps(aEPWTemps); return;
    }
    EPWUpdateSuggestedDisplay();
    EPWRefreshMappingIcons();
    sPhase = Mid(sState, 18, 1);

    // The SWF border shape is unnamed, so an empty clip traces its authored
    // geometry above the state. Only compatible detonators of a hovered
    // primer receive a red outline; dual-role powers still act as primers.
    if (m_nCurrentPowerIconIndex >= 0 && m_nCurrentPowerIconIndex < m_aPowerIcons.Length && m_aPowerIcons[m_nCurrentPowerIconIndex].pPower != None)
    {
        nmHovered = m_aPowerIcons[m_nCurrentPowerIconIndex].pPower.PowerName;
        nHoveredPrimer = EPWPrimerMask(nmHovered);
        // Real time keeps the entry fade independent of paused game time.
        fComboFade = FClamp((m_pPlayerController.WorldInfo.RealTimeSeconds - m_aPowerIcons[m_nCurrentPowerIconIndex].GetNumber("EPWComboHoverStart")) / 0.2, 0.0, 1.0);
        fComboFade = fComboFade * fComboFade * (3.0 - 2.0 * fComboFade);
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
            nCandidateDetonator = EPWDetonatorMask(m_aPowerIcons[nIcon].pPower);
            bDetonatorOutline = (nHoveredPrimer & nCandidateDetonator) != 0;
            if (!bDetonatorOutline)
            {
                continue;
            }
            fPulse = 0.5 + 0.5 * Sin(m_pPlayerController.WorldInfo.RealTimeSeconds * 7.5);
            fPulse *= fPulse;
            for (nState = 0; nState < 8; ++nState)
            {
                if (nState != nVisualState && nState != nVisualDesiredState)
                {
                    continue;
                }
                sStatePath = m_aPowerIcons[nIcon].sPath $ ".powerIconMC.sub." $ m_aPowerIcons[nIcon].m_aPowerStatePaths[nState];
                sOutlinePath = sStatePath $ ".EPWComboOutlineRed";
                if (!GetVariableBool(sOutlinePath $ ".EPWCreated"))
                {
                    oStateClip = EPWTempValue(GetVariableObject(sStatePath), aEPWTemps);
                    if (oStateClip == None) { continue; }
                    oOutline = EPWTempValue(oStateClip.CreateEmptyMovieClip("EPWComboOutlineRed", 100), aEPWTemps);
                    if (oOutline == None)
                    {
                        continue;
                    }
                    // Line thickness is in Flash pixels. Colors are 0xRRGGBB.
                    aArgs.Length = 3;
                    aArgs[0].Type = ASType.AS_Number;
                    aArgs[1].Type = ASType.AS_Number;
                    aArgs[2].Type = ASType.AS_Number;
                    aArgs[0].N = 2.0;
                    aArgs[1].N = 15222349.0;
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
                SetVariableBool(sOutlinePath $ ".EPWCreated", TRUE);
                SetVariableBool(sOutlinePath $ ".EPWComboActive", TRUE);
                SetVariableBool(sOutlinePath $ ".EPWComboFadingOut", FALSE);
                SetVariableBool(sOutlinePath $ "._visible", TRUE);
                SetVariableNumber(sOutlinePath $ "._alpha", (56.0 + 28.0 * fPulse) * fComboFade);
            }
        }
    }
    // Keep the picked power marked while the joystick moves or the page changes.
    // The eight player clips are reused across pages, so update visibility by
    // physical slot every frame rather than storing a GFx clip reference.
    nSelectedSlot = InStr("ABCDEFGHIJKLMNOP", Mid(sState, 16, 1));
    nSquadSelected = int(GetVariableNumber(m_sWheelInnerPath $ ".EPWSquadSelected")) - 1;
    bSquadMoving = nSquadSelected >= 0 && nSquadSelected < m_aPowerIcons.Length && (m_ePowerWheelMode == SFXPowerWheelMode.PWM_PC ? m_aPowerIcons[nSquadSelected].GetBool("_visible") : m_aPowerIcons[nSquadSelected].bVisible) && EPWHasPower(m_aPowerIcons[nSquadSelected]);
    for (nIcon = 0; nIcon < m_aPowerIcons.Length; ++nIcon)
    {
        nSlot = m_oPowerIndices.aPlayer.Find(nIcon);
        nVisualState = int(m_aPowerIcons[nIcon].GetNumber("EPWVisualState"));
        nVisualDesiredState = int(m_aPowerIcons[nIcon].GetNumber("EPWVisualDesiredState"));
        // Match LB's character-owned destinations, including empty slots.
        // Shepard can cross pages; each companion stays within its own side.
        // PC uses the same clip visibility and physical ownership as its drop.
        bMoveVisible = m_ePowerWheelMode == SFXPowerWheelMode.PWM_PC ? m_aPowerIcons[nIcon].GetBool("_visible") : m_aPowerIcons[nIcon].bVisible;
        bMoveTarget = (nSelectedSlot >= 0 && nSlot >= 0) || (bSquadMoving && (m_ePowerWheelMode == SFXPowerWheelMode.PWM_PC ? Left(m_aPowerIcons[nSquadSelected].sID, 6) == Left(m_aPowerIcons[nIcon].sID, 6) : ((m_oPowerIndices.aHench1.Find(nSquadSelected) >= 0 && m_oPowerIndices.aHench1.Find(nIcon) >= 0) || (m_oPowerIndices.aHench2.Find(nSquadSelected) >= 0 && m_oPowerIndices.aHench2.Find(nIcon) >= 0))));
        bMoveOutline = sPhase != "O" && ((nSlot >= 0 && nSelectedSlot == nSlot + int(Mid(sState, 17, 1)) * 8) || (nIcon == nSquadSelected && bMoveVisible && EPWHasPower(m_aPowerIcons[nIcon])) || (bMoveTarget && nIcon == m_nCurrentPowerIconIndex && bMoveVisible));
        for (nState = 0; nState < 8; ++nState)
        {
            sStatePath = m_aPowerIcons[nIcon].sPath $ ".powerIconMC.sub." $ m_aPowerIcons[nIcon].m_aPowerStatePaths[nState];
            sOutlinePath = sStatePath $ ".EPWComboOutlineRed";
            // Existing outlines animate through scalar paths, without wrappers.
            if (GetVariableBool(sOutlinePath $ ".EPWComboFadingOut"))
            {
                fComboFade = FClamp((m_pPlayerController.WorldInfo.RealTimeSeconds - GetVariableNumber(sOutlinePath $ ".EPWComboExitStart")) / 0.2, 0.0, 1.0);
                fComboFade = fComboFade * fComboFade * (3.0 - 2.0 * fComboFade);
                SetVariableNumber(sOutlinePath $ "._alpha", GetVariableNumber(sOutlinePath $ ".EPWComboExitAlpha") * (1.0 - fComboFade));
                if (fComboFade >= 1.0)
                {
                    SetVariableBool(sOutlinePath $ "._visible", FALSE);
                    SetVariableBool(sOutlinePath $ ".EPWComboActive", FALSE);
                    SetVariableBool(sOutlinePath $ ".EPWComboFadingOut", FALSE);
                }
            }
            sOutlinePath = sStatePath $ ".EPWMoveOutlineGreen";
            if (!GetVariableBool(sOutlinePath $ ".EPWCreated") && bMoveOutline && (nState == nVisualState || nState == nVisualDesiredState))
            {
                oStateClip = EPWTempValue(GetVariableObject(sStatePath), aEPWTemps);
                if (oStateClip == None) { continue; }
                oOutline = EPWTempValue(oStateClip.CreateEmptyMovieClip("EPWMoveOutlineGreen", 102), aEPWTemps);
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
                SetVariableBool(sOutlinePath $ ".EPWCreated", TRUE);
            }
            if (GetVariableBool(sOutlinePath $ ".EPWCreated"))
            {
                SetVariableBool(sOutlinePath $ "._visible", bMoveOutline && (nState == nVisualState || nState == nVisualDesiredState));
            }
        }
    }
    if (sPhase != "O" && sPhase != "I")
    {
        EPWReleaseTemps(aEPWTemps); return;
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
        EPWReleaseTemps(aEPWTemps); return;
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

        if (m_aPowerIcons[nIcon].oMappedIcon.sPath != "") { SetVariableNumber(m_aPowerIcons[nIcon].oMappedIcon.sPath $ "._alpha", fAlpha); }
        if (m_aPowerIcons[nIcon].sMappedBGPath != "") { SetVariableNumber(m_aPowerIcons[nIcon].sMappedBGPath $ "._alpha", fAlpha); }
    }
    EPWReleaseTemps(aEPWTemps);
}
