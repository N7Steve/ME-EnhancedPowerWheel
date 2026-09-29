public event function bool HandleInputEvent(BioGuiEvents Event, optional float fValue = 1.0)
{
    local int nIcon;

    switch (Event)
    {
        case BioGuiEvents.BIOGUI_EVENT_AXIS_LSTICK_X:
            m_vLStickInput.X = fValue;
            break;
        case BioGuiEvents.BIOGUI_EVENT_AXIS_LSTICK_Y:
            m_vLStickInput.Y = fValue;
            break;
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_RTHUMB:
            if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers && m_aPowerIcons.Length > 5)
            {
                if (m_aPowerIcons[5].bVisible)
                {
                    LeavePowerIcon(m_nCurrentPowerIconIndex, TRUE);
                    for (nIcon = 0; nIcon < m_aPowerIcons.Length; ++nIcon)
                    {
                        m_aPowerIcons[nIcon].SetSelected(FALSE);
                        m_aPowerIcons[nIcon].ClearIcon();
                        m_aPowerIcons[nIcon].pPower = None;
                        m_aPowerIcons[nIcon].pPawn = None;
                        m_aPowerIcons[nIcon].eState = SFXPowerWheelPowerState.PWPS_EmptySelectable;
                        m_aPowerIcons[nIcon].Hide();
                    }
                    // A player-owned icon is the page marker; no class layout change.
                    m_aPowerIcons[5].bVisible = FALSE;
                    SetInformationText("", "", FALSE);
                    SetUseText("");
                    SetMapText("", 0, "", 0, "", 0);
                }
                return TRUE;
            }
            break;
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_LTHUMB:
            if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers && m_aPowerIcons.Length > 5)
            {
                if (!m_aPowerIcons[5].bVisible)
                {
                    SetupPlayerPowers();
                    for (nIcon = 0; nIcon < m_aPowerIcons.Length; ++nIcon)
                    {
                        if (SFXGRI(oWorldInfo.GRI).bCanSpawnHenchmen || !m_aPowerIcons[nIcon].bHenchIcon)
                        {
                            m_aPowerIcons[nIcon].SetVisible(TRUE);
                            m_aPowerIcons[nIcon].UpdateDisplay();
                        }
                    }
                    m_aPowerIcons[5].bVisible = TRUE;
                }
                return TRUE;
            }
            break;
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_A:
            SelectCurrentWheelItem(m_ePowerWheelMode);
            break;
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_X:
            if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers && (m_aPowerIcons.Length <= 5 || m_aPowerIcons[5].bVisible))
            {
                m_pPlayerController.GenerateTutorialEvent(11);
                MapCurrentPower(5);
            }
            break;
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_B:
            if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers && (m_aPowerIcons.Length <= 5 || m_aPowerIcons[5].bVisible))
            {
                m_pPlayerController.GenerateTutorialEvent(11);
                MapCurrentPower(6);
            }
            break;
        case BioGuiEvents.BIOGUI_EVENT_BUTTON_Y:
            if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers && (m_aPowerIcons.Length <= 5 || m_aPowerIcons[5].bVisible))
            {
                m_pPlayerController.GenerateTutorialEvent(11);
                MapCurrentPower(1);
            }
            break;
        default:
            return Super(SFXGUIMovie).HandleInputEvent(Event, fValue);
    }
    return TRUE;
}
