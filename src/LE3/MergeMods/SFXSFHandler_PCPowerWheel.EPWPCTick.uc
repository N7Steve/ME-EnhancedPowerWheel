public final function EPWPCTick()
{
    local GFxValue oWheel;
    local GFxValue oRoot;
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

    oWheel = GetVariableObject(m_sWheelInnerPath);
    if (oWheel == None || m_aPowerIconInfo.Length == 0 || !m_bVisible || m_ePowerWheelMode != SFXPowerWheelMode.PWM_PC) { return; }
    if (!HasFocus())
    {
        EPWPCFinishDrag(TRUE);
        return;
    }
    // Flash Key uses keycode 32; rising edges avoid repeats while held.
    oKey = GetVariableObject("_global.Key");
    if (oKey != None)
    {
        aArgs.Length = 1;
        aArgs[0].Type = ASType.AS_Number;
        aArgs[0].N = 32.0;
        oDown = oKey.Invoke("isDown", aArgs);
        bSpaceDown = oDown.B;
    }
    if (bSpaceDown && !oWheel.GetBool("EPWPCSpaceDown") && Len(m_aPowerIconInfo[0].Id) == 18)
    {
        if (oWheel.GetBool("EPWPCPressed") && !oWheel.GetBool("EPWPCDragging"))
        {
            EPWPCFinishDrag(TRUE);
            oWheel.SetBool("EPWPCSuppressClick", TRUE);
        }
        if (oWheel.GetBool("EPWPCDragging") && oWheel.GetNumber("EPWPCAbsolute") <= 0.0)
        {
            // Squad powers cannot move across Shepard's pages.
            EPWPCFinishDrag(TRUE);
        }
        LeavePowerIcon(m_nCurrentPowerIconIndex, TRUE);
        Super.HandleInputEvent(BioGuiEvents.BIOGUI_EVENT_BUTTON_RTHUMB, 1.0);
    }
    oWheel.SetBool("EPWPCSpaceDown", bSpaceDown);
    if (!oWheel.GetBool("EPWPCPressed")) { return; }
    oRoot = GetVariableObject("_root");
    if (oRoot == None) { return; }
    nSource = int(oWheel.GetNumber("EPWPCSource")) - 1;
    if (nSource < 0 || nSource >= m_aPowerIcons.Length) { return; }
    if (!oWheel.GetBool("EPWPCDragging"))
    {
        fX = oRoot.GetNumber("_xmouse") - oWheel.GetNumber("EPWPCDownX");
        fY = oRoot.GetNumber("_ymouse") - oWheel.GetNumber("EPWPCDownY");
        if (fX * fX + fY * fY < m_fDragStartThreshold * m_fDragStartThreshold) { return; }
        sState = m_aPowerIconInfo[0].Id;
        if (Len(sState) != 18) { return; }
        oWheel.SetBool("EPWPCDragging", TRUE);
        oWheel.SetBool("EPWPCSuppressClick", TRUE);
        nAbsolute = int(oWheel.GetNumber("EPWPCAbsolute")) - 1;
        if (nAbsolute >= 0)
        {
            m_aPowerIconInfo[0].Id = Left(sState, 16) $ Mid("ABCDEFGHIJKLMNOP", nAbsolute, 1) $ Mid(sState, 17);
        }
        else
        {
            oWheel.SetNumber("EPWSquadSelected", float(nSource + 1));
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
}
