public event function WheelVisibilityChanged(bool bVisible)
{
    local int nIcon;
    local GFxValue oHenchBG;
    local GFxValue oWheel;
    local GFxValue oKey;
    local array<ASValue> aArgs;
    local ASValue oDown;
    
    oWheel = GetVariableObject(m_sWheelInnerPath);
    EPWPCFinishDrag(TRUE);
    if (oWheel != None)
    {
        oWheel.SetBool("EPWPCPressed", FALSE);
        oWheel.SetBool("EPWPCDragging", FALSE);
        oWheel.SetBool("EPWPCSuppressClick", FALSE);
        if (bVisible)
        {
            oWheel.SetBool("EPWPCWasHandlingKeys", m_bHandleKeyPresses);
            StartHandlingKeyPresses();
            oKey = GetVariableObject("_global.Key");
            if (oKey != None)
            {
                aArgs.Length = 1;
                aArgs[0].Type = ASType.AS_Number;
                aArgs[0].N = 32.0;
                oDown = oKey.Invoke("isDown", aArgs);
                oWheel.SetBool("EPWPCSpaceDown", oDown.B);
            }
        }
        else if (!oWheel.GetBool("EPWPCWasHandlingKeys"))
        {
            StopHandlingKeyPresses();
        }
    }
    SetMouseShown(bVisible);
    Super.WheelVisibilityChanged(bVisible);
    if (!bVisible)
    {
        oPanel.GotoFrameAndStop("mainContent.DashMain.Dash.Player", 1);
        m_bDashboardWeaponsOpen = FALSE;
        SendMouseEvent(52);
        for (nIcon = 0; nIcon < 8; ++nIcon)
        {
            m_aQuickSlotIcons[nIcon].bDragHover = FALSE;
            m_aQuickSlotIcons[nIcon].SetSelected(FALSE);
            m_aQuickSlotIcons[nIcon].UpdateDisplay();
        }
    }
    else if (HaveHenchmen() == FALSE)
    {
        oHenchBG = GetVariableObject("mainContent.DashMain.Dash.teamPanel1");
        oHenchBG.SetVisible(FALSE);
        oHenchBG = GetVariableObject("mainContent.DashMain.Dash.teamPanel2");
        oHenchBG.SetVisible(FALSE);
    }
    oPanel.SetClipVisibility("mainContent.QuickSlots.Control", bVisible);
    m_oCenterWeaponIcon.oIconMC.SetVisible(bVisible);
    EPWPCPresentation();
}
