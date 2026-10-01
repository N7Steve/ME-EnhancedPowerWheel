public final function EPWPCFinishDrag(optional bool bCancel = FALSE)
{
    local int nTarget;
    local int nSource;
    local int nSlot;
    local int nAbsolute;
    local string sState;
    local string sDrop;
    local bool bSameOwner;
    local SFXPowerCustomActionBase pOriginalPower;
    local BioPawn pOriginalPawn;
    local Name nmOriginal;
    local array<int> aSquadIndices;
    local BioPawn pSquadPawn;
    local string sSlotPrefix;
    local int nIconIndex;
    local int nNativeCount;
    local string sResult;

    if (!GetVariableBool(m_sWheelInnerPath $ ".EPWPCPressed")) { return; }
    SetVariableBool(m_sWheelInnerPath $ ".EPWPCPressed", FALSE);
    if (!GetVariableBool(m_sWheelInnerPath $ ".EPWPCDragging")) { return; }
    SetVariableBool(m_sWheelInnerPath $ ".EPWPCDragging", FALSE);
    SetVariableBool(m_sWheelInnerPath $ ".EPWPCSuppressClick", TRUE);
    nSource = int(GetVariableNumber(m_sWheelInnerPath $ ".EPWPCSource")) - 1;
    if (nSource >= 0 && nSource < m_aPowerIcons.Length)
    {
        // StopDragging references the shared DragPower ghost, even after paging.
        m_aPowerIcons[nSource].AS_StopDragging();
    }
    sState = m_aPowerIconInfo[0].Id;
    sResult = bCancel ? "cancel" : "fade-or-no-target";
    nTarget = -1;
    if (!bCancel && Len(sState) == 18)
    {
        nTarget = EPWPCDropTarget();
        if (nTarget >= 0)
        {
            nAbsolute = int(GetVariableNumber(m_sWheelInnerPath $ ".EPWPCAbsolute")) - 1;
            if (nAbsolute < 0 && nSource >= 0 && nSource < m_aPowerIcons.Length)
            {
                sSlotPrefix = Left(m_aPowerIcons[nSource].sID, 6);
                if (sSlotPrefix == "Icon10")
                {
                    aSquadIndices = m_oPowerIndices.aHench1;
                    pSquadPawn = m_pHench1Pawn;
                }
                else if (sSlotPrefix == "Icon20")
                {
                    aSquadIndices = m_oPowerIndices.aHench2;
                    pSquadPawn = m_pHench2Pawn;
                }
                nNativeCount = aSquadIndices.Length;
                if (pSquadPawn != None && (aSquadIndices.Length != 5 || aSquadIndices.Find(nSource) < 0 || aSquadIndices.Find(nTarget) < 0))
                {
                    aSquadIndices.Length = 0;
                    for (nSlot = 1; nSlot <= 5; ++nSlot)
                    {
                        for (nIconIndex = 0; nIconIndex < m_aPowerIcons.Length; ++nIconIndex)
                        {
                            if (m_aPowerIcons[nIconIndex].sID == (sSlotPrefix $ string(nSlot)))
                            {
                                aSquadIndices.AddItem(nIconIndex);
                                break;
                            }
                        }
                    }
                }
            }
            bSameOwner = (nAbsolute >= 0 && m_oPowerIndices.aPlayer.Find(nTarget) >= 0) || (nAbsolute < 0 && pSquadPawn != None && aSquadIndices.Length == 5 && aSquadIndices.Find(nSource) >= 0 && aSquadIndices.Find(nTarget) >= 0);
            sResult = bSameOwner ? "same-slot" : "other-character-or-missing-slots";
            if (bSameOwner)
            {
                if (nAbsolute >= 0)
                {
                    HoverPowerIcon(nTarget, TRUE);
                    HandleInputEvent(BioGuiEvents.BIOGUI_EVENT_BUTTON_LB, -1.0);
                    sResult = "player-drop";
                }
                else if (nSource != nTarget)
                {
                    // The PC drag already captured its source. Apply the same
                    // persistent layout as controller ordering to that companion.
                    if (pSquadPawn != None)
                    {
                        LeavePowerIcon(m_nCurrentPowerIconIndex, TRUE);
                        EPWSquadLayout(pSquadPawn, aSquadIndices, aSquadIndices.Find(nSource), aSquadIndices.Find(nTarget));
                        EPWUpdateSuggestedDisplay();
                        HoverPowerIcon(nTarget, TRUE);
                        PlayGuiSound('HUDPowerWheelQueueingHighlightedPowerForActivation');
                        sResult = "squad-drop";
                    }
                }
            }
        }
        else if (nSource >= 0 && nSource < m_aPowerIcons.Length)
        {
            // Preserve vanilla drag-to-quickslot mapping. The physical source may
            // now show the other page; supply the captured identity synchronously.
            sDrop = m_aPowerIcons[nSource].AS_GetDropTarget();
            for (nSlot = 0; nSlot < 8; ++nSlot)
            {
                if (m_aQuickSlotIcons[nSlot] == None || m_aQuickSlotIcons[nSlot].sID != sDrop) { continue; }
                pOriginalPower = m_aPowerIcons[nSource].pPower;
                pOriginalPawn = m_aPowerIcons[nSource].pPawn;
                nmOriginal = m_aPowerIcons[nSource].nmPowerName;
                m_aPowerIcons[nSource].pPower = m_oDragPowerIcon.pPower;
                m_aPowerIcons[nSource].pPawn = m_oDragPowerIcon.pPawn;
                m_aPowerIcons[nSource].nmPowerName = m_oDragPowerIcon.nmPowerName;
                NewSetQuickSlotPower(nSlot, nSource, TRUE, FALSE);
                sResult = "quickslot-drop";
                m_aPowerIcons[nSource].pPower = pOriginalPower;
                m_aPowerIcons[nSource].pPawn = pOriginalPawn;
                m_aPowerIcons[nSource].nmPowerName = nmOriginal;
                break;
            }
        }
    }
    if (m_aPowerIconInfo.Length > 0 && Len(m_aPowerIconInfo[0].Id) >= 18)
    {
        sState = m_aPowerIconInfo[0].Id;
        m_aPowerIconInfo[0].Id = Left(sState, 16) $ "X" $ Mid(sState, 17);
    }
    SetVariableNumber(m_sWheelInnerPath $ ".EPWSquadSelected", 0.0);
    SetVariableString(m_sWheelInnerPath $ ".EPWPCDropDiag", "EPW16 INPUT PC drop source=" $ string(nSource) $ " target=" $ string(nTarget) $ " nativeSlots=" $ string(nNativeCount) $ " slots=" $ string(aSquadIndices.Length) $ " result=" $ sResult);
    if (m_oDragPowerIcon != None) { m_oDragPowerIcon.Hide(); }
}
