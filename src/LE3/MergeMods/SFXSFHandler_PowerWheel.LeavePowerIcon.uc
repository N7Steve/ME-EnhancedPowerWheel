public final event function LeavePowerIcon(int nIconIndex, bool bSkipTransition)
{
    local GFxValue oStateClip;
    local GFxValue oOutline;
    local int nCandidate;
    local int nState;

    if (nIconIndex < 0 || nIconIndex >= m_aPowerIcons.Length || m_nCurrentPowerIconIndex != nIconIndex)
    {
        return;
    }

    // Clear every outline, including squad icons and dual-role powers.
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
                    oOutline.SetVisible(FALSE);
                }
                oOutline = oStateClip.GetObject("EPWComboOutlineViolet");
                if (oOutline != None)
                {
                    oOutline.SetVisible(FALSE);
                }
            }
        }
    }

    m_aPowerIcons[nIconIndex].SetHover(FALSE, bSkipTransition);
    m_aPowerIcons[nIconIndex].SetSelected(FALSE);
    SetInformationText("", "", FALSE);
    m_nCurrentPowerIconIndex = -1;
}
