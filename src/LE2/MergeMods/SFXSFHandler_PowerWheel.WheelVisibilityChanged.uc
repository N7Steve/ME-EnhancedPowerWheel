public event function WheelVisibilityChanged(bool bVisible)
{
    local int nIcon;
    local bool bPowerWheel;
    local bool bWeaponWheel;
    local int nSlot;
    local string sSquadVisibility;

    // Reset transition state on both opening and closing, including mid-fade.
    oPanel.SetVariableBool("EPWLE2Open", bVisible && m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers);
    oPanel.SetVariableInt("EPWLE2FadePhase", 0);
    oPanel.SetVariableBool("EPWLE2SavePending", FALSE);
    oPanel.SetVariableFloat("EPWLE2FadeAlpha", 100.0);
    for (nIcon = 0; nIcon < m_aPowerIcons.Length; ++nIcon)
    {
        oPanel.SetVariableFloat(m_aPowerIcons[nIcon].sPath $ "._alpha", 100.0);
        oPanel.SetVariableFloat(m_aPowerIcons[nIcon].oMappedIcon.sPath $ "._alpha", 100.0);
        oPanel.SetVariableFloat("mainContent." $ m_aPowerIcons[nIcon].sMappedBGPath $ "._alpha", 100.0);
    }
    EPWUpdateUI(FALSE);
    if (!bVisible && m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers)
    {
        LeavePowerIcon(m_nCurrentPowerIconIndex, TRUE);
        // Return native source data before another wheel mode can use these slots.
        for (nSlot = 0; nSlot < m_oPowerIndices.aPlayer.Length; ++nSlot)
        {
            nIcon = m_oPowerIndices.aPlayer[nSlot];
            m_aPowerIcons[nIcon].pPower = None;
            m_aPowerIcons[nIcon].pPawn = None;
            m_aPowerIcons[nIcon].eState = SFXPowerWheelPowerState.PWPS_EmptySelectable;
            m_aPowerIcons[nIcon].eDesiredState = SFXPowerWheelPowerState.PWPS_EmptySelectable;
        }
        SetupPlayerPowers();
        sSquadVisibility = oPanel.GetVariableString("EPWLE2SquadVisibility");
        if (Len(sSquadVisibility) == m_aPowerIcons.Length)
        {
            for (nIcon = 0; nIcon < m_aPowerIcons.Length; ++nIcon)
            {
                if (m_oPowerIndices.aPlayer.Find(nIcon) == -1)
                {
                    m_aPowerIcons[nIcon].bVisible = Mid(sSquadVisibility, nIcon, 1) == "1";
                }
            }
        }
    }
    oPanel.SetVariableInt("EPWLE2Page", 0);
    oPanel.SetVariableInt("EPWLE2Selected", -1);
    oPanel.SetVariableBool("EPWLE2SquadCached", FALSE);
    oPanel.SetVariableBool("EPWLE2Pending", bVisible && m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers);
    if (bVisible == FALSE)
    {
        if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Weapons || m_ePowerWheelMode == SFXPowerWheelMode.PWM_PC)
        {
            LeaveWeaponIcon(m_nCurrentWeaponIconIndex);
            for (nIcon = 0; nIcon < m_aWeaponIcons.Length; ++nIcon)
            {
                oPanel.SetClipVisibility(m_aWeaponIcons[nIcon].sPath, FALSE);
            }
        }
        if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers || m_ePowerWheelMode == SFXPowerWheelMode.PWM_PC)
        {
            LeavePowerIcon(m_nCurrentPowerIconIndex, TRUE);
            for (nIcon = 0; nIcon < m_aPowerIcons.Length; ++nIcon)
            {
                SetPowerIconSelected(nIcon, FALSE);
                HidePowerIconByIndex(nIcon);
            }
        }
        oPanel.GotoLabelAndPlay("mainContent.Wheel", "OUT");
        m_bInOutTransition = TRUE;
        m_fLastProcessedStickAngle = -1.0;
        oPanel.SetClipVisibility(m_sTitleTextPath, FALSE);
        SetInformationText("", "");
        SetUseText("");
        SetMapText("", 0, "", 0);
        oPanel.SetClipVisibility(m_sShepardBlockerPath, FALSE);
        oPanel.SetClipVisibility(m_sHench1BlockerPath, FALSE);
        oPanel.SetClipVisibility(m_sHench2BlockerPath, FALSE);
        SetStatusAndPowerText(None, 1);
        SetStatusAndPowerText(None, 2);
        BioHintSystem(m_pPlayerController.HintSystem).HintEvent('ClearTutorialHint');
        m_pPlayerController.GenerateTutorialEvent(7);
    }
    else
    {
        if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Weapons || m_ePowerWheelMode == SFXPowerWheelMode.PWM_PC)
        {
            bWeaponWheel = TRUE;
            for (nIcon = 0; nIcon < m_aWeaponIcons.Length; ++nIcon)
            {
                oPanel.SetClipVisibility(m_aWeaponIcons[nIcon].sPath, TRUE);
            }
        }
        if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers || m_ePowerWheelMode == SFXPowerWheelMode.PWM_PC)
        {
            bPowerWheel = TRUE;
            for (nIcon = 0; nIcon < m_aPowerIcons.Length; ++nIcon)
            {
                oPanel.SetClipVisibility(m_aPowerIcons[nIcon].sPath, TRUE);
            }
        }
        oPanel.GotoLabelAndPlay("mainContent.Wheel", "IN");
        oPanel.SetClipVisibility(m_sTitleTextPath, TRUE);
        SetStatusAndPowerText(m_pHench1Pawn, 1);
        SetStatusAndPowerText(m_pHench2Pawn, 2);
        BioHintSystem(m_pPlayerController.HintSystem).GeneratePowerWheelTutorialHint(bPowerWheel, bWeaponWheel);
    }
    if (bVisible && m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers)
    {
        HandleInputEvent(BioGuiEvents.BIOGUI_EVENT_BUTTON_LTHUMB, -1.0);
        // Recheck after native opening on the first forwarded input event.
        oPanel.SetVariableBool("EPWLE2Pending", TRUE);
    }
    if (!bVisible && m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers)
    {
        EPWRefreshMappingIcons(FALSE);
    }
}
