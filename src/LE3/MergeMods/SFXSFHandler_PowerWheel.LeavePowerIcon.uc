public final event function LeavePowerIcon(int nIconIndex, bool bSkipTransition)
{
    local GFxValue oStateClip;
    local GFxValue oOutline;
    local int nCandidate;
    local int nState;
    local bool bSoftLeave;
    local ASDisplayInfo oDisplay;

    if (nIconIndex >= 0 && nIconIndex < m_aPowerIcons.Length && m_nCurrentPowerIconIndex == nIconIndex)
    {
        bSoftLeave = m_aPowerIcons[nIconIndex].GetBool("EPWComboSoftLeave");
        m_aPowerIcons[nIconIndex].SetBool("EPWComboSoftLeave", FALSE);
    }

    // Snapshot red alpha for hover exits; close/rebuild cancel all fades.
    // Cleanup also runs without a current hover, since exits may be pending.
    for (nCandidate = 0; nCandidate < m_aPowerIcons.Length; ++nCandidate)
    {
        for (nState = 0; nState < 8; ++nState)
        {
            oStateClip = GetVariableObject(m_aPowerIcons[nCandidate].sPath $ ".powerIconMC.sub." $ m_aPowerIcons[nCandidate].m_aPowerStatePaths[nState]);
            if (oStateClip != None)
            {
                oOutline = oStateClip.GetObject("EPWComboOutlineRed");
                if (oOutline != None)
                {
                    if (bSoftLeave)
                    {
                        if (oOutline.GetBool("EPWComboActive") && !oOutline.GetBool("EPWComboFadingOut"))
                        {
                            oDisplay = oOutline.GetDisplayInfo();
                            oOutline.SetNumber("EPWComboExitAlpha", oDisplay.Alpha);
                            oOutline.SetNumber("EPWComboExitStart", m_pPlayerController.WorldInfo.RealTimeSeconds);
                            oOutline.SetBool("EPWComboFadingOut", TRUE);
                        }
                    }
                    else
                    {
                        oOutline.SetVisible(FALSE);
                        oOutline.SetBool("EPWComboActive", FALSE);
                        oOutline.SetBool("EPWComboFadingOut", FALSE);
                    }
                }
                oOutline = oStateClip.GetObject("EPWComboOutlineViolet");
                if (oOutline != None)
                {
                    oOutline.SetVisible(FALSE);
                }
            }
        }
    }

    if (nIconIndex < 0 || nIconIndex >= m_aPowerIcons.Length || m_nCurrentPowerIconIndex != nIconIndex)
    {
        return;
    }
    if (EPWHasPower(m_aPowerIcons[nIconIndex]))
    {
        m_aPowerIcons[nIconIndex].SetHover(FALSE, bSkipTransition);
        m_aPowerIcons[nIconIndex].SetSelected(FALSE);
    }
    else
    {
        // Empty destinations never enter native hover/selection transitions.
        m_aPowerIcons[nIconIndex].bSelected = FALSE;
        m_aPowerIcons[nIconIndex].eDesiredState = SFXPowerWheelPowerState.PWPS_EmptySelectable;
        if (m_aPowerIcons[nIconIndex].eState != SFXPowerWheelPowerState.PWPS_EmptySelectable)
        {
            m_aPowerIcons[nIconIndex].SetState(SFXPowerWheelPowerState.PWPS_EmptySelectable, TRUE);
        }
    }
    SetInformationText("", "", FALSE);
    m_nCurrentPowerIconIndex = -1;
}
