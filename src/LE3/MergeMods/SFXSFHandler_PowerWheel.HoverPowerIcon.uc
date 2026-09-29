public final event function HoverPowerIcon(int nIconIndex, bool bSkipTransition)
{
    local SFXGUIValue_PowerIcon oIcon;
    local Name nmPower;
    local Name nmCandidate;
    local GFxValue oStateClip;
    local ASColorTransform oTint;
    local int nCandidate;
    local int nState;
    
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

    // Visual POC only: Pull is blue and Flare is red while either is hovered.
    if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers && (nmPower == 'Pull' || nmPower == 'Flare'))
    {
        oTint.Multiply.A = 1.0;
        for (nCandidate = 0; nCandidate < m_aPowerIcons.Length; ++nCandidate)
        {
            if (m_oPowerIndices.aPlayer.Find(nCandidate) == -1 || m_aPowerIcons[nCandidate].pPower == None)
            {
                continue;
            }
            nmCandidate = m_aPowerIcons[nCandidate].pPower.PowerName;
            if (nmCandidate != 'Pull' && nmCandidate != 'Flare')
            {
                continue;
            }
            oTint.Multiply.R = nmCandidate == 'Pull' ? 0.15 : 1.0;
            oTint.Multiply.G = nmCandidate == 'Pull' ? 0.55 : 0.15;
            oTint.Multiply.B = nmCandidate == 'Pull' ? 1.0 : 0.15;
            for (nState = 0; nState < 8; ++nState)
            {
                oStateClip = GetVariableObject(m_aPowerIcons[nCandidate].sPath $ ".powerIconMC.sub." $ m_aPowerIcons[nCandidate].m_aPowerStatePaths[nState]);
                if (oStateClip != None)
                {
                    oStateClip.SetColorTransform(oTint);
                }
            }
        }
    }
}
