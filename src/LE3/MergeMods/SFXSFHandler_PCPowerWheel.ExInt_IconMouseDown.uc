public final function ExInt_IconMouseDown(string sIconID)
{
    local array<GFxValue> aEPWTemps;
    local int nIcon;
    local SFXPowerWheelMode eMode;
    local GFxValue oWheel;
    local GFxValue oRoot;
    local SFXGUIValue_PowerIcon oSource;
    local int nSlot;
    
    if (IsMouseShown() == FALSE)
    {
        EPWReleaseTemps(aEPWTemps); return;
    }
    oWheel = EPWTempValue(GetVariableObject(m_sWheelInnerPath), aEPWTemps);
    if (oWheel != None) { oWheel.SetBool("EPWPCSuppressClick", FALSE); }
    m_bDraggingPower = FALSE;
    eMode = FindIconIndexFromPath(sIconID, nIcon);
    if (nIcon == -1 || eMode == SFXPowerWheelMode.PWM_NONE)
    {
        HandleQuickSlotMouseDown(sIconID);
        EPWReleaseTemps(aEPWTemps); return;
    }
    if (eMode == SFXPowerWheelMode.PWM_Powers)
    {
        if (m_aPowerIcons[nIcon].eState != SFXPowerWheelPowerState.PWPS_EmptySelectable && m_aPowerIcons[nIcon].eState != SFXPowerWheelPowerState.PWPS_EmptySelected)
        {
            m_bDraggingPower = TRUE;
        }
    }
    if (eMode == SFXPowerWheelMode.PWM_Powers && m_ePowerWheelMode == SFXPowerWheelMode.PWM_PC && m_bVisible)
    {
        // EPW owns lower-bar drags; native quickslot/weapon gestures stay native.
        m_bDraggingPower = FALSE;
        m_nDraggingIcon = -1;
        if (m_aPowerIconInfo.Length == 0 || Len(m_aPowerIconInfo[0].Id) != 18) { EPWReleaseTemps(aEPWTemps); return; }
        oWheel = EPWTempValue(GetVariableObject(m_sWheelInnerPath), aEPWTemps);
        oRoot = EPWTempValue(GetVariableObject("_root"), aEPWTemps);
        if (oWheel == None || oRoot == None) { EPWReleaseTemps(aEPWTemps); return; }
        oWheel.SetBool("EPWPCSuppressClick", FALSE);
        if (!EPWHasPower(m_aPowerIcons[nIcon]) || m_oDragPowerIcon == None) { EPWReleaseTemps(aEPWTemps); return; }
        oSource = m_aPowerIcons[nIcon];
        if (IsPawnBlocked(oSource.pPawn)) { EPWReleaseTemps(aEPWTemps); return; }
        oWheel.SetBool("EPWPCPressed", TRUE);
        oWheel.SetBool("EPWPCDragging", FALSE);
        oWheel.SetNumber("EPWPCSource", float(nIcon + 1));
        nSlot = m_oPowerIndices.aPlayer.Find(nIcon);
        oWheel.SetNumber("EPWPCAbsolute", nSlot >= 0 ? float(int(Mid(m_aPowerIconInfo[0].Id, 17, 1)) * 8 + nSlot + 1) : 0.0);
        oWheel.SetNumber("EPWPCDownX", oRoot.GetNumber("_xmouse"));
        oWheel.SetNumber("EPWPCDownY", oRoot.GetNumber("_ymouse"));
        // Capture the original identity/artwork before either page is rebuilt.
        m_oDragPowerIcon.SetPower(oSource.pPower);
        m_oDragPowerIcon.pPawn = oSource.pPawn;
        m_oDragPowerIcon.nmPowerName = oSource.nmPowerName;
        m_oDragPowerIcon.SetIcon(oSource.nIcon, oSource.sIconResource);
        m_oDragPowerIcon.sName = oSource.sName;
        m_oDragPowerIcon.sDescription = oSource.sDescription;
        m_oDragPowerIcon.eDesiredState = SFXPowerWheelPowerState.PWPS_Selected;
        m_oDragPowerIcon.SetState(SFXPowerWheelPowerState.PWPS_Selected, TRUE);
        m_oDragPowerIcon.UpdateDisplay();
        EPWReleaseTemps(aEPWTemps); return;
    }
    m_nDraggingIcon = nIcon;
    EPWReleaseTemps(aEPWTemps);
}
