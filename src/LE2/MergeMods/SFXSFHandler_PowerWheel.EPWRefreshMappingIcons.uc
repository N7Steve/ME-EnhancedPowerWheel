public final function EPWRefreshMappingIcons(optional bool bShow = TRUE)
{
    local BioPlayerInput oInput;
    local BioSFManager oMgr;
    local SFXPowerWheelMapButtonIcon eButton;
    local int nSlot;
    local int nIcon;
    local int nButton;
    local int nSide;
    local bool bMapped;

    if (!bShow || !oPanel.GetVariableBool("EPWLE2Open"))
    {
        // Native cleanup addresses short background paths. Explicitly clear
        // all real siblings after native setup/hide, including squad badges.
        for (nIcon = 0; nIcon < m_aPowerIcons.Length; ++nIcon)
        {
            oPanel.SetClipVisibility(m_aPowerIcons[nIcon].oMappedIcon.sPath, FALSE);
            oPanel.SetClipVisibility("mainContent." $ m_aPowerIcons[nIcon].sMappedBGPath, FALSE);
            oPanel.SetVariableFloat(m_aPowerIcons[nIcon].oMappedIcon.sPath $ "._alpha", 0.0);
            oPanel.SetVariableFloat("mainContent." $ m_aPowerIcons[nIcon].sMappedBGPath $ "._alpha", 0.0);
        }
        return;
    }
    if (m_pPlayerController == None) { return; }
    oInput = BioPlayerInput(m_pPlayerController.PlayerInput);
    if (oInput == None) { return; }
    oMgr = oPanel.oParentManager;
    for (nSlot = 0; nSlot < m_oPowerIndices.aPlayer.Length; ++nSlot)
    {
        nIcon = m_oPowerIndices.aPlayer[nSlot];
        eButton = SFXPowerWheelMapButtonIcon.PWBI_Icon_NONE;
        nSide = 0;
        if (m_aPowerIcons[nIcon].pPower != None)
        {
            // Read live input assignments, never write controller/quickslot data.
            if (oInput.m_nmMappedPower3 != 'None' && (m_aPowerIcons[nIcon].pPower.Class.Name == oInput.m_nmMappedPower3 || m_aPowerIcons[nIcon].pPower.PowerName == oInput.m_nmMappedPower3))
            {
                eButton = SFXPowerWheelMapButtonIcon.PWBI_FaceButtonTop;
            }
            else if (oInput.m_nmMappedPower != 'None' && (m_aPowerIcons[nIcon].pPower.Class.Name == oInput.m_nmMappedPower || m_aPowerIcons[nIcon].pPower.PowerName == oInput.m_nmMappedPower))
            {
                nSide = 1;
            }
            else if (oInput.m_nmMappedPower2 != 'None' && (m_aPowerIcons[nIcon].pPower.Class.Name == oInput.m_nmMappedPower2 || m_aPowerIcons[nIcon].pPower.PowerName == oInput.m_nmMappedPower2))
            {
                nSide = 2;
            }
        }
        if (nSide != 0)
        {
            if (oMgr != None && oMgr.IsTriggerSouthpaw()) { nSide = 3 - nSide; }
            if (oMgr != None && oMgr.IsTriggerShoulderSwapped())
            {
                eButton = nSide == 1 ? SFXPowerWheelMapButtonIcon.PWBI_TriggerLeft : SFXPowerWheelMapButtonIcon.PWBI_TriggerRight;
            }
            else
            {
                eButton = nSide == 1 ? SFXPowerWheelMapButtonIcon.PWBI_ShoulderLeft : SFXPowerWheelMapButtonIcon.PWBI_ShoulderRight;
            }
        }
        bMapped = eButton != SFXPowerWheelMapButtonIcon.PWBI_Icon_NONE;
        m_aPowerIcons[nIcon].bMapped = bMapped;
        m_aPowerIcons[nIcon].oMappedIcon.eIcon = eButton;
        // These symbols coexist in one authored SWF frame, not separate frames.
        for (nButton = 1; nButton < 9; ++nButton)
        {
            oPanel.SetClipVisibility(m_aPowerIcons[nIcon].oMappedIcon.sPath $ "." $ m_aMappingIconPaths[nButton], m_aPowerIcons[nIcon].bVisible && bMapped && nButton == int(eButton));
        }
        oPanel.SetClipVisibility(m_aPowerIcons[nIcon].oMappedIcon.sPath, m_aPowerIcons[nIcon].bVisible && bMapped);
        oPanel.SetClipVisibility("mainContent." $ m_aPowerIcons[nIcon].sMappedBGPath, m_aPowerIcons[nIcon].bVisible && bMapped);
    }
}
