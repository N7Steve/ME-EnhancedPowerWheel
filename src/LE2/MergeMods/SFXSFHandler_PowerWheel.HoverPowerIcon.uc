public event function HoverPowerIcon(int nIconIndex, bool bSkipTransition)
{
    local SFXPowerWheelIconPower oIcon;
    local Name nmPower;

    if (nIconIndex < 0 || nIconIndex >= m_aPowerIcons.Length)
    {
        return;
    }
    if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers && !m_aPowerIcons[nIconIndex].bVisible)
    {
        return;
    }
    if (m_nCurrentPowerIconIndex == nIconIndex)
    {
        return;
    }
    LeavePowerIcon(m_nCurrentPowerIconIndex, bSkipTransition);
    oIcon = m_aPowerIcons[nIconIndex];
    if (bSkipTransition == FALSE)
    {
        oPanel.GotoLabelAndPlay(oIcon.sPath, "grow");
    }
    else
    {
        oPanel.GotoLabelAndStop(oIcon.sPath, "opened");
    }
    SetPowerIconSelected(nIconIndex, TRUE);
    if (oIcon.pPower == None && m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers)
    {
        SetInformationText("", "");
        SetUseText("");
        SetMapText("", 0, "", 0);
    }
    else
    {
        UpdateTextDisplayForIcon(nIconIndex);
    }
    PlayGuiSound('HUDPowerWheelChangeHighlightedPower');
    m_nCurrentPowerIconIndex = nIconIndex;
    if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers)
    {
        EPWUpdateSuggestedDisplay();
    }
    if (oIcon.pPower != None)
    {
        nmPower = oIcon.pPower.BaseName;
    }
    else
    {
        nmPower = oIcon.nmPowerName;
    }
    BioHintSystem(m_pPlayerController.HintSystem).UpdatePowerWheelTutorialHint(nmPower);
}
