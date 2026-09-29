public final event function LeavePowerIcon(int nIconIndex, bool bSkipTransition)
{
    local GFxValue oStateClip;
    local ASColorTransform oNormal;
    local int nCandidate;
    local int nState;
    local Name nmCandidate;

    if (nIconIndex < 0 || nIconIndex >= m_aPowerIcons.Length || m_nCurrentPowerIconIndex != nIconIndex)
    {
        return;
    }

    // Restore the SWF's identity transform before changing hover/page/visibility.
    oNormal.Multiply.R = 1.0;
    oNormal.Multiply.G = 1.0;
    oNormal.Multiply.B = 1.0;
    oNormal.Multiply.A = 1.0;
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
        for (nState = 0; nState < 8; ++nState)
        {
            oStateClip = GetVariableObject(m_aPowerIcons[nCandidate].sPath $ ".powerIconMC.sub." $ m_aPowerIcons[nCandidate].m_aPowerStatePaths[nState]);
            if (oStateClip != None)
            {
                oStateClip.SetColorTransform(oNormal);
            }
        }
    }

    m_aPowerIcons[nIconIndex].SetHover(FALSE, bSkipTransition);
    m_aPowerIcons[nIconIndex].SetSelected(FALSE);
    SetInformationText("", "", FALSE);
    m_nCurrentPowerIconIndex = -1;
}
