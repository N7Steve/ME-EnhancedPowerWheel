public final event function LeavePowerIcon(int nIconIndex, bool bSkipTransition)
{
    local string sOutlinePath;
    local int nCandidate;
    local int nState;
    local bool bSoftLeave;

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
            sOutlinePath = m_aPowerIcons[nCandidate].sPath $ ".powerIconMC.sub." $ m_aPowerIcons[nCandidate].m_aPowerStatePaths[nState] $ ".EPWComboOutlineRed";
            if (GetVariableBool(sOutlinePath $ ".EPWCreated"))
            {
                if (bSoftLeave)
                {
                    if (GetVariableBool(sOutlinePath $ ".EPWComboActive") && !GetVariableBool(sOutlinePath $ ".EPWComboFadingOut"))
                    {
                        SetVariableNumber(sOutlinePath $ ".EPWComboExitAlpha", GetVariableNumber(sOutlinePath $ "._alpha"));
                        SetVariableNumber(sOutlinePath $ ".EPWComboExitStart", m_pPlayerController.WorldInfo.RealTimeSeconds);
                        SetVariableBool(sOutlinePath $ ".EPWComboFadingOut", TRUE);
                    }
                }
                else
                {
                    SetVariableBool(sOutlinePath $ "._visible", FALSE);
                    SetVariableBool(sOutlinePath $ ".EPWComboActive", FALSE);
                    SetVariableBool(sOutlinePath $ ".EPWComboFadingOut", FALSE);
                }
            }
            // Retire legacy violet clips if present, without wrapping them.
            SetVariableBool(m_aPowerIcons[nCandidate].sPath $ ".powerIconMC.sub." $ m_aPowerIcons[nCandidate].m_aPowerStatePaths[nState] $ ".EPWComboOutlineViolet._visible", FALSE);
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
