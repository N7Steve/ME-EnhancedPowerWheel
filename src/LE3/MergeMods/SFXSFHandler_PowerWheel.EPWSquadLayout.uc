// Reorder GUI content only; never change a pawn's manager or display indices.
public final function EPWSquadLayout(BioPawn pPawn, array<int> aIndices, optional int nFrom = -1, optional int nTo = -1)
{
    local BioGlobalVariableTable oPlot;
    local SFXGUIValue_PowerIcon oIcon;
    local int nCompanion;
    local int nBase;
    local int nSlot;
    local int nSource;
    local int nKey;
    local int nChar;
    local int nSaved;
    local int nSwap;
    local string sName;
    local array<int> aKeys;
    local array<int> aOrder;
    local array<int> aUsed;
    local array<SFXPowerCustomActionBase> aPowers;
    local array<BioPawn> aPawns;
    local array<Name> aPowerNames;
    local array<string> aNames;
    local array<string> aDescriptions;
    local array<string> aResources;
    local array<string> aInfo;
    local array<int> aIconIds;
    local array<int> aCooldowns;
    local array<SFXPowerWheelPowerState> aStates;
    local array<SFXPowerWheelPowerState> aDesiredStates;
    local array<bool> aDelayedFlash;
    local array<bool> aFlashWhenTextChanges;
    local bool bSwap;
    local GFxValue oWheel;
    local string sRecord;
    local GFxValue oLoader;
    local array<ASValue> aIconArgs;
    local int nState;
    local int nIconIndex;
    local string sSlotPrefix;
    local array<bool> aVisible;

    if (pPawn == None) { return; }
    if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_PC && aIndices.Length != 5)
    {
        // PC's list may describe populated powers. Ordering needs all five
        // authored physical slots, including holes, as in the controller UI.
        if (pPawn == m_pHench1Pawn) { sSlotPrefix = "Icon10"; }
        else if (pPawn == m_pHench2Pawn) { sSlotPrefix = "Icon20"; }
        else { return; }
        aIndices.Length = 0;
        for (nSlot = 1; nSlot <= 5; ++nSlot)
        {
            for (nIconIndex = 0; nIconIndex < m_aPowerIcons.Length; ++nIconIndex)
            {
                if (m_aPowerIcons[nIconIndex].sID == (sSlotPrefix $ string(nSlot)))
                {
                    aIndices.AddItem(nIconIndex);
                    break;
                }
            }
        }
    }
    if (aIndices.Length != 5)
    {
        return;
    }
    // Fixed banks by the installed game's companion tags, independent of side.
    nCompanion = -1;
    switch (pPawn.Tag)
    {
        case 'hench_garrus': nCompanion = 0; break;
        case 'hench_tali': nCompanion = 1; break;
        case 'hench_liara': nCompanion = 2; break;
        case 'hench_ashley': nCompanion = 3; break;
        case 'hench_kaidan': nCompanion = 4; break;
        case 'hench_edi': nCompanion = 5; break;
        case 'hench_prothean': nCompanion = 6; break;
        case 'hench_marine': nCompanion = 7; break;
        case 'hench_anderson': nCompanion = 8; break;
    }
    oPlot = BioWorldInfo(oWorldInfo).GetGlobalVariables();
    nBase = 740300 + nCompanion * 6;
    bSwap = nFrom >= 0 && nFrom < 5 && nTo >= 0 && nTo < 5;
    for (nSlot = 0; nSlot < 5; ++nSlot)
    {
        oIcon = m_aPowerIcons[aIndices[nSlot]];
        aVisible.AddItem(oIcon.GetBool("_visible"));
        nKey = 0;
        // Native setup can retain an empty visual state on an occupied source.
        // A real power reference defines content; availability is refreshed below.
        if (oIcon.pPower != None || EPWHasPower(oIcon))
        {
            sName = Caps(string(oIcon.pPower != None ? oIcon.pPower.PowerName : oIcon.nmPowerName));
            nKey = 1;
            for (nChar = 0; nChar < Len(sName); ++nChar)
            {
                nKey = (nKey * 31 + Asc(Mid(sName, nChar, 1))) % 10000019;
            }
            ++nKey;
        }
        aKeys.AddItem(nKey);
        aOrder.AddItem(nSlot);
        aPowers.AddItem(oIcon.pPower);
        aPawns.AddItem(oIcon.pPawn);
        aPowerNames.AddItem(oIcon.nmPowerName);
        aNames.AddItem(oIcon.sName);
        aDescriptions.AddItem(oIcon.sDescription);
        aResources.AddItem(oIcon.sIconResource);
        aInfo.AddItem(oIcon.CurrentInfoText);
        aIconIds.AddItem(oIcon.nIcon);
        aCooldowns.AddItem(oIcon.nCooldownValue);
        aStates.AddItem(oIcon.eState);
        aDesiredStates.AddItem(oIcon.eDesiredState);
        aDelayedFlash.AddItem(oIcon.bDelayedFlash);
        aFlashWhenTextChanges.AddItem(oIcon.FlashWhenTextChanges);
    }
    if (bSwap)
    {
        nSwap = aOrder[nFrom];
        aOrder[nFrom] = aOrder[nTo];
        aOrder[nTo] = nSwap;
        if (oPlot != None && nCompanion >= 0)
        {
            // Match Shepard's custom plot writes: skip native plot processing.
            oPlot.SetInt(nBase, 0, TRUE);
            for (nSlot = 0; nSlot < 5; ++nSlot)
            {
                oPlot.SetInt(nBase + 1 + nSlot, aKeys[aOrder[nSlot]], TRUE);
            }
            oPlot.SetInt(nBase, 1, TRUE);
        }
    }
    else if (oPlot != None && nCompanion >= 0 && oPlot.GetInt(nBase) == 1)
    {
        for (nSlot = 0; nSlot < 5; ++nSlot)
        {
            aOrder[nSlot] = -1;
            nSaved = oPlot.GetInt(nBase + 1 + nSlot);
            if (nSaved == 0) { continue; }
            for (nSource = 0; nSource < 5; ++nSource)
            {
                if (aKeys[nSource] == nSaved && aUsed.Find(nSource) < 0)
                {
                    aOrder[nSlot] = nSource;
                    aUsed.AddItem(nSource);
                    break;
                }
            }
        }
        // Learned/new powers fill holes without displacing saved identities.
        for (nSource = 0; nSource < 5; ++nSource)
        {
            if (aKeys[nSource] != 0 && aUsed.Find(nSource) < 0)
            {
                nSlot = aOrder.Find(-1);
                if (nSlot >= 0) { aOrder[nSlot] = nSource; }
            }
        }
    }
    // One bounded latest write/load record per side, using the existing reader.
    // Readback distinguishes a plot-write failure from opening reconstruction.
    oWheel = GetVariableObject(m_sWheelInnerPath);
    if (oWheel != None)
    {
        sRecord = "EPW16 INPUT squad tag=" $ string(pPawn.Tag) $ " bank=" $ string(nCompanion) $ " swap=" $ string(bSwap);
        if (oPlot != None && nCompanion >= 0)
        {
            sRecord $= " marker=" $ string(oPlot.GetInt(nBase));
            for (nSlot = 0; nSlot < 5; ++nSlot)
            {
                nSource = aOrder[nSlot];
                sRecord $= " slot" $ string(nSlot) $ "=" $ string(oPlot.GetInt(nBase + 1 + nSlot)) $ "/" $ string(nSource >= 0 ? aKeys[nSource] : 0);
            }
        }
        else { sRecord $= " persistence=UNAVAILABLE"; }
        oWheel.SetString((bSwap ? "EPWSquadWrite" : "EPWSquadLoad") $ (pPawn == m_pHench1Pawn ? "1" : "2"), sRecord);
        LogInternal(sRecord, 'EPW16');
    }
    for (nSlot = 0; nSlot < 5; ++nSlot)
    {
        oIcon = m_aPowerIcons[aIndices[nSlot]];
        nSource = aOrder[nSlot];
        oIcon.SetHover(FALSE, TRUE);
        oIcon.SetSelected(FALSE);
        oIcon.ClearIcon();
        // ClearIcon invalidates image content even when the proxy path matches.
        oLoader = GetVariableObject(oIcon.sPath $ ".powerIconMC.sub.notSuggested");
        if (oLoader != None) { oLoader.SetString("EPWProxyPath", ""); }
        oIcon.pPower = None;
        oIcon.pPawn = None;
        oIcon.nmPowerName = 'None';
        oIcon.sName = "";
        oIcon.sDescription = "";
        oIcon.CurrentInfoText = "";
        oIcon.nCooldownValue = 0;
        oIcon.bDelayedFlash = FALSE;
        oIcon.FlashWhenTextChanges = FALSE;
        if (nSource >= 0 && aKeys[nSource] != 0)
        {
            oIcon.pPawn = aPawns[nSource];
            oIcon.SetPower(aPowers[nSource]);
            oIcon.nmPowerName = aPowerNames[nSource];
            oIcon.SetIcon(aIconIds[nSource], aResources[nSource]);
            oIcon.sName = aNames[nSource];
            oIcon.sDescription = aDescriptions[nSource];
            oIcon.CurrentInfoText = aInfo[nSource];
            oIcon.nCooldownValue = aCooldowns[nSource];
            oIcon.bDelayedFlash = aDelayedFlash[nSource];
            oIcon.FlashWhenTextChanges = aFlashWhenTextChanges[nSource];
            if (aStates[nSource] == SFXPowerWheelPowerState.PWPS_Selected || aStates[nSource] == SFXPowerWheelPowerState.PWPS_EmptySelectable || aStates[nSource] == SFXPowerWheelPowerState.PWPS_EmptySelected)
            {
                // Match Shepard's occupied-source normalization, then let the
                // native hover/leave cycle below evaluate actual availability.
                oIcon.eDesiredState = SFXPowerWheelPowerState.PWPS_Selectable;
                oIcon.SetState(SFXPowerWheelPowerState.PWPS_Selectable, TRUE);
            }
            else
            {
                oIcon.eDesiredState = aDesiredStates[nSource];
                if (oIcon.eDesiredState == SFXPowerWheelPowerState.PWPS_EmptySelectable || oIcon.eDesiredState == SFXPowerWheelPowerState.PWPS_EmptySelected)
                {
                    oIcon.eDesiredState = aStates[nSource];
                }
                oIcon.SetState(aStates[nSource], TRUE);
            }
        }
        else
        {
            oIcon.eDesiredState = SFXPowerWheelPowerState.PWPS_EmptySelectable;
            oIcon.SetState(SFXPowerWheelPowerState.PWPS_EmptySelectable, TRUE);
        }
        oIcon.bMapped = EPWHasPower(oIcon) && GetHenchmanMappedPower(pPawn) == oIcon.nmPowerName;
        oIcon.oMappedIcon.eIcon = oIcon.bMapped ? (pPawn == m_pHench1Pawn ? SFXPowerWheelMapButtonIcon.PWBI_DPadLeft : SFXPowerWheelMapButtonIcon.PWBI_DPadRight) : SFXPowerWheelMapButtonIcon.PWBI_Icon_NONE;
        oIcon.bDirty = TRUE;
        if (m_ePowerWheelMode == SFXPowerWheelMode.PWM_PC)
        {
            // Preserve the displayed page and synchronize native visibility.
            oIcon.SetVisible(aVisible[nSlot]);
        }
        oIcon.UpdateDisplay();
        oIcon.SetStateDisplay();
        oIcon.MadeVisible(oIcon.bVisible);
        if (EPWHasPower(oIcon))
        {
            oIcon.SetHover(TRUE, TRUE);
            oIcon.SetSelected(TRUE);
            oIcon.SetHover(FALSE, TRUE);
            oIcon.SetSelected(FALSE);
            // Each occupied SWF state owns a separate image loader. Native
            // state changes can expose a loader that SetIcon did not populate
            // while the destination still had its previous empty visual state.
            // Initialize image content only; native state/visibility stays intact.
            aIconArgs.Length = 2;
            aIconArgs[0].Type = ASType.AS_String;
            aIconArgs[0].S = oIcon.sIconResource;
            aIconArgs[1].Type = ASType.AS_Number;
            aIconArgs[1].N = oIcon.nIcon;
            sRecord = "";
            for (nState = 0; nState < 8; ++nState)
            {
                if (nState == int(SFXPowerWheelPowerState.PWPS_EmptySelectable) || nState == int(SFXPowerWheelPowerState.PWPS_EmptySelected)) { continue; }
                oLoader = GetVariableObject(oIcon.sPath $ ".powerIconMC.sub." $ oIcon.m_aPowerStatePaths[nState] $ ".iconMC");
                if (oLoader != None)
                {
                    sRecord $= " loader" $ string(nState) $ "=" $ string(int(oLoader.GetNumber("m_nIcon"))) $ "/" $ string(oLoader.GetBool("IsLoading")) $ "/" $ string(oLoader.GetBool("_visible"));
                    // Authored SetIcon checks the OLD cached index before assigning
                    // the new one. Seed it to avoid Failed() on a cleared loader.
                    oLoader.SetNumber("m_nIcon", float(oIcon.nIcon));
                    oLoader.Invoke("SetIcon", aIconArgs);
                }
            }
            // Bounded diagnostics for an initial invisible-image reproduction.
            sRecord = "EPW16 INPUT squad image tag=" $ string(pPawn.Tag) $ " slot=" $ string(nSlot) $ " power=" $ string(oIcon.nmPowerName) $ " state=" $ string(oIcon.eState) $ " desired=" $ string(oIcon.eDesiredState) $ " icon=" $ string(oIcon.nIcon) $ " resource=" $ oIcon.sIconResource $ sRecord;
            if (oWheel != None) { oWheel.SetString("EPWSquadImage" $ string(aIndices[nSlot]), sRecord); }
        }
    }
}
