public final function ExInt_IconMouseUp(string sIconID)
{
    local int nIcon;
    local SFXPowerWheelMode eMode;
    local GFxValue oWheel;
    
    if (IsMouseShown() == FALSE)
    {
        return;
    }
    oWheel = GetVariableObject(m_sWheelInnerPath);
    if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_PC && oWheel != None)
    {
        EPWPCFinishDrag();
        if (oWheel.GetBool("EPWPCSuppressClick") || m_aPowerIconInfo.Length == 0 || Len(m_aPowerIconInfo[0].Id) != 18) { return; }
    }
    eMode = FindIconIndexFromPath(sIconID, nIcon);
    if (nIcon == -1 || eMode == SFXPowerWheelMode.PWM_NONE)
    {
        HandleQuickSlotMouseUp(sIconID);
        return;
    }
    if (m_nDraggingIcon == nIcon && m_bDoingDrag != FALSE)
    {
        m_nDraggingIcon = -1;
        return;
    }
    if (eMode == SFXPowerWheelMode.PWM_Powers && m_nCurrentPowerIconIndex == nIcon)
    {
        SelectCurrentWheelItem(1);
        m_pPlayerController.GenerateTutorialEvent(9);
    }
    else if (eMode == SFXPowerWheelMode.PWM_Weapons && m_nCurrentWeaponIconIndex == nIcon)
    {
        if (m_oWeaponIndices.aPlayer.Find(nIcon) != -1)
        {
            SelectCurrentWheelItem(2);
        }
        else if (m_oWeaponIndices.aHench1.Find(nIcon) != -1)
        {
            SwapHenchmanWeapon(m_pHench1Pawn);
        }
        else if (m_oWeaponIndices.aHench2.Find(nIcon) != -1)
        {
            SwapHenchmanWeapon(m_pHench2Pawn);
        }
    }
    m_nDraggingIcon = -1;
}