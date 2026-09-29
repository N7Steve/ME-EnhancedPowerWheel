public event function WheelVisibilityChanged(bool bVisible)
{
    local int nIcon;
    local bool bPowerWheel;
    local bool bWeaponWheel;
    local bool bHadOrderState;
    local GFxValue oWheel;
    local SFXGUIValue_PowerIcon oIcon;
    local GFxValue oMapped;
    local ASDisplayInfo oDisplay;

    // A close during a page fade must not leave any power clip transparent.
    for (nIcon = 0; nIcon < m_aPowerIcons.Length; ++nIcon)
    {
        oIcon = m_aPowerIcons[nIcon];
        oDisplay = oIcon.GetDisplayInfo();
        oDisplay.hasAlpha = TRUE;
        oDisplay.Alpha = 100.0;
        oIcon.SetDisplayInfo(oDisplay);

        oMapped = GetVariableObject(oIcon.oMappedIcon.sPath);
        if (oMapped != None)
        {
            oDisplay = oMapped.GetDisplayInfo();
            oDisplay.hasAlpha = TRUE;
            oDisplay.Alpha = 100.0;
            oMapped.SetDisplayInfo(oDisplay);
        }
        oMapped = GetVariableObject(oIcon.sMappedBGPath);
        if (oMapped != None)
        {
            oDisplay = oMapped.GetDisplayInfo();
            oDisplay.hasAlpha = TRUE;
            oDisplay.Alpha = 100.0;
            oMapped.SetDisplayInfo(oDisplay);
        }
    }

    if (!bVisible)
    {
        bHadOrderState = m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers && m_aPowerIconInfo.Length > 0 && m_aPowerIconInfo[0].Id != "";
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
                m_aPowerIcons[nIcon].SetSelected(FALSE);
                m_aPowerIcons[nIcon].Hide();
            }
        }
        AS_ShowWheel(FALSE);
        m_bInOutTransition = TRUE;
        m_fLastProcessedStickAngle = -1.0;
        oPanel.SetClipVisibility(m_sTitleTextPath, FALSE);
        SetInformationText("", "", FALSE);
        SetUseText("");
        SetMapText("", 0, "", 0, "", 0);
        oPanel.SetClipVisibility(m_sShepardBlockerPath, FALSE);
        oPanel.SetClipVisibility(m_sHench1BlockerPath, FALSE);
        oPanel.SetClipVisibility(m_sHench2BlockerPath, FALSE);
        SetStatusAndPowerText(None, 1);
        SetStatusAndPowerText(None, 2);
        BioHintSystem(m_pPlayerController.HintSystem).HintEvent('ClearTutorialHint');
        if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Weapons)
        {
            m_pPlayerController.GenerateTutorialEvent(7);
        }
        else if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers)
        {
            m_pPlayerController.GenerateTutorialEvent(9);
        }
        // The next opening rebuilds its icons from the current save.
        if (bHadOrderState)
        {
            m_aPowerIconInfo[0].Id = "";
        }
    }
    else
    {
        if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Weapons || m_ePowerWheelMode == SFXPowerWheelMode.PWM_PC)
        {
            bWeaponWheel = TRUE;
            for (nIcon = 0; nIcon < m_aWeaponIcons.Length; ++nIcon)
            {
                if (SFXGRI(oWorldInfo.GRI).bCanSpawnHenchmen || !m_aWeaponIcons[nIcon].bHenchIcon)
                {
                    oPanel.SetClipVisibility(m_aWeaponIcons[nIcon].sPath, TRUE);
                }
            }
        }
        if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers || m_ePowerWheelMode == SFXPowerWheelMode.PWM_PC)
        {
            bPowerWheel = TRUE;
            for (nIcon = 0; nIcon < m_aPowerIcons.Length; ++nIcon)
            {
                if (SFXGRI(oWorldInfo.GRI).bCanSpawnHenchmen || !m_aPowerIcons[nIcon].bHenchIcon)
                {
                    m_aPowerIcons[nIcon].SetVisible(TRUE);
                }
            }
        }
        SetSquadPawnDisplay(m_sHench1PortraitImagePath, m_sHench1PortraitMovieClipPath, m_pHench1Pawn);
        SetSquadPawnDisplay(m_sHench2PortraitImagePath, m_sHench2PortraitMovieClipPath, m_pHench2Pawn);
        AS_ShowWheel(TRUE);
        oPanel.SetClipVisibility(m_sTitleTextPath, TRUE);
        if (SFXGRI(oWorldInfo.GRI).bCanSpawnHenchmen)
        {
            SetStatusAndPowerText(m_pHench1Pawn, 1);
            SetStatusAndPowerText(m_pHench2Pawn, 2);
        }
        if (HaveHenchmen() == FALSE)
        {
            oWheel = GetVariableObject(m_sWheelInnerPath);
            if (oWheel != None)
            {
                oWheel.GotoAndStop("MP");
            }
        }
        BioHintSystem(m_pPlayerController.HintSystem).GeneratePowerWheelTutorialHint(bPowerWheel, bWeaponWheel);
        if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers && m_aPowerIconInfo.Length > 0)
        {
            // Native opening can restore vanilla icons after this callback returns.
            m_aPowerIconInfo[0].Id = "P";
        }
    }
}
