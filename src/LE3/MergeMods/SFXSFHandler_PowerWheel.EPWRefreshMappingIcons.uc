public final function EPWRefreshMappingIcons()
{
    local BioPlayerInput oInput;
    local SFXGUIValue_PowerIcon oIcon;
    local SFXPowerWheelMapButtonIcon eButton;
    local int nSlot;
    local int nButton;
    local int nSide;
    local bool bMapped;

    // PC owns eight keyboard assignments and has no controller badge paths.
    if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_PC) { return; }
    if (m_pPlayerController == None)
    {
        return;
    }
    oInput = BioPlayerInput(m_pPlayerController.PlayerInput);
    if (oInput == None)
    {
        return;
    }
    for (nSlot = 0; nSlot < m_aPowerIcons.Length; ++nSlot)
    {
        oIcon = m_aPowerIcons[nSlot];
        eButton = SFXPowerWheelMapButtonIcon.PWBI_Icon_NONE;
        nSide = 0;
        if (oIcon.bHenchIcon)
        {
            if (EPWHasPower(oIcon) && GetHenchmanMappedPower(oIcon.pPawn) == oIcon.nmPowerName)
            {
                eButton = oIcon.pPawn == m_pHench1Pawn ? SFXPowerWheelMapButtonIcon.PWBI_DPadLeft : SFXPowerWheelMapButtonIcon.PWBI_DPadRight;
            }
        }
        else if (oIcon.pPower != None)
        {
            // AutoMapXbox/save data use class names; also accept the power name.
            // Read the actual input assignments, never the isolated setup icon.
            if (oInput.m_nmMappedPower3 != 'None' && (oIcon.pPower.Class.Name == oInput.m_nmMappedPower3 || oIcon.pPower.PowerName == oInput.m_nmMappedPower3))
            {
                eButton = SFXPowerWheelMapButtonIcon.PWBI_FaceButtonTop;
            }
            else if (oInput.m_nmMappedPower != 'None' && (oIcon.pPower.Class.Name == oInput.m_nmMappedPower || oIcon.pPower.PowerName == oInput.m_nmMappedPower))
            {
                nSide = 1;
            }
            else if (oInput.m_nmMappedPower2 != 'None' && (oIcon.pPower.Class.Name == oInput.m_nmMappedPower2 || oIcon.pPower.PowerName == oInput.m_nmMappedPower2))
            {
                nSide = 2;
            }
        }
        if (nSide != 0)
        {
            if (IsTriggerSouthpaw()) { nSide = 3 - nSide; }
            if (IsTriggerShoulderSwapped())
            {
                eButton = nSide == 1 ? SFXPowerWheelMapButtonIcon.PWBI_TriggerLeft : SFXPowerWheelMapButtonIcon.PWBI_TriggerRight;
            }
            else
            {
                eButton = nSide == 1 ? SFXPowerWheelMapButtonIcon.PWBI_ShoulderLeft : SFXPowerWheelMapButtonIcon.PWBI_ShoulderRight;
            }
        }
        bMapped = eButton != SFXPowerWheelMapButtonIcon.PWBI_Icon_NONE;
        // These are GUI metadata only; no input/save assignment is written.
        oIcon.bMapped = bMapped;
        oIcon.oMappedIcon.eIcon = eButton;
        for (nButton = 1; nButton < 9; ++nButton)
        {
            // All badge symbols coexist in one SWF frame, as named child clips.
            oPanel.SetClipVisibility(oIcon.oMappedIcon.sPath $ "." $ m_aMappingIconPaths[nButton], oIcon.bVisible && bMapped && nButton == int(eButton));
        }
        oPanel.SetClipVisibility(oIcon.oMappedIcon.sPath, oIcon.bVisible && bMapped);
        oPanel.SetClipVisibility(oIcon.sMappedBGPath, oIcon.bVisible && bMapped);
    }
}
