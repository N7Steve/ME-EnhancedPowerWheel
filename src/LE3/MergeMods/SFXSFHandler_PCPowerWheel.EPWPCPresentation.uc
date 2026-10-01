public final function EPWPCPresentation()
{
    local GFxValue oWheel;
    local GFxValue oHint;
    local GFxValue oSwitch;
    local GFxValue oBadge;
    local GFxValue oKeyText;
    local array<ASValue> aArgs;
    local ASValue oCreated;
    local string sLabel;
    local string sKeys;
    local int nIcon;
    local int nSlot;
    local bool bVisible;

    oWheel = GetVariableObject(m_sWheelInnerPath);
    if (oWheel == None) { return; }
    bVisible = m_bVisible && m_ePowerWheelMode == SFXPowerWheelMode.PWM_PC && m_aPowerIconInfo.Length > 0 && Len(m_aPowerIconInfo[0].Id) >= 18;
    if (bVisible && m_pPlayerController.WorldInfo.RealTimeSeconds >= oWheel.GetNumber("EPWPCDiagNext"))
    {
        oWheel.SetNumber("EPWPCDiagNext", m_pPlayerController.WorldInfo.RealTimeSeconds + 1.0);
        oWheel.SetString("EPWPCDiag", "EPW16 INPUT PC state=" $ m_aPowerIconInfo[0].Id $ " space=" $ string(oWheel.GetBool("EPWPCSpaceDown")) $ " pressed=" $ string(oWheel.GetBool("EPWPCPressed")) $ " drag=" $ string(oWheel.GetBool("EPWPCDragging")) $ " source=" $ string(int(oWheel.GetNumber("EPWPCSource")) - 1) $ " absolute=" $ string(int(oWheel.GetNumber("EPWPCAbsolute")) - 1) $ " hover=" $ string(m_nCurrentPowerIconIndex));
    }
    // Keep legacy help clips hidden; do not create any Space tooltip.
    oHint = oWheel.GetObject("EPWPCHelp");
    if (oHint != None) { oHint.SetVisible(FALSE); }
    oSwitch = oWheel.GetObject("EPWPCSwitch");
    if (oSwitch != None) { oSwitch.SetVisible(FALSE); }
    // PC badges read existing keyboard assignments; they never write bindings.
    for (nIcon = 0; nIcon < m_aPowerIcons.Length; ++nIcon)
    {
        oBadge = m_aPowerIcons[nIcon].GetObject("EPWPCKeys");
        sKeys = "";
        if (bVisible && m_aPowerIcons[nIcon].bVisible && EPWHasPower(m_aPowerIcons[nIcon]))
        {
            for (nSlot = 0; nSlot < 8; ++nSlot)
            {
                if (m_aQuickSlotIcons[nSlot] == None || !EPWHasPower(m_aQuickSlotIcons[nSlot])) { continue; }
                if (m_aQuickSlotIcons[nSlot].pPawn == m_aPowerIcons[nIcon].pPawn && m_aQuickSlotIcons[nSlot].nmPowerName == m_aPowerIcons[nIcon].nmPowerName)
                {
                    oKeyText = GetVariableObject(m_aQuickSlotIcons[nSlot].sPath $ ".txtKey");
                    sLabel = oKeyText != None ? oKeyText.GetString("text") : "";
                    if (sLabel != "") { sKeys $= (sKeys == "" ? "" : "/") $ sLabel; }
                }
            }
        }
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
            oBadge = m_aPowerIcons[nIcon].GetObject("EPWPCKeys");
            if (oBadge != None) { oBadge.SetBool("html", TRUE); oBadge.SetBool("selectable", FALSE); }
        }
        if (oBadge != None)
        {
            oBadge.SetVisible(sKeys != "");
            oBadge.SetString("htmlText", "<font face='AeroLight Shared' size='16' color='#68B9E8'>" $ sKeys $ "</font>");
        }
    }
}
