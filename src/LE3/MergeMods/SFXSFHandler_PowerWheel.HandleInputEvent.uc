public event function bool HandleInputEvent(BioGuiEvents Event, optional float fValue = 1.0)
{
    local array<GFxValue> aEPWTemps;
    local int nIcon;
    local int nSlot;
    local int nAbsoluteSlot;
    local int nSelectedSlot;
    local int nSourceSlot;
    local int nPage;
    local int nGroup;
    local int nPacked;
    local int nValue;
    local int nSeen;
    local int nPower;
    local int nFound;
    local int nKey;
    local array<SFXPowerCustomActionBase> aAvailablePowers;
    local array<SFXPowerCustomActionBase> aOriginalPowers;
    local array<int> aOriginalIndices;
    local bool bValidMap;
    local bool bRefreshPage;
    local bool bFadePage;
    local bool bPreserveHover;
    local bool bPageRedraw;
    local BioGlobalVariableTable oPlot;
    local string sState;
    local string sMap;
    local string sSelected;
    local string sSource;
    local string sTarget;
    local array<SFXPowerCustomActionBase> aPowers;
    local array<BioPawn> aPawns;
    local array<Name> aPowerNames;
    local array<string> aNames;
    local array<string> aDescriptions;
    local array<string> aResources;
    local array<int> aIconIds;
    local array<int> aCooldowns;
    local array<SFXPowerWheelPowerState> aStates;
    local array<SFXPowerWheelPowerState> aDesiredStates;
    local array<int> aSquadIndices;
    local BioPawn pSquadPawn;
    local GFxValue oWheel;
    local int nSquadSelected;

    oWheel = EPWTempValue(GetVariableObject(m_sWheelInnerPath), aEPWTemps);

    // 16 source characters (0-F, dash empty), selection and page.
    // Version 3 also stores a power identity for each occupied save slot.
    if ((m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers || m_ePowerWheelMode == SFXPowerWheelMode.PWM_PC) && m_aPowerIconInfo.Length > 0 && (m_aPowerIconInfo[0].Id == "" || m_aPowerIconInfo[0].Id == "P"))
    {
        // P requests a redraw after native opening has finished on the next update.
        bRefreshPage = m_aPowerIconInfo[0].Id == "P";
        EPWPlayerPowers(aAvailablePowers);
        sMap = "----------------";
        oPlot = BioWorldInfo(oWorldInfo).GetGlobalVariables();
        if (aAvailablePowers.Length <= 8 && (oPlot == None || (oPlot.GetInt(740200) != 2 && oPlot.GetInt(740200) != 3)))
        {
            SetupPlayerPowers();
            for (nSlot = 0; nSlot < 8; ++nSlot)
            {
                nIcon = m_oPowerIndices.aPlayer[nSlot];
                nPower = aAvailablePowers.Find(m_aPowerIcons[nIcon].pPower);
                if (nPower >= 0 && InStr(sMap, Mid("0123456789ABCDEF", nPower, 1)) < 0)
                {
                    sMap = Left(sMap, nSlot) $ Mid("0123456789ABCDEF", nPower, 1) $ Mid(sMap, nSlot + 1);
                }
            }
        }
        if (oPlot != None && oPlot.GetInt(740200) == 2)
        {
            sState = "";
            bValidMap = TRUE;
            for (nGroup = 3; nGroup >= 0; --nGroup)
            {
                nPacked = oPlot.GetInt(740201 + nGroup);
                if (nPacked < 0 || nPacked > 65535)
                {
                    bValidMap = FALSE;
                }
                for (nSlot = 0; nSlot < 4; ++nSlot)
                {
                    nValue = nPacked % 16;
                    nPacked = nPacked / 16;
                    if (nValue < 8)
                    {
                        if ((nSeen & (1 << nValue)) != 0)
                        {
                            bValidMap = FALSE;
                        }
                        nSeen = nSeen | (1 << nValue);
                        sState = Mid("01234567", nValue, 1) $ sState;
                    }
                    else
                    {
                        if (nValue != 15)
                        {
                            bValidMap = FALSE;
                        }
                        sState = "-" $ sState;
                    }
                }
            }
            if (bValidMap && nSeen == 255)
            {
                SetupPlayerPowers();
                for (nSlot = 0; nSlot < 16; ++nSlot)
                {
                    nSourceSlot = InStr("01234567", Mid(sState, nSlot, 1));
                    if (nSourceSlot >= 0)
                    {
                        nIcon = m_oPowerIndices.aPlayer[nSourceSlot];
                        nPower = aAvailablePowers.Find(m_aPowerIcons[nIcon].pPower);
                        if (nPower >= 0 && InStr(sMap, Mid("0123456789ABCDEF", nPower, 1)) < 0)
                        {
                            sMap = Left(sMap, nSlot) $ Mid("0123456789ABCDEF", nPower, 1) $ Mid(sMap, nSlot + 1);
                        }
                    }
                }
            }
        }
        if (oPlot != None && oPlot.GetInt(740200) == 3)
        {
            for (nSlot = 0; nSlot < 16; ++nSlot)
            {
                nKey = oPlot.GetInt(740210 + nSlot);
                if (nKey == 0)
                {
                    continue;
                }
                for (nPower = 0; nPower < aAvailablePowers.Length; ++nPower)
                {
                    sSource = Mid("0123456789ABCDEF", nPower, 1);
                    if (EPWPowerKey(aAvailablePowers[nPower]) == nKey && InStr(sMap, sSource) < 0)
                    {
                        sMap = Left(sMap, nSlot) $ sSource $ Mid(sMap, nSlot + 1);
                        break;
                    }
                }
            }
        }
        // Existing identities keep their slots; new powers take the first hole.
        for (nPower = 0; nPower < aAvailablePowers.Length; ++nPower)
        {
            sSource = Mid("0123456789ABCDEF", nPower, 1);
            nSlot = InStr(sMap, "-");
            if (InStr(sMap, sSource) < 0 && nSlot >= 0)
            {
                sMap = Left(sMap, nSlot) $ sSource $ Mid(sMap, nSlot + 1);
            }
        }
        EPWSaveMap(sMap, aAvailablePowers);
        m_aPowerIconInfo[0].Id = sMap $ "X0";
    }
    sState = m_aPowerIconInfo[0].Id;
    sMap = Left(sState, 16);
    sSelected = Mid(sState, 16, 1);
    nPage = int(Mid(sState, 17, 1));

    // Ignore wheel input until the page fade has finished.
    // Negative thumb input is reserved for the redraw at the fade midpoint.
    if (Len(sState) > 18 && (Event == BioGuiEvents.BIOGUI_EVENT_AXIS_LSTICK_X || Event == BioGuiEvents.BIOGUI_EVENT_AXIS_LSTICK_Y))
    {
        if (Event == BioGuiEvents.BIOGUI_EVENT_AXIS_LSTICK_X)
        {
            m_vLStickInput.X = fValue;
        }
        else
        {
            m_vLStickInput.Y = fValue;
        }
        EPWReleaseTemps(aEPWTemps); return TRUE;
    }
    if (Len(sState) > 18 && !(fValue < 0.0 && (Event == BioGuiEvents.BIOGUI_EVENT_BUTTON_RTHUMB || Event == BioGuiEvents.BIOGUI_EVENT_BUTTON_LTHUMB)))
    {
        EPWReleaseTemps(aEPWTemps); return TRUE;
    }

    switch (Event)
    {
        case BioGuiEvents.BIOGUI_EVENT_AXIS_LSTICK_X:
            m_vLStickInput.X = fValue;
            break;
        case BioGuiEvents.BIOGUI_EVENT_AXIS_LSTICK_Y:
            m_vLStickInput.Y = fValue;
            break;
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_RTHUMB:
            if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers || m_ePowerWheelMode == SFXPowerWheelMode.PWM_PC)
            {
                if (fValue < 0.0)
                {
                    // Internal redraw keeps the target page already in sState.
                    bRefreshPage = TRUE;
                    bPageRedraw = Len(sState) > 18;
                    bPreserveHover = bPageRedraw && m_oPowerIndices.aPlayer.Find(m_nCurrentPowerIconIndex) >= 0;
                }
                else
                {
                    if (oWheel != None) { oWheel.SetNumber("EPWSquadSelected", 0.0); }
                    nPage = 1 - nPage;
                    bFadePage = TRUE;
                    PlayGuiSound('BrowserSegmentChange');
                }
                break;
            }
            EPWReleaseTemps(aEPWTemps); return Super(SFXGUIMovie).HandleInputEvent(Event, fValue);
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_LTHUMB:
            if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers || m_ePowerWheelMode == SFXPowerWheelMode.PWM_PC)
            {
                if (fValue < 0.0)
                {
                    // Retained only for the first-open and fade redraw calls.
                    bRefreshPage = TRUE;
                    bPageRedraw = Len(sState) > 18;
                    bPreserveHover = bPageRedraw && m_oPowerIndices.aPlayer.Find(m_nCurrentPowerIconIndex) >= 0;
                }
                break;
            }
            EPWReleaseTemps(aEPWTemps); return Super(SFXGUIMovie).HandleInputEvent(Event, fValue);
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_LB:
            if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers || m_ePowerWheelMode == SFXPowerWheelMode.PWM_PC)
            {
                // Each companion owns its five physical slots on the main page.
                if (nPage == 0 && m_nCurrentPowerIconIndex >= 0 && m_nCurrentPowerIconIndex < m_aPowerIcons.Length && oWheel != None)
                {
                    if (m_oPowerIndices.aHench1.Find(m_nCurrentPowerIconIndex) >= 0 && m_pHench1Pawn != None)
                    {
                        aSquadIndices = m_oPowerIndices.aHench1;
                        pSquadPawn = m_pHench1Pawn;
                    }
                    else if (m_oPowerIndices.aHench2.Find(m_nCurrentPowerIconIndex) >= 0 && m_pHench2Pawn != None)
                    {
                        aSquadIndices = m_oPowerIndices.aHench2;
                        pSquadPawn = m_pHench2Pawn;
                    }
                    if (pSquadPawn != None)
                    {
                        sSelected = "X";
                        nSquadSelected = int(oWheel.GetNumber("EPWSquadSelected")) - 1;
                        nSourceSlot = aSquadIndices.Find(nSquadSelected);
                        if (nSourceSlot < 0)
                        {
                            // Moving to another companion starts a new selection.
                            oWheel.SetNumber("EPWSquadSelected", 0.0);
                            if (EPWHasPower(m_aPowerIcons[m_nCurrentPowerIconIndex]))
                            {
                                oWheel.SetNumber("EPWSquadSelected", float(m_nCurrentPowerIconIndex + 1));
                                PlayGuiSound('HUDPowerWheelQueueingHighlightedPowerForActivation');
                            }
                        }
                        else
                        {
                            oWheel.SetNumber("EPWSquadSelected", 0.0);
                            nIcon = m_nCurrentPowerIconIndex;
                            if (nSquadSelected != nIcon && EPWHasPower(m_aPowerIcons[nSquadSelected]))
                            {
                                LeavePowerIcon(nIcon, TRUE);
                                EPWSquadLayout(pSquadPawn, aSquadIndices, nSourceSlot, aSquadIndices.Find(nIcon));
                                EPWRefreshMappingIcons();
                                HoverPowerIcon(nIcon, TRUE);
                                PlayGuiSound('HUDPowerWheelQueueingHighlightedPowerForActivation');
                            }
                        }
                        break;
                    }
                }
                nSlot = m_oPowerIndices.aPlayer.Find(m_nCurrentPowerIconIndex);
                if (nSlot >= 0)
                {
                    if (oWheel != None) { oWheel.SetNumber("EPWSquadSelected", 0.0); }
                    nAbsoluteSlot = nPage * 8 + nSlot;
                    nSelectedSlot = InStr("ABCDEFGHIJKLMNOP", sSelected);
                    if (nSelectedSlot == -1)
                    {
                        if (m_aPowerIcons[m_nCurrentPowerIconIndex].pPower != None)
                        {
                            sSelected = Mid("ABCDEFGHIJKLMNOP", nAbsoluteSlot, 1);
                            PlayGuiSound('HUDPowerWheelQueueingHighlightedPowerForActivation');
                        }
                    }
                    else
                    {
                        if (nSelectedSlot != nAbsoluteSlot)
                        {
                            sSource = Mid(sMap, nSelectedSlot, 1);
                            sTarget = Mid(sMap, nAbsoluteSlot, 1);
                            sMap = Left(sMap, nSelectedSlot) $ sTarget $ Mid(sMap, nSelectedSlot + 1);
                            sMap = Left(sMap, nAbsoluteSlot) $ sSource $ Mid(sMap, nAbsoluteSlot + 1);
                            EPWPlayerPowers(aAvailablePowers);
                            EPWSaveMap(sMap, aAvailablePowers);
                            bRefreshPage = TRUE;
                            bPreserveHover = TRUE;
                            PlayGuiSound('HUDPowerWheelQueueingHighlightedPowerForActivation');
                        }
                        sSelected = "X";
                    }
                }
                break;
            }
            EPWReleaseTemps(aEPWTemps); return Super(SFXGUIMovie).HandleInputEvent(Event, fValue);
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_A:
            SelectCurrentWheelItem(m_ePowerWheelMode);
            break;
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_X:
            if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers && m_nCurrentPowerIconIndex >= 0 && m_aPowerIcons[m_nCurrentPowerIconIndex].eState != SFXPowerWheelPowerState.PWPS_EmptySelectable && m_aPowerIcons[m_nCurrentPowerIconIndex].eState != SFXPowerWheelPowerState.PWPS_EmptySelected)
            {
                m_pPlayerController.GenerateTutorialEvent(11);
                MapCurrentPower(5);
            }
            break;
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_B:
            if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers && m_nCurrentPowerIconIndex >= 0 && m_aPowerIcons[m_nCurrentPowerIconIndex].eState != SFXPowerWheelPowerState.PWPS_EmptySelectable && m_aPowerIcons[m_nCurrentPowerIconIndex].eState != SFXPowerWheelPowerState.PWPS_EmptySelected)
            {
                m_pPlayerController.GenerateTutorialEvent(11);
                MapCurrentPower(6);
            }
            break;
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_Y:
            if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers && m_nCurrentPowerIconIndex >= 0 && m_aPowerIcons[m_nCurrentPowerIconIndex].eState != SFXPowerWheelPowerState.PWPS_EmptySelectable && m_aPowerIcons[m_nCurrentPowerIconIndex].eState != SFXPowerWheelPowerState.PWPS_EmptySelected)
            {
                m_pPlayerController.GenerateTutorialEvent(11);
                MapCurrentPower(1);
            }
            break;
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_LB_RELEASE:
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_LTHUMB_RELEASE:
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_RTHUMB_RELEASE:
            if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers || m_ePowerWheelMode == SFXPowerWheelMode.PWM_PC)
            {
                EPWReleaseTemps(aEPWTemps); return TRUE;
            }
            EPWReleaseTemps(aEPWTemps); return Super(SFXGUIMovie).HandleInputEvent(Event, fValue);
        default:
            EPWReleaseTemps(aEPWTemps); return Super(SFXGUIMovie).HandleInputEvent(Event, fValue);
    }

    if ((m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers || m_ePowerWheelMode == SFXPowerWheelMode.PWM_PC) && m_aPowerIconInfo.Length > 0)
    {
        m_aPowerIconInfo[0].Id = sMap $ sSelected $ string(nPage);
        if (bFadePage)
        {
            m_aPowerIconInfo[0].Id $= "O";
        }
    }
    if (!bRefreshPage)
    {
        EPWReleaseTemps(aEPWTemps); return TRUE;
    }

    if (!bPreserveHover)
    {
        LeavePowerIcon(m_nCurrentPowerIconIndex, TRUE);
    }
    for (nSlot = 0; nSlot < 8; ++nSlot)
    {
        nIcon = m_oPowerIndices.aPlayer[nSlot];
        m_aPowerIcons[nIcon].Hide();
        m_aPowerIcons[nIcon].ClearIcon();
        m_aPowerIcons[nIcon].pPower = None;
        m_aPowerIcons[nIcon].pPawn = None;
    }
    EPWPlayerPowers(aAvailablePowers);
    if (m_pShepardPawn == None || m_pShepardPawn.PowerManager == None || m_oPowerIndices.aPlayer.Length < 8)
    {
        EPWReleaseTemps(aEPWTemps); return TRUE;
    }
    // Let native setup initialize each real power, without competing powers.
    // The manager array and display indices are restored synchronously below.
    aOriginalPowers = m_pShepardPawn.PowerManager.Powers;
    for (nPower = 0; nPower < aOriginalPowers.Length; ++nPower)
    {
        aOriginalIndices.AddItem(aOriginalPowers[nPower].WheelDisplayIndex);
    }
    for (nPower = 0; nPower < aAvailablePowers.Length; ++nPower)
    {
        for (nSlot = 0; nSlot < 8; ++nSlot)
        {
            nIcon = m_oPowerIndices.aPlayer[nSlot];
            m_aPowerIcons[nIcon].ClearIcon();
            m_aPowerIcons[nIcon].pPower = None;
            m_aPowerIcons[nIcon].pPawn = None;
        }
        m_pShepardPawn.PowerManager.Powers.Length = 0;
        m_pShepardPawn.PowerManager.Powers.AddItem(aAvailablePowers[nPower]);
        SetupPlayerPowers();
        nFound = -1;
        for (nSlot = 0; nSlot < 8; ++nSlot)
        {
            nIcon = m_oPowerIndices.aPlayer[nSlot];
            if (m_aPowerIcons[nIcon].pPower == aAvailablePowers[nPower])
            {
                nFound = nIcon;
                break;
            }
        }
        // If native setup rejects an icon, keep a null source, never another power.
        nIcon = nFound >= 0 ? nFound : m_oPowerIndices.aPlayer[0];
        aPowers.AddItem(nFound >= 0 ? m_aPowerIcons[nIcon].pPower : None);
        aPawns.AddItem(m_aPowerIcons[nIcon].pPawn);
        aPowerNames.AddItem(m_aPowerIcons[nIcon].nmPowerName);
        aNames.AddItem(m_aPowerIcons[nIcon].sName);
        aDescriptions.AddItem(m_aPowerIcons[nIcon].sDescription);
        aResources.AddItem(m_aPowerIcons[nIcon].sIconResource);
        aIconIds.AddItem(m_aPowerIcons[nIcon].nIcon);
        aCooldowns.AddItem(m_aPowerIcons[nIcon].nCooldownValue);
        aStates.AddItem(m_aPowerIcons[nIcon].eState);
        aDesiredStates.AddItem(m_aPowerIcons[nIcon].eDesiredState);
    }
    m_pShepardPawn.PowerManager.Powers = aOriginalPowers;
    for (nPower = 0; nPower < aOriginalPowers.Length; ++nPower)
    {
        aOriginalPowers[nPower].WheelDisplayIndex = aOriginalIndices[nPower];
    }
    for (nIcon = 0; nIcon < m_aPowerIcons.Length; ++nIcon)
    {
        if (m_aPowerIcons[nIcon].bHenchIcon)
        {
            if (nPage == 1)
            {
                m_aPowerIcons[nIcon].Hide();
            }
            else if (SFXGRI(oWorldInfo.GRI).bCanSpawnHenchmen)
            {
                m_aPowerIcons[nIcon].SetVisible(TRUE);
            }
        }
    }
    for (nSlot = 0; nSlot < 8; ++nSlot)
    {
        nIcon = m_oPowerIndices.aPlayer[nSlot];
        nSourceSlot = InStr("0123456789ABCDEF", Mid(sMap, nPage * 8 + nSlot, 1));
        m_aPowerIcons[nIcon].SetSelected(FALSE);
        m_aPowerIcons[nIcon].Hide();
        m_aPowerIcons[nIcon].ClearIcon();
        if (nSourceSlot >= 0 && nSourceSlot < aPowers.Length && aPowers[nSourceSlot] != None)
        {
            m_aPowerIcons[nIcon].pPawn = aPawns[nSourceSlot];
            m_aPowerIcons[nIcon].nmPowerName = aPowerNames[nSourceSlot];
            m_aPowerIcons[nIcon].SetPower(aPowers[nSourceSlot]);
            m_aPowerIcons[nIcon].SetIcon(aIconIds[nSourceSlot], aResources[nSourceSlot]);
            m_aPowerIcons[nIcon].sName = aNames[nSourceSlot];
            m_aPowerIcons[nIcon].sDescription = aDescriptions[nSourceSlot];
            m_aPowerIcons[nIcon].nCooldownValue = aCooldowns[nSourceSlot];
            // Native setup can leave the prior page's empty visual state on an occupied source.
            if (aStates[nSourceSlot] == SFXPowerWheelPowerState.PWPS_Selected || aStates[nSourceSlot] == SFXPowerWheelPowerState.PWPS_EmptySelectable || aStates[nSourceSlot] == SFXPowerWheelPowerState.PWPS_EmptySelected)
            {
                m_aPowerIcons[nIcon].eDesiredState = SFXPowerWheelPowerState.PWPS_Selectable;
                m_aPowerIcons[nIcon].SetState(SFXPowerWheelPowerState.PWPS_Selectable, TRUE);
            }
            else
            {
                m_aPowerIcons[nIcon].eDesiredState = aDesiredStates[nSourceSlot];
                if (m_aPowerIcons[nIcon].eDesiredState == SFXPowerWheelPowerState.PWPS_EmptySelectable || m_aPowerIcons[nIcon].eDesiredState == SFXPowerWheelPowerState.PWPS_EmptySelected)
                {
                    m_aPowerIcons[nIcon].eDesiredState = aStates[nSourceSlot];
                }
                m_aPowerIcons[nIcon].SetState(aStates[nSourceSlot], TRUE);
            }
        }
        else
        {
            m_aPowerIcons[nIcon].pPower = None;
            m_aPowerIcons[nIcon].pPawn = None;
            // ClearIcon leaves text metadata from the previous page/native setup.
            m_aPowerIcons[nIcon].nmPowerName = 'None';
            m_aPowerIcons[nIcon].sName = "";
            m_aPowerIcons[nIcon].sDescription = "";
            m_aPowerIcons[nIcon].eDesiredState = SFXPowerWheelPowerState.PWPS_EmptySelectable;
            m_aPowerIcons[nIcon].SetState(SFXPowerWheelPowerState.PWPS_EmptySelectable, TRUE);
        }
        m_aPowerIcons[nIcon].bDirty = TRUE;
        m_aPowerIcons[nIcon].SetVisible(TRUE);
        m_aPowerIcons[nIcon].UpdateDisplay();
        m_aPowerIcons[nIcon].SetStateDisplay();
        m_aPowerIcons[nIcon].MadeVisible(TRUE);
        if (m_aPowerIcons[nIcon].pPower != None)
        {
            // Refresh native availability after restoring the full power roster.
            // Match hover/leave without transitions or changing handler selection.
            m_aPowerIcons[nIcon].SetHover(TRUE, TRUE);
            m_aPowerIcons[nIcon].SetSelected(TRUE);
            m_aPowerIcons[nIcon].SetHover(FALSE, TRUE);
            m_aPowerIcons[nIcon].SetSelected(FALSE);
        }

    }
    // Restore squad content only after native setup and full-roster restoration.
    // This also reapplies its saved layout when R3 returns to the main page.
    if (nPage == 0)
    {
        EPWSquadLayout(m_pHench1Pawn, m_oPowerIndices.aHench1);
        EPWSquadLayout(m_pHench2Pawn, m_oPowerIndices.aHench2);
    }
    EPWRefreshMappingIcons();
    EPWUpdateSuggestedDisplay();
    SetInformationText("", "", FALSE);
    SetUseText("");
    SetMapText("", 0, "", 0, "", 0);
    if (bPreserveHover && m_nCurrentPowerIconIndex >= 0 && m_nCurrentPowerIconIndex < m_aPowerIcons.Length)
    {
        if (m_aPowerIcons[m_nCurrentPowerIconIndex].pPower != None)
        {
            m_aPowerIcons[m_nCurrentPowerIconIndex].SetHover(TRUE, TRUE);
            m_aPowerIcons[m_nCurrentPowerIconIndex].SetSelected(TRUE);
        }
        UpdateTextDisplayForIcon(m_nCurrentPowerIconIndex);
    }
    else if (!bPageRedraw)
    {
        m_fLastProcessedStickAngle = -1.0;
    }
    m_aPowerIconInfo[0].Id = sMap $ sSelected $ string(nPage);
    EPWUpdateSuggestedDisplay();
    EPWRefreshMappingIcons();
    EPWReleaseTemps(aEPWTemps); return TRUE;
}
