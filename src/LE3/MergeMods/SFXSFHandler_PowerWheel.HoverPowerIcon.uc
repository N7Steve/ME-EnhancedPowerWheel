public final event function HoverPowerIcon(int nIconIndex, bool bSkipTransition)
{
    local SFXGUIValue_PowerIcon oIcon;
    local Name nmPower;
    
    if (nIconIndex < 0 || nIconIndex >= m_aPowerIcons.Length)
    {
        return;
    }
    if (m_nCurrentPowerIconIndex == nIconIndex)
    {
        return;
    }
    // Only hover changes request a soft combo exit; rebuild/close clear it.
    if (m_nCurrentPowerIconIndex >= 0 && m_nCurrentPowerIconIndex < m_aPowerIcons.Length)
    {
        m_aPowerIcons[m_nCurrentPowerIconIndex].SetBool("EPWComboSoftLeave", TRUE);
    }
    LeavePowerIcon(m_nCurrentPowerIconIndex, bSkipTransition);
    oIcon = m_aPowerIcons[nIconIndex];
    oIcon.SetNumber("EPWComboHoverStart", m_pPlayerController.WorldInfo.RealTimeSeconds);
    if (EPWHasPower(oIcon))
    {
        oIcon.SetHover(TRUE, bSkipTransition);
        oIcon.SetSelected(TRUE);
    }
    else
    {
        // Keep an empty destination hoverable for LB, without A/Map or text.
        oIcon.pPower = None;
        oIcon.pPawn = None;
        oIcon.nmPowerName = 'None';
        oIcon.sName = "";
        oIcon.sDescription = "";
        oIcon.eDesiredState = SFXPowerWheelPowerState.PWPS_EmptySelectable;
        oIcon.bSelected = FALSE;
        if (oIcon.eState != SFXPowerWheelPowerState.PWPS_EmptySelectable)
        {
            oIcon.SetState(SFXPowerWheelPowerState.PWPS_EmptySelectable, TRUE);
        }
    }
    UpdateTextDisplayForIcon(nIconIndex);
    PlayGuiSound('HUDPowerWheelChangeHighlightedPower');
    m_nCurrentPowerIconIndex = nIconIndex;
    if (oIcon.pPower != None)
    {
        nmPower = oIcon.pPower.PowerName;
    }
    else
    {
        nmPower = oIcon.nmPowerName;
    }
    BioHintSystem(m_pPlayerController.HintSystem).UpdatePowerWheelTutorialHint(nmPower);

}
