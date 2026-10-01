public final function EPWPCPresentation(optional bool bClosing = FALSE)
{
    local array<GFxValue> aEPWTemps;
    local GFxValue oBadge;
    local array<ASValue> aArgs;
    local ASValue oCreated;
    local string sLabel;
    local string sKeys;
    local int nIcon;
    local int nSlot;
    local bool bVisible;

    if ((!m_bVisible || m_ePowerWheelMode != SFXPowerWheelMode.PWM_PC) && !bClosing) { EPWReleaseTemps(aEPWTemps); return; }
    bVisible = !bClosing && m_bVisible && m_ePowerWheelMode == SFXPowerWheelMode.PWM_PC && m_aPowerIconInfo.Length > 0 && Len(m_aPowerIconInfo[0].Id) >= 18;
    if (bVisible && m_pPlayerController.WorldInfo.RealTimeSeconds >= GetVariableNumber(m_sWheelInnerPath $ ".EPWPCDiagNext"))
    {
        SetVariableNumber(m_sWheelInnerPath $ ".EPWPCDiagNext", m_pPlayerController.WorldInfo.RealTimeSeconds + 1.0);
        SetVariableString(m_sWheelInnerPath $ ".EPWPCDiag", "EPW16 INPUT PC state=" $ m_aPowerIconInfo[0].Id $ " space=" $ string(GetVariableBool(m_sWheelInnerPath $ ".EPWPCSpaceDown")) $ " pressed=" $ string(GetVariableBool(m_sWheelInnerPath $ ".EPWPCPressed")) $ " drag=" $ string(GetVariableBool(m_sWheelInnerPath $ ".EPWPCDragging")) $ " source=" $ string(int(GetVariableNumber(m_sWheelInnerPath $ ".EPWPCSource")) - 1) $ " absolute=" $ string(int(GetVariableNumber(m_sWheelInnerPath $ ".EPWPCAbsolute")) - 1) $ " hover=" $ string(m_nCurrentPowerIconIndex));
    }
    // Legacy help cleanup uses scalar paths, including the close transition.
    SetVariableBool(m_sWheelInnerPath $ ".EPWPCHelp._visible", FALSE);
    SetVariableBool(m_sWheelInnerPath $ ".EPWPCSwitch._visible", FALSE);
    // PC badges read existing keyboard assignments; they never write bindings.
    for (nIcon = 0; nIcon < m_aPowerIcons.Length; ++nIcon)
    {
        sKeys = "";
        if (bVisible && m_aPowerIcons[nIcon].bVisible && EPWHasPower(m_aPowerIcons[nIcon]))
        {
            for (nSlot = 0; nSlot < 8; ++nSlot)
            {
                if (m_aQuickSlotIcons[nSlot] == None || !EPWHasPower(m_aQuickSlotIcons[nSlot])) { continue; }
                if (m_aQuickSlotIcons[nSlot].pPawn == m_aPowerIcons[nIcon].pPawn && m_aQuickSlotIcons[nSlot].nmPowerName == m_aPowerIcons[nIcon].nmPowerName)
                {
                    sLabel = GetVariableString(m_aQuickSlotIcons[nSlot].sPath $ ".txtKey.text");
                    if (sLabel != "") { sKeys $= (sKeys == "" ? "" : "/") $ sLabel; }
                }
            }
        }
        // Existing labels only need wrappers when their assignment changes.
        if (sKeys == GetVariableString(m_aPowerIcons[nIcon].sPath $ ".EPWPCKeys.EPWKeys")) { continue; }
        oBadge = EPWTempValue(m_aPowerIcons[nIcon].GetObject("EPWPCKeys"), aEPWTemps);
        if (oBadge == None && sKeys != "")
        {
            aArgs.Length = 6;
            aArgs[0].Type = ASType.AS_String;
            aArgs[0].S = "EPWPCKeys";
            aArgs[1].Type = ASType.AS_Number;
            aArgs[1].N = 1200.0;
            aArgs[2].Type = ASType.AS_Number;
            aArgs[2].N = 4.0;
            aArgs[3].Type = ASType.AS_Number;
            aArgs[3].N = -2.0;
            aArgs[4].Type = ASType.AS_Number;
            aArgs[4].N = 75.0;
            aArgs[5].Type = ASType.AS_Number;
            aArgs[5].N = 22.0;
            oCreated = m_aPowerIcons[nIcon].Invoke("createTextField", aArgs);
            oBadge = EPWTempValue(m_aPowerIcons[nIcon].GetObject("EPWPCKeys"), aEPWTemps);
            if (oBadge != None) { oBadge.SetBool("html", TRUE); oBadge.SetBool("selectable", FALSE); }
        }
        if (oBadge != None)
        {
            oBadge.SetString("EPWKeys", sKeys);
            oBadge.SetVisible(sKeys != "");
            oBadge.SetString("htmlText", "<font face='AeroLight Shared' size='16' color='#68B9E8'>" $ sKeys $ "</font>");
        }
    }
    EPWReleaseTemps(aEPWTemps);
}
