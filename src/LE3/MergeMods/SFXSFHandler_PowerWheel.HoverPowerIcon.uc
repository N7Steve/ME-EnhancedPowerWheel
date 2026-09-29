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
    LeavePowerIcon(m_nCurrentPowerIconIndex, bSkipTransition);
    oIcon = m_aPowerIcons[nIconIndex];
    if (oIcon.eState != SFXPowerWheelPowerState.PWPS_EmptySelectable && oIcon.eState != SFXPowerWheelPowerState.PWPS_EmptySelected)
    {
        oIcon.SetHover(TRUE, bSkipTransition);
        oIcon.SetSelected(TRUE);
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
