public event function bool HandleInputEvent(BioGuiEvents Event, optional float fValue = 1.0)
{
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
    local bool bValidMap;
    local bool bRefreshPage;
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
    local array<bool> aMapped;
    local array<SFXPowerWheelPowerState> aStates;
    local array<SFXPowerWheelPowerState> aDesiredStates;
    local array<SFXPowerWheelMapButtonIcon> aMapIcons;

    // 16 source-slot characters, one selected-slot character, one page.
    // Plot ints 740200-740204 persist the map in each save game.
    if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers && m_aPowerIconInfo.Length > 0 && (m_aPowerIconInfo[0].Id == "" || m_aPowerIconInfo[0].Id == "P"))
    {
        // P requests a redraw after native opening has finished on the next update.
        bRefreshPage = m_aPowerIconInfo[0].Id == "P";
        sMap = "01234567--------";
        oPlot = BioWorldInfo(oWorldInfo).GetGlobalVariables();
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
                sMap = sState;
            }
        }
        m_aPowerIconInfo[0].Id = sMap $ "X0";
    }
    sState = m_aPowerIconInfo[0].Id;
    sMap = Left(sState, 16);
    sSelected = Mid(sState, 16, 1);
    nPage = int(Mid(sState, 17, 1));

    switch (Event)
    {
        case BioGuiEvents.BIOGUI_EVENT_AXIS_LSTICK_X:
            m_vLStickInput.X = fValue;
            break;
        case BioGuiEvents.BIOGUI_EVENT_AXIS_LSTICK_Y:
            m_vLStickInput.Y = fValue;
            break;
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_RTHUMB:
            if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers)
            {
                if (nPage == 0)
                {
                    nPage = 1;
                    bRefreshPage = TRUE;
                }
                break;
            }
            return Super(SFXGUIMovie).HandleInputEvent(Event, fValue);
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_LTHUMB:
            if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers)
            {
                if (nPage == 1 || fValue < 0.0)
                {
                    nPage = 0;
                    bRefreshPage = TRUE;
                }
                break;
            }
            return Super(SFXGUIMovie).HandleInputEvent(Event, fValue);
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_LT:
            if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers)
            {
                nSlot = m_oPowerIndices.aPlayer.Find(m_nCurrentPowerIconIndex);
                if (nSlot >= 0)
                {
                    nAbsoluteSlot = nPage * 8 + nSlot;
                    nSelectedSlot = InStr("ABCDEFGHIJKLMNOP", sSelected);
                    if (nSelectedSlot == -1)
                    {
                        if (m_aPowerIcons[m_nCurrentPowerIconIndex].pPower != None)
                        {
                            sSelected = Mid("ABCDEFGHIJKLMNOP", nAbsoluteSlot, 1);
                            PlayGuiSound('HUDPowerWheelChangeHighlightedPower');
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
                            oPlot = BioWorldInfo(oWorldInfo).GetGlobalVariables();
                            if (oPlot != None)
                            {
                                oPlot.SetInt(740200, 0, TRUE);
                                for (nGroup = 0; nGroup < 4; ++nGroup)
                                {
                                    nPacked = 0;
                                    for (nIcon = 0; nIcon < 4; ++nIcon)
                                    {
                                        nPacked = nPacked * 16;
                                        nValue = InStr("01234567", Mid(sMap, nGroup * 4 + nIcon, 1));
                                        if (nValue < 0)
                                        {
                                            nValue = 15;
                                        }
                                        nPacked = nPacked + nValue;
                                    }
                                    oPlot.SetInt(740201 + nGroup, nPacked, TRUE);
                                }
                                oPlot.SetInt(740200, 2, TRUE);
                            }
                            bRefreshPage = TRUE;
                        }
                        sSelected = "X";
                    }
                }
                break;
            }
            return Super(SFXGUIMovie).HandleInputEvent(Event, fValue);
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_A:
            SelectCurrentWheelItem(m_ePowerWheelMode);
            break;
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_X:
            if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers && nPage == 0 && m_nCurrentPowerIconIndex >= 0 && m_aPowerIcons[m_nCurrentPowerIconIndex].eState != SFXPowerWheelPowerState.PWPS_EmptySelectable && m_aPowerIcons[m_nCurrentPowerIconIndex].eState != SFXPowerWheelPowerState.PWPS_EmptySelected)
            {
                m_pPlayerController.GenerateTutorialEvent(11);
                MapCurrentPower(5);
            }
            break;
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_B:
            if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers && nPage == 0 && m_nCurrentPowerIconIndex >= 0 && m_aPowerIcons[m_nCurrentPowerIconIndex].eState != SFXPowerWheelPowerState.PWPS_EmptySelectable && m_aPowerIcons[m_nCurrentPowerIconIndex].eState != SFXPowerWheelPowerState.PWPS_EmptySelected)
            {
                m_pPlayerController.GenerateTutorialEvent(11);
                MapCurrentPower(6);
            }
            break;
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_Y:
            if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers && nPage == 0 && m_nCurrentPowerIconIndex >= 0 && m_aPowerIcons[m_nCurrentPowerIconIndex].eState != SFXPowerWheelPowerState.PWPS_EmptySelectable && m_aPowerIcons[m_nCurrentPowerIconIndex].eState != SFXPowerWheelPowerState.PWPS_EmptySelected)
            {
                m_pPlayerController.GenerateTutorialEvent(11);
                MapCurrentPower(1);
            }
            break;
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_LT_RELEASE:
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_LTHUMB_RELEASE:
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_RTHUMB_RELEASE:
            if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers)
            {
                return TRUE;
            }
            return Super(SFXGUIMovie).HandleInputEvent(Event, fValue);
        default:
            return Super(SFXGUIMovie).HandleInputEvent(Event, fValue);
    }

    if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers && m_aPowerIconInfo.Length > 0)
    {
        m_aPowerIconInfo[0].Id = sMap $ sSelected $ string(nPage);
    }
    if (!bRefreshPage)
    {
        return TRUE;
    }

    LeavePowerIcon(m_nCurrentPowerIconIndex, TRUE);
    for (nSlot = 0; nSlot < 8; ++nSlot)
    {
        nIcon = m_oPowerIndices.aPlayer[nSlot];
        m_aPowerIcons[nIcon].Hide();
        m_aPowerIcons[nIcon].ClearIcon();
        m_aPowerIcons[nIcon].pPower = None;
        m_aPowerIcons[nIcon].pPawn = None;
    }
    SetupPlayerPowers();
    // Capture vanilla data before reusing its eight physical GFx slots.
    for (nSlot = 0; nSlot < 8; ++nSlot)
    {
        nIcon = m_oPowerIndices.aPlayer[nSlot];
        aPowers.AddItem(m_aPowerIcons[nIcon].pPower);
        aPawns.AddItem(m_aPowerIcons[nIcon].pPawn);
        aPowerNames.AddItem(m_aPowerIcons[nIcon].nmPowerName);
        aNames.AddItem(m_aPowerIcons[nIcon].sName);
        aDescriptions.AddItem(m_aPowerIcons[nIcon].sDescription);
        aResources.AddItem(m_aPowerIcons[nIcon].sIconResource);
        aIconIds.AddItem(m_aPowerIcons[nIcon].nIcon);
        aCooldowns.AddItem(m_aPowerIcons[nIcon].nCooldownValue);
        aMapped.AddItem(m_aPowerIcons[nIcon].bMapped);
        aStates.AddItem(m_aPowerIcons[nIcon].eState);
        aDesiredStates.AddItem(m_aPowerIcons[nIcon].eDesiredState);
        aMapIcons.AddItem(m_aPowerIcons[nIcon].oMappedIcon.eIcon);
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
        nSourceSlot = InStr("01234567", Mid(sMap, nPage * 8 + nSlot, 1));
        m_aPowerIcons[nIcon].SetSelected(FALSE);
        m_aPowerIcons[nIcon].Hide();
        m_aPowerIcons[nIcon].ClearIcon();
        if (nSourceSlot >= 0 && aPowers[nSourceSlot] != None)
        {
            m_aPowerIcons[nIcon].pPawn = aPawns[nSourceSlot];
            m_aPowerIcons[nIcon].nmPowerName = aPowerNames[nSourceSlot];
            m_aPowerIcons[nIcon].SetPower(aPowers[nSourceSlot]);
            m_aPowerIcons[nIcon].SetIcon(aIconIds[nSourceSlot], aResources[nSourceSlot]);
            m_aPowerIcons[nIcon].sName = aNames[nSourceSlot];
            m_aPowerIcons[nIcon].sDescription = aDescriptions[nSourceSlot];
            m_aPowerIcons[nIcon].nCooldownValue = aCooldowns[nSourceSlot];
            m_aPowerIcons[nIcon].bMapped = aMapped[nSourceSlot];
            m_aPowerIcons[nIcon].oMappedIcon.eIcon = aMapIcons[nSourceSlot];
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
            m_aPowerIcons[nIcon].eDesiredState = SFXPowerWheelPowerState.PWPS_EmptySelectable;
            m_aPowerIcons[nIcon].SetState(SFXPowerWheelPowerState.PWPS_EmptySelectable, TRUE);
        }
        m_aPowerIcons[nIcon].bDirty = TRUE;
        m_aPowerIcons[nIcon].SetVisible(TRUE);
        m_aPowerIcons[nIcon].UpdateDisplay();
        m_aPowerIcons[nIcon].SetStateDisplay();
        m_aPowerIcons[nIcon].MadeVisible(TRUE);
    }
    SetInformationText("", "", FALSE);
    SetUseText("");
    SetMapText("", 0, "", 0, "", 0);
    m_fLastProcessedStickAngle = -1.0;
    m_aPowerIconInfo[0].Id = sMap $ sSelected $ string(nPage);
    return TRUE;
}
