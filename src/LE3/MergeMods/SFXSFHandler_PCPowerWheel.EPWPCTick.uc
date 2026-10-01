public final function EPWPCTick()
{
    local array<GFxValue> aEPWTemps;
    local GFxValue oKey;
    local ASValue oDown;
    local array<ASValue> aArgs;
    local bool bSpaceDown;
    local int nSource;
    local int nAbsolute;
    local int nTarget;
    local float fX;
    local float fY;
    local string sState;

    if (m_aPowerIconInfo.Length == 0 || !m_bVisible || m_ePowerWheelMode != SFXPowerWheelMode.PWM_PC) { EPWReleaseTemps(aEPWTemps); return; }
    if (!HasFocus())
    {
        EPWPCFinishDrag(TRUE);
        EPWReleaseTemps(aEPWTemps); return;
    }
    // Flash Key uses keycode 32; rising edges avoid repeats while held.
    oKey = EPWTempValue(GetVariableObject("_global.Key"), aEPWTemps);
    if (oKey != None)
    {
        aArgs.Length = 1;
        aArgs[0].Type = ASType.AS_Number;
        aArgs[0].N = 32.0;
        oDown = oKey.Invoke("isDown", aArgs);
        bSpaceDown = oDown.B;
    }
    if (bSpaceDown && !GetVariableBool(m_sWheelInnerPath $ ".EPWPCSpaceDown") && Len(m_aPowerIconInfo[0].Id) == 18)
    {
        if (GetVariableBool(m_sWheelInnerPath $ ".EPWPCPressed") && !GetVariableBool(m_sWheelInnerPath $ ".EPWPCDragging"))
        {
            EPWPCFinishDrag(TRUE);
            SetVariableBool(m_sWheelInnerPath $ ".EPWPCSuppressClick", TRUE);
        }
        if (GetVariableBool(m_sWheelInnerPath $ ".EPWPCDragging") && GetVariableNumber(m_sWheelInnerPath $ ".EPWPCAbsolute") <= 0.0)
        {
            // Squad powers cannot move across Shepard's pages.
            EPWPCFinishDrag(TRUE);
        }
        LeavePowerIcon(m_nCurrentPowerIconIndex, TRUE);
        Super.HandleInputEvent(BioGuiEvents.BIOGUI_EVENT_BUTTON_RTHUMB, 1.0);
    }
    SetVariableBool(m_sWheelInnerPath $ ".EPWPCSpaceDown", bSpaceDown);
    if (!GetVariableBool(m_sWheelInnerPath $ ".EPWPCPressed")) { EPWReleaseTemps(aEPWTemps); return; }
    nSource = int(GetVariableNumber(m_sWheelInnerPath $ ".EPWPCSource")) - 1;
    if (nSource < 0 || nSource >= m_aPowerIcons.Length) { EPWReleaseTemps(aEPWTemps); return; }
    if (!GetVariableBool(m_sWheelInnerPath $ ".EPWPCDragging"))
    {
        fX = GetVariableNumber("_root._xmouse") - GetVariableNumber(m_sWheelInnerPath $ ".EPWPCDownX");
        fY = GetVariableNumber("_root._ymouse") - GetVariableNumber(m_sWheelInnerPath $ ".EPWPCDownY");
        if (fX * fX + fY * fY < m_fDragStartThreshold * m_fDragStartThreshold) { EPWReleaseTemps(aEPWTemps); return; }
        sState = m_aPowerIconInfo[0].Id;
        if (Len(sState) != 18) { EPWReleaseTemps(aEPWTemps); return; }
        SetVariableBool(m_sWheelInnerPath $ ".EPWPCDragging", TRUE);
        SetVariableBool(m_sWheelInnerPath $ ".EPWPCSuppressClick", TRUE);
        nAbsolute = int(GetVariableNumber(m_sWheelInnerPath $ ".EPWPCAbsolute")) - 1;
        if (nAbsolute >= 0)
        {
            m_aPowerIconInfo[0].Id = Left(sState, 16) $ Mid("ABCDEFGHIJKLMNOP", nAbsolute, 1) $ Mid(sState, 17);
        }
        else
        {
            SetVariableNumber(m_sWheelInnerPath $ ".EPWSquadSelected", float(nSource + 1));
        }
        m_aPowerIcons[nSource].AS_BeginDragging();
        PlayGuiSound('HUDPowerWheelQueueingHighlightedPowerForActivation');
    }
    if (Len(m_aPowerIconInfo[0].Id) == 18)
    {
        // Native roll events clear bDown on exit and omit destination mouse-up.
        // Hit testing also keeps empty destinations hoverable during an AS drag.
        nTarget = EPWPCDropTarget();
        if (nTarget >= 0)
        {
            HoverPowerIcon(nTarget, TRUE);
        }
        else
        {
            LeavePowerIcon(m_nCurrentPowerIconIndex, TRUE);
        }
    }
    EPWReleaseTemps(aEPWTemps);
}
