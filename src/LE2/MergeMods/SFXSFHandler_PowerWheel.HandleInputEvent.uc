public function HandleInputEvent(BioGuiEvents Event, optional float fValue = 1.0)
{
    local int nPage;
    local int nSlot;
    local int nAbsoluteSlot;
    local int nSelected;
    local string sMap;
    local string sSource;
    local string sTarget;
    local array<SFXPowerWheelIconPower> aSources;
    local array<string> aSourceCounters;
    local SFXPowerWheelIconPower oPhysical;
    local SFXPowerWheelIconPower oEmpty;
    local SFXPowerWheelPowerState eDisplayState;
    local SFXPowerWheelMapButtonIcon eMapping;
    local int nIcon;
    local int nSource;
    local int nState;
    local int nSeen;
    local int nPreviousHover;
    local bool bValid;
    local bool bVisible;
    local string sSignature;
    local string sSquadVisibility;
    local string sStatePath;

    // Negative L3 is the internal redraw; real R3 switches pages through a fade.
    if (Event == BioGuiEvents.BIOGUI_EVENT_BUTTON_LTHUMB && fValue < 0.0)
    {
        if (oPanel == None || m_ePowerWheelMode != SFXPowerWheelMode.PWM_Powers || m_oPowerIndices.aPlayer.Length != 8)
        {
            return;
        }
        for (nSlot = 0; nSlot < 8; ++nSlot)
        {
            nIcon = m_oPowerIndices.aPlayer[nSlot];
            if (nIcon < 0 || nIcon >= m_aPowerIcons.Length)
            {
                return;
            }
        }
        nPreviousHover = m_nCurrentPowerIconIndex;
        LeavePowerIcon(m_nCurrentPowerIconIndex, TRUE);
        // Clear destination counters before native setup can write source counters.
        // These Flash fields are separate from the icon data and survive reassignment.
        for (nSlot = 0; nSlot < 8; ++nSlot)
        {
            nIcon = m_oPowerIndices.aPlayer[nSlot];
            oPanel.SetTextFieldText(m_aPowerIcons[nIcon].sPath $ ".powerIconMC.sub.txtInfo", "");
        }
        // Empty the physical player data before collecting native source order.
        for (nSlot = 0; nSlot < 8; ++nSlot)
        {
            nIcon = m_oPowerIndices.aPlayer[nSlot];
            m_aPowerIcons[nIcon].pPower = None;
            m_aPowerIcons[nIcon].pPawn = None;
            m_aPowerIcons[nIcon].nmPowerName = 'None';
            m_aPowerIcons[nIcon].sName = "";
            m_aPowerIcons[nIcon].sDescription = "";
            m_aPowerIcons[nIcon].nIcon = 0;
            m_aPowerIcons[nIcon].nPowerID = -1;
            m_aPowerIcons[nIcon].bMapped = FALSE;
            m_aPowerIcons[nIcon].oMappedIcon.eIcon = SFXPowerWheelMapButtonIcon.PWBI_Icon_NONE;
            m_aPowerIcons[nIcon].bSelected = FALSE;
            m_aPowerIcons[nIcon].eState = SFXPowerWheelPowerState.PWPS_EmptySelectable;
            m_aPowerIcons[nIcon].eDesiredState = SFXPowerWheelPowerState.PWPS_EmptySelectable;
        }
        SetupPlayerPowers();
        for (nSlot = 0; nSlot < 8; ++nSlot)
        {
            nIcon = m_oPowerIndices.aPlayer[nSlot];
            aSources.AddItem(m_aPowerIcons[nIcon]);
            aSourceCounters.AddItem(oPanel.GetVariableString(m_aPowerIcons[nIcon].sPath $ ".powerIconMC.sub.txtInfo.text"));
            sSignature = sSignature $ string(m_aPowerIcons[nIcon].nmPowerName) $ ";";
        }

        sMap = oPanel.GetVariableString("EPWLE2Map");
        bValid = Len(sMap) == 16;
        for (nSlot = 0; nSlot < Len(sMap); ++nSlot)
        {
            nSource = InStr("01234567", Mid(sMap, nSlot, 1));
            if (nSource >= 0)
            {
                if ((nSeen & (1 << nSource)) != 0)
                {
                    bValid = FALSE;
                }
                nSeen = nSeen | (1 << nSource);
            }
            else if (Mid(sMap, nSlot, 1) != "-")
            {
                bValid = FALSE;
            }
        }
        if (!bValid || nSeen != 255 || oPanel.GetVariableString("EPWLE2Sources") != sSignature)
        {
            sMap = "01234567--------";
            oPanel.SetVariableString("EPWLE2Map", sMap);
            oPanel.SetVariableString("EPWLE2Sources", sSignature);
            oPanel.SetVariableInt("EPWLE2Selected", -1);
        }
        nPage = oPanel.GetVariableInt("EPWLE2Page");
        nPage = nPage == 1 ? 1 : 0;
        oPanel.SetVariableInt("EPWLE2Page", nPage);
        if (!oPanel.GetVariableBool("EPWLE2SquadCached"))
        {
            for (nIcon = 0; nIcon < m_aPowerIcons.Length; ++nIcon)
            {
                sSquadVisibility = sSquadVisibility $ (m_aPowerIcons[nIcon].bVisible ? "1" : "0");
            }
            oPanel.SetVariableString("EPWLE2SquadVisibility", sSquadVisibility);
            oPanel.SetVariableBool("EPWLE2SquadCached", TRUE);
        }
        sSquadVisibility = oPanel.GetVariableString("EPWLE2SquadVisibility");
        for (nIcon = 0; nIcon < m_aPowerIcons.Length; ++nIcon)
        {
            if (m_oPowerIndices.aPlayer.Find(nIcon) == -1)
            {
                bVisible = nPage == 0 && Mid(sSquadVisibility, nIcon, 1) == "1";
                m_aPowerIcons[nIcon].bVisible = bVisible;
                oPanel.SetClipVisibility(m_aPowerIcons[nIcon].sPath, bVisible);
                oPanel.SetClipVisibility(m_aPowerIcons[nIcon].oMappedIcon.sPath, bVisible && m_aPowerIcons[nIcon].bMapped);
                oPanel.SetClipVisibility(m_aPowerIcons[nIcon].sMappedBGPath, bVisible && m_aPowerIcons[nIcon].bMapped);
            }
        }
        for (nSlot = 0; nSlot < 8; ++nSlot)
        {
            nIcon = m_oPowerIndices.aPlayer[nSlot];
            oPhysical = m_aPowerIcons[nIcon];
            nSource = InStr("01234567", Mid(sMap, nPage * 8 + nSlot, 1));
            if (nSource >= 0 && aSources[nSource].pPower != None)
            {
                m_aPowerIcons[nIcon] = aSources[nSource];
                eDisplayState = aSources[nSource].eDesiredState;
                if (eDisplayState == SFXPowerWheelPowerState.PWPS_Selected || eDisplayState == SFXPowerWheelPowerState.PWPS_EmptySelectable || eDisplayState == SFXPowerWheelPowerState.PWPS_EmptySelected)
                {
                    eDisplayState = SFXPowerWheelPowerState.PWPS_Selectable;
                }
            }
            else
            {
                m_aPowerIcons[nIcon] = oEmpty;
                eDisplayState = SFXPowerWheelPowerState.PWPS_EmptySelectable;
            }
            // Clip paths, IDs and stick boundaries belong to the destination position.
            m_aPowerIcons[nIcon].sPath = oPhysical.sPath;
            m_aPowerIcons[nIcon].sID = oPhysical.sID;
            m_aPowerIcons[nIcon].fBoundary = oPhysical.fBoundary;
            m_aPowerIcons[nIcon].sMappedBGPath = oPhysical.sMappedBGPath;
            m_aPowerIcons[nIcon].oMappedIcon.sPath = oPhysical.oMappedIcon.sPath;
            m_aPowerIcons[nIcon].bVisible = TRUE;
            m_aPowerIcons[nIcon].bSelected = FALSE;
            m_aPowerIcons[nIcon].eDesiredState = eDisplayState;
            SetPowerIconState(nIcon, eDisplayState);
            // Force the initial artwork and empty states, before any joystick hover.
            oPanel.GotoLabelAndStop(m_aPowerIcons[nIcon].sPath, "normal");
            oPanel.SetClipVisibility(m_aPowerIcons[nIcon].sPath, TRUE);
            oPanel.SetClipVisibility(m_aPowerIcons[nIcon].sPath $ ".powerIconMC", TRUE);
            oPanel.SetClipVisibility(m_aPowerIcons[nIcon].sPath $ ".powerIconMC.sub", TRUE);
            for (nState = 0; nState < 8; ++nState)
            {
                sStatePath = m_aPowerIcons[nIcon].sPath $ ".powerIconMC.sub." $ m_aPowerStatePaths[nState];
                if (m_aPowerIcons[nIcon].pPower != None)
                {
                    oPanel.GotoFrameAndStop(sStatePath $ ".iconMC", m_aPowerIcons[nIcon].nIcon);
                }
                oPanel.SetClipVisibility(sStatePath, nState == int(eDisplayState));
            }
            // Always overwrite the counter, including empty and non-charge powers.
            if (nSource >= 0 && m_aPowerIcons[nIcon].pPower != None)
            {
                oPanel.SetTextFieldText(m_aPowerIcons[nIcon].sPath $ ".powerIconMC.sub.txtInfo", aSourceCounters[nSource]);
            }
            else
            {
                oPanel.SetTextFieldText(m_aPowerIcons[nIcon].sPath $ ".powerIconMC.sub.txtInfo", "");
            }
            eMapping = m_aPowerIcons[nIcon].oMappedIcon.eIcon;
            m_aPowerIcons[nIcon].oMappedIcon.eIcon = SFXPowerWheelMapButtonIcon.PWBI_Icon_NONE;
            SetMappingIcon(m_aPowerIcons[nIcon].oMappedIcon, eMapping);
            oPanel.SetClipVisibility(m_aPowerIcons[nIcon].oMappedIcon.sPath, m_aPowerIcons[nIcon].pPower != None && m_aPowerIcons[nIcon].bMapped);
            oPanel.SetClipVisibility(m_aPowerIcons[nIcon].sMappedBGPath, m_aPowerIcons[nIcon].pPower != None && m_aPowerIcons[nIcon].bMapped);
        }
        SetInformationText("", "");
        SetUseText("");
        SetMapText("", 0, "", 0);
        m_fLastProcessedStickAngle = -1.0;
        oPanel.SetVariableBool("EPWLE2Pending", FALSE);
        if (m_oPowerIndices.aPlayer.Find(nPreviousHover) >= 0)
        {
            HoverPowerIcon(nPreviousHover, TRUE);
        }
        EPWUpdateUI(TRUE);
        return;
    }

    if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers && oPanel != None)
    {
        if (oPanel.GetVariableInt("EPWLE2FadePhase") != 0)
        {
            // Leave close/back/menu events on their inherited path during animation.
            if (Event == BioGuiEvents.BIOGUI_EVENT_AXIS_LSTICK_X) { m_vLStickInput.X = fValue; }
            else if (Event == BioGuiEvents.BIOGUI_EVENT_AXIS_LSTICK_Y) { m_vLStickInput.Y = fValue; }
            else if (Event != BioGuiEvents.BIOGUI_EVENT_BUTTON_RTHUMB && Event != BioGuiEvents.BIOGUI_EVENT_BUTTON_LB && Event != BioGuiEvents.BIOGUI_EVENT_BUTTON_A && Event != BioGuiEvents.BIOGUI_EVENT_BUTTON_X && Event != BioGuiEvents.BIOGUI_EVENT_BUTTON_B && Event != BioGuiEvents.BIOGUI_EVENT_BUTTON_RTHUMB_RELEASE && Event != BioGuiEvents.BIOGUI_EVENT_BUTTON_LB_RELEASE)
            {
                Super.HandleInputEvent(Event, fValue);
            }
            return;
        }
        if (oPanel.GetVariableBool("EPWLE2Pending") || Len(oPanel.GetVariableString("EPWLE2Map")) != 16)
        {
            HandleInputEvent(BioGuiEvents.BIOGUI_EVENT_BUTTON_LTHUMB, -1.0);
        }
        nPage = oPanel.GetVariableInt("EPWLE2Page");
        if (Event == BioGuiEvents.BIOGUI_EVENT_BUTTON_RTHUMB)
        {
            oPanel.SetVariableInt("EPWLE2FadeTarget", 1 - nPage);
            oPanel.SetVariableFloat("EPWLE2FadeAlpha", 100.0);
            oPanel.SetVariableInt("EPWLE2FadePhase", 1);
            PlayGuiSound('HUDPowerWheelChangeHighlightedPower');
            return;
        }
        if (Event == BioGuiEvents.BIOGUI_EVENT_BUTTON_LB)
        {
            nSlot = m_oPowerIndices.aPlayer.Find(m_nCurrentPowerIconIndex);
            if (nSlot >= 0)
            {
                nAbsoluteSlot = nPage * 8 + nSlot;
                nSelected = oPanel.GetVariableInt("EPWLE2Selected");
                if (nSelected < 0 || nSelected >= 16)
                {
                    if (m_aPowerIcons[m_nCurrentPowerIconIndex].pPower != None)
                    {
                        oPanel.SetVariableInt("EPWLE2Selected", nAbsoluteSlot);
                        PlayGuiSound('HUDPowerWheelQueueingHighlightedPowerForActivation');
                        EPWUpdateUI(TRUE);
                    }
                }
                else
                {
                    if (nSelected != nAbsoluteSlot)
                    {
                        sMap = oPanel.GetVariableString("EPWLE2Map");
                        sSource = Mid(sMap, nSelected, 1);
                        sTarget = Mid(sMap, nAbsoluteSlot, 1);
                        sMap = Left(sMap, nSelected) $ sTarget $ Mid(sMap, nSelected + 1);
                        sMap = Left(sMap, nAbsoluteSlot) $ sSource $ Mid(sMap, nAbsoluteSlot + 1);
                        oPanel.SetVariableString("EPWLE2Map", sMap);
                        PlayGuiSound('HUDPowerWheelMapOnePower');
                    }
                    oPanel.SetVariableInt("EPWLE2Selected", -1);
                    HandleInputEvent(BioGuiEvents.BIOGUI_EVENT_BUTTON_LTHUMB, -1.0);
                }
            }
            return;
        }
        if (Event == BioGuiEvents.BIOGUI_EVENT_BUTTON_RTHUMB_RELEASE || Event == BioGuiEvents.BIOGUI_EVENT_BUTTON_LB_RELEASE)
        {
            return;
        }
    }
    switch (Event)
    {
        case BioGuiEvents.BIOGUI_EVENT_AXIS_LSTICK_X:
            m_vLStickInput.X = fValue;
            break;
        case BioGuiEvents.BIOGUI_EVENT_AXIS_LSTICK_Y:
            m_vLStickInput.Y = fValue;
            break;
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_A:
            SelectCurrentWheelItem(m_ePowerWheelMode);
            break;
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_X:
            if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers && nPage == 0 && m_nCurrentPowerIconIndex >= 0 && m_nCurrentPowerIconIndex < m_aPowerIcons.Length && m_aPowerIcons[m_nCurrentPowerIconIndex].pPower != None)
            {
                MapCurrentPower(5);
            }
            break;
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_B:
            if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers && nPage == 0 && m_nCurrentPowerIconIndex >= 0 && m_nCurrentPowerIconIndex < m_aPowerIcons.Length && m_aPowerIcons[m_nCurrentPowerIconIndex].pPower != None)
            {
                MapCurrentPower(6);
            }
            break;
        default:
            Super.HandleInputEvent(Event, fValue);
    }
}
