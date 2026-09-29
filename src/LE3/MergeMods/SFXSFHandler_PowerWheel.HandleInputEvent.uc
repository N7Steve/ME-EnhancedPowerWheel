public event function bool HandleInputEvent(BioGuiEvents Event, optional float fValue = 1.0)
{
    local int nIcon;
    local int nSlot;
    local int nAbsoluteSlot;
    local int nSelectedSlot;
    local int nSourceSlot;
    local int nPage;
    local bool bRefreshPage;
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
    // This temporary state is reset before InitPowerIcons can run again.
    if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers && m_aPowerIconInfo.Length > 0 && m_aPowerIconInfo[0].Id == "")
    {
        m_aPowerIconInfo[0].Id = "01234567--------X0";
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
                if (nPage == 1)
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
            m_aPowerIcons[nIcon].eDesiredState = aDesiredStates[nSourceSlot];
            m_aPowerIcons[nIcon].SetState(aStates[nSourceSlot], TRUE);
        }
        else
        {
            m_aPowerIcons[nIcon].pPower = None;
            m_aPowerIcons[nIcon].pPawn = None;
            m_aPowerIcons[nIcon].eState = SFXPowerWheelPowerState.PWPS_EmptySelectable;
            m_aPowerIcons[nIcon].eDesiredState = SFXPowerWheelPowerState.PWPS_EmptySelectable;
        }
        m_aPowerIcons[nIcon].bDirty = TRUE;
        m_aPowerIcons[nIcon].SetVisible(TRUE);
        m_aPowerIcons[nIcon].UpdateDisplay();
    }
    SetInformationText("", "", FALSE);
    SetUseText("");
    SetMapText("", 0, "", 0, "", 0);
    m_fLastProcessedStickAngle = -1.0;
    m_aPowerIconInfo[0].Id = sMap $ sSelected $ string(nPage);
    return TRUE;
}
