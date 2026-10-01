public function CleanupReferences()
{
    local int nIcon;

    m_pPlayerController = None;
    m_pPlayerSquad = None;
    m_pShepardPawn = None;
    m_pHench1Pawn = None;
    m_pHench2Pawn = None;
    m_pCurrentPlayerSelection = None;
    for (nIcon = 0; nIcon < m_aPowerIcons.Length; ++nIcon)
    {
        m_aPowerIcons[nIcon].pPower = None;
        m_aPowerIcons[nIcon].pPawn = None;
    }
}