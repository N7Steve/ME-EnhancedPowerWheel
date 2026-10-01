public final function EPWUpdateSwitchHint(bool bVisible)
{
    local GFxValue oWheel;
    local GFxValue oHint;
    local GFxValue oIcon;
    local GFxValue oOrderHint;
    local GFxValue oOrderIcon;
    local GFxValue oTarget;
    local GFxValue oTemplate;
    local GFxValue oButton;
    local GFxValue oRow;
    local GFxValue oGlow;
    local GFxValue oFilters;
    local GFxValue oProxy;
    local array<GFxValue> aTexts;
    local array<GFxValue> aButtons;
    local array<GFxValue> aTargets;
    local SFXEngine oEngine;
    local SFXProfileSettings oProfile;
    local array<ASValue> aArgs;
    local ASValue vDepth;
    local ASDisplayInfo oNativeDisplay;
    local ASDisplayInfo oRowDisplay;
    local ASDisplayInfo oTemplateDisplay;
    local ASDisplayInfo oButtonDisplay;
    local string sLabel;
    local string sLanguage;
    local float fY;
    local float fTopY;
    local string sNativeText;
    local float fButtonOffset;
    local string sHtml;
    local string sTexture;
    local string sTargetName;
    local float fIconSize;
    local float fTargetSize;
    local float fIconGap;
    local string sSource;
    local int nRow;
    local int nLayoutRow;
    local int nArg;
    local bool bSpanish;
    local bool bSelected;
    local bool bPlayerSlot;
    local bool bOccupied;
    local bool bShowOrder;
    local bool bSquadSlot;
    local int nSquadSelected;

    oWheel = GetVariableObject(m_sWheelInnerPath);
    if (oWheel == None)
    {
        return;
    }
    oHint = oWheel.GetObject("EPWSwitchHint");
    oIcon = oWheel.GetObject("EPWSwitchButton");
    oOrderHint = oWheel.GetObject("EPWOrderHint");
    oOrderIcon = oWheel.GetObject("EPWOrderButton");
    // Native order, top to bottom. Cache authored positions for other wheel modes.
    aTexts.AddItem(GetVariableObject(m_sMapText3Path));
    aButtons.AddItem(GetVariableObject(m_sMapButton3Path));
    aTexts.AddItem(GetVariableObject(m_sMapText2Path));
    aButtons.AddItem(GetVariableObject(m_sMapButton2Path));
    aTexts.AddItem(GetVariableObject(m_sMapText1Path));
    aButtons.AddItem(GetVariableObject(m_sMapButton1Path));
    aTexts.AddItem(GetVariableObject(m_sUseTextPath));
    aButtons.AddItem(GetVariableObject(m_sUseButtonPath));
    for (nRow = 0; nRow < 3; ++nRow)
    {
        aTargets.AddItem(oWheel.GetObject("EPWMapTarget" $ string(nRow)));
    }
    for (nRow = 0; nRow < aTexts.Length; ++nRow)
    {
        if (aTexts[nRow] != None && aButtons[nRow] != None && !aTexts[nRow].GetBool("EPWHelpCached"))
        {
            oNativeDisplay = aTexts[nRow].GetDisplayInfo();
            aTexts[nRow].SetNumber("EPWHelpNativeX", oNativeDisplay.X);
            aTexts[nRow].SetNumber("EPWHelpNativeY", oNativeDisplay.Y);
            oNativeDisplay = aButtons[nRow].GetDisplayInfo();
            aButtons[nRow].SetNumber("EPWHelpNativeX", oNativeDisplay.X);
            aButtons[nRow].SetNumber("EPWHelpNativeY", oNativeDisplay.Y);
            aTexts[nRow].SetBool("EPWHelpCached", TRUE);
        }
    }
    if (!bVisible || !m_bShowUseMapText || m_ePowerWheelMode != SFXPowerWheelMode.PWM_Powers)
    {
        if (oHint != None) { oHint.SetVisible(FALSE); }
        if (oIcon != None) { oIcon.SetVisible(FALSE); }
        if (oOrderHint != None) { oOrderHint.SetVisible(FALSE); }
        if (oOrderIcon != None) { oOrderIcon.SetVisible(FALSE); }
        for (nRow = 0; nRow < aTargets.Length; ++nRow)
        {
            if (aTargets[nRow] != None) { aTargets[nRow].SetVisible(FALSE); }
        }
        for (nRow = 0; nRow < aTexts.Length; ++nRow)
        {
            oProxy = oWheel.GetObject("EPWHelpText" $ string(nRow));
            if (oProxy != None) { oProxy.SetVisible(FALSE); }
            if (aTexts[nRow] != None && aButtons[nRow] != None && aTexts[nRow].GetBool("EPWHelpPacked"))
            {
                oRowDisplay.hasX = TRUE;
                oRowDisplay.hasY = TRUE;
                oRowDisplay.X = aTexts[nRow].GetNumber("EPWHelpNativeX");
                oRowDisplay.Y = aTexts[nRow].GetNumber("EPWHelpNativeY");
                aTexts[nRow].SetDisplayInfo(oRowDisplay);
                oRowDisplay.X = aButtons[nRow].GetNumber("EPWHelpNativeX");
                oRowDisplay.Y = aButtons[nRow].GetNumber("EPWHelpNativeY");
                aButtons[nRow].SetDisplayInfo(oRowDisplay);
                aTexts[nRow].SetVisible(aTexts[nRow].GetBool("EPWHelpNativeVisible"));
                aTexts[nRow].SetBool("EPWHelpPacked", FALSE);
            }
        }
        return;
    }
    oTemplate = aTexts[3];
    oButton = aButtons[3];
    if (oTemplate == None || oButton == None || aTexts[0] == None)
    {
        return;
    }
    // Keep the accepted spacing, with another 24 pixels right/up for the block.
    oTemplateDisplay = oTemplate.GetDisplayInfo();
    oButtonDisplay = oButton.GetDisplayInfo();
    // Read and write through the same display API; never feed runtime _x back.
    oTemplateDisplay.X = oTemplate.GetNumber("EPWHelpNativeX") + 56.0;
    oButtonDisplay.X = oButton.GetNumber("EPWHelpNativeX") + 48.0;
    oRowDisplay.hasX = TRUE;
    oRowDisplay.hasY = TRUE;
    fTopY = aTexts[0].GetNumber("EPWHelpNativeY") - 24.0;
    bSelected = m_aPowerIconInfo.Length > 0 && Len(m_aPowerIconInfo[0].Id) >= 18 && InStr("ABCDEFGHIJKLMNOP", Mid(m_aPowerIconInfo[0].Id, 16, 1)) >= 0;
    bPlayerSlot = m_nCurrentPowerIconIndex >= 0 && m_nCurrentPowerIconIndex < m_aPowerIcons.Length && m_oPowerIndices.aPlayer.Find(m_nCurrentPowerIconIndex) >= 0;
    bSquadSlot = m_nCurrentPowerIconIndex >= 0 && m_nCurrentPowerIconIndex < m_aPowerIcons.Length && ((m_pHench1Pawn != None && m_oPowerIndices.aHench1.Find(m_nCurrentPowerIconIndex) >= 0) || (m_pHench2Pawn != None && m_oPowerIndices.aHench2.Find(m_nCurrentPowerIconIndex) >= 0));
    if (bSquadSlot)
    {
        nSquadSelected = int(oWheel.GetNumber("EPWSquadSelected")) - 1;
        bSelected = nSquadSelected >= 0 && ((m_oPowerIndices.aHench1.Find(m_nCurrentPowerIconIndex) >= 0 && m_oPowerIndices.aHench1.Find(nSquadSelected) >= 0) || (m_oPowerIndices.aHench2.Find(m_nCurrentPowerIconIndex) >= 0 && m_oPowerIndices.aHench2.Find(nSquadSelected) >= 0));
    }
    bOccupied = (bPlayerSlot || bSquadSlot) && EPWHasPower(m_aPowerIcons[m_nCurrentPowerIconIndex]);
    bShowOrder = (bPlayerSlot || bSquadSlot) && (bSelected || bOccupied);
    // Switch first, contextual ordering second; hidden rows leave no gaps.
    fY = fTopY + 30.0;
    if (bShowOrder) { fY += 30.0; }
    // Native clip bounds do not translate to HTML image dimensions. The owner's
    // 1.9.12 screenshot shows 50-pixel HTML glyphs oversized; use 32 consistently.
    fIconSize = 32.0;
    fIconGap = oTemplateDisplay.X - oButtonDisplay.X;
    for (nLayoutRow = 0; nLayoutRow < aTexts.Length; ++nLayoutRow)
    {
        // Keep source/metadata indices intact; visit A, Y, B, X for layout.
        nRow = nLayoutRow == 0 ? 3 : nLayoutRow - 1;
        oRow = aTexts[nRow];
        oProxy = oWheel.GetObject("EPWHelpText" $ string(nRow));
        if (oRow != None && aButtons[nRow] != None && oRow.GetText() != "")
        {
            sNativeText $= Caps(oRow.GetText()) $ " ";
            sSource = oRow.GetText();
            while (Len(sSource) > 0 && Right(sSource, 1) == " ") { sSource = Left(sSource, Len(sSource) - 1); }
            if (oProxy == None)
            {
                aArgs.Length = 0;
                vDepth = oWheel.Invoke("getNextHighestDepth", aArgs);
                aArgs.Length = 6;
                aArgs[0].Type = ASType.AS_String;
                aArgs[0].S = "EPWHelpText" $ string(nRow);
                for (nArg = 1; nArg < 6; ++nArg) { aArgs[nArg].Type = ASType.AS_Number; }
                aArgs[1].N = vDepth.N;
                aArgs[2].N = oTemplateDisplay.X;
                aArgs[3].N = fY;
                aArgs[4].N = oRow.GetNumber("_width");
                aArgs[5].N = 36.0;
                oWheel.Invoke("createTextField", aArgs);
                oProxy = oWheel.GetObject(aArgs[0].S);
                if (oProxy != None)
                {
                    oProxy.SetBool("selectable", FALSE);
                    oProxy.SetBool("embedFonts", TRUE);
                    oGlow = CreateObject("flash.filters.GlowFilter");
                    oFilters = CreateArray();
                    if (oGlow != None && oFilters != None)
                    {
                        oGlow.SetNumber("color", 401457.0);
                        oGlow.SetNumber("alpha", 1.0);
                        oGlow.SetNumber("blurX", 2.0);
                        oGlow.SetNumber("blurY", 2.0);
                        oGlow.SetNumber("strength", 10.0);
                        oGlow.SetNumber("quality", 1.0);
                        oGlow.SetBool("inner", FALSE);
                        oGlow.SetBool("knockout", FALSE);
                        oFilters.SetElementObject(0, oGlow);
                        oProxy.SetObject("filters", oFilters);
                    }
                }
            }
            if (oProxy == None) { continue; }
            if (!oRow.GetBool("EPWHelpPacked"))
            {
                oNativeDisplay = oRow.GetDisplayInfo();
                oRow.SetBool("EPWHelpNativeVisible", oNativeDisplay.visible);
            }
            // Native fields supply localized plain text; SetMapText supplies
            // destination metadata independently of the text/HTML readback.
            oRow.SetVisible(FALSE);
            oRow = oProxy;
            sTexture = nRow < 3 ? oWheel.GetString("EPWMapTexture" $ string(nRow)) : "";
            oRow.SetString("EPWHelpTexture", sTexture);
            if (sSource != oRow.GetString("EPWHelpSourceProcessed"))
            {
                sHtml = Repl(sSource, "&", "&amp;");
                sHtml = Repl(sHtml, "<", "&lt;");
                sHtml = Repl(sHtml, ">", "&gt;");
                sHtml = "<font face=\"AeroLight Shared\" size=\"18\" color=\"#79c9fd\">" $ sHtml $ "</font>";
                oRow.SetText(sHtml, TRUE);
                oRow.SetString("EPWHelpSourceProcessed", sSource);
            }
            oRow.SetVisible(TRUE);
            // Text-only metrics now align Use and Map consistently; embedded
            // images no longer enlarge just the mapping rows' line boxes.
            fButtonOffset = oRow.GetNumber("textHeight") * 0.5 + 2.0;
            // Absolute cached coordinates keep the rightward offset stable.
            oRowDisplay.X = oTemplateDisplay.X;
            oRowDisplay.Y = fY;
            oRow.SetDisplayInfo(oRowDisplay);
            oRowDisplay.X = oButtonDisplay.X;
            oRowDisplay.Y = fY + fButtonOffset;
            aButtons[nRow].SetDisplayInfo(oRowDisplay);
            if (nRow < 3 && sTexture != "")
            {
                // The screenshot confirms face Y is smaller at 32. Its native
                // leading clip has a 50-pixel texture extent; bumpers keep 32.
                fTargetSize = sTexture == "YBtn" ? 50.0 : fIconSize;
                oTarget = aTargets[nRow];
                if (oTarget == None)
                {
                    sTargetName = "EPWMapTarget" $ string(nRow);
                    aArgs.Length = 0;
                    vDepth = oWheel.Invoke("getNextHighestDepth", aArgs);
                    aArgs.Length = 6;
                    aArgs[0].Type = ASType.AS_String;
                    aArgs[0].S = sTargetName;
                    for (nArg = 1; nArg < 6; ++nArg) { aArgs[nArg].Type = ASType.AS_Number; }
                    aArgs[1].N = vDepth.N;
                    aArgs[2].N = 0.0;
                    aArgs[3].N = 0.0;
                    aArgs[4].N = fTargetSize + 8.0;
                    aArgs[5].N = fTargetSize + 16.0;
                    oWheel.Invoke("createTextField", aArgs);
                    oTarget = oWheel.GetObject(sTargetName);
                    aTargets[nRow] = oTarget;
                    if (oTarget != None)
                    {
                        oTarget.SetBool("selectable", FALSE);
                        oTarget.SetBool("embedFonts", TRUE);
                    }
                }
                if (oTarget != None)
                {
                    if (oTarget.GetString("EPWTexture") != sTexture)
                    {
                        oTarget.SetNumber("_width", fTargetSize + 8.0);
                        oTarget.SetNumber("_height", fTargetSize + 16.0);
                        oTarget.SetText("<font face=\"AeroLight Shared\" size=\"18\"><img src=\"img://GUI_SF_Xbox_ControllerIcons.Xbox_ControllerIcons_" $ sTexture $ "\" width=\"" $ string(int(fTargetSize)) $ "\" height=\"" $ string(int(fTargetSize)) $ "\"/></font>", TRUE);
                        oTarget.SetString("EPWTexture", sTexture);
                    }
                    oRowDisplay.X = oTemplateDisplay.X + oRow.GetNumber("textWidth") + fIconGap - fTargetSize * 0.5;
                    oRowDisplay.Y = fY + fButtonOffset - oTarget.GetNumber("textHeight") * 0.5 - 2.0;
                    oTarget.SetDisplayInfo(oRowDisplay);
                    oTarget.SetVisible(TRUE);
                }
            }
            else if (nRow < 3 && aTargets[nRow] != None)
            {
                aTargets[nRow].SetVisible(FALSE);
            }
            aTexts[nRow].SetBool("EPWHelpPacked", TRUE);
            fY += 30.0;
        }
        else
        {
            if (oProxy != None) { oProxy.SetVisible(FALSE); }
            if (nRow < 3 && aTargets[nRow] != None) { aTargets[nRow].SetVisible(FALSE); }
        }
    }
    for (nRow = 0; nRow < 4; ++nRow)
    {
        if ((nRow == 0 && oHint != None) || (nRow == 1 && oIcon != None) || (nRow == 2 && oOrderHint != None) || (nRow == 3 && oOrderIcon != None))
        {
            continue;
        }
        aArgs.Length = 0;
        vDepth = oWheel.Invoke("getNextHighestDepth", aArgs);
        aArgs.Length = 6;
        aArgs[0].Type = ASType.AS_String;
        aArgs[0].S = nRow == 0 ? "EPWSwitchHint" : (nRow == 1 ? "EPWSwitchButton" : (nRow == 2 ? "EPWOrderHint" : "EPWOrderButton"));
        for (nArg = 1; nArg < 6; ++nArg)
        {
            aArgs[nArg].Type = ASType.AS_Number;
        }
        aArgs[1].N = vDepth.N;
        aArgs[2].N = oTemplateDisplay.X;
        aArgs[3].N = fY;
        aArgs[4].N = (nRow == 0 || nRow == 2) ? oTemplate.GetNumber("_width") : 40.0;
        aArgs[5].N = (nRow == 0 || nRow == 2) ? 36.0 : 48.0;
        oWheel.Invoke("createTextField", aArgs);
        oRow = oWheel.GetObject(aArgs[0].S);
        if (oRow != None)
        {
            oRow.SetBool("selectable", FALSE);
            oRow.SetBool("embedFonts", TRUE);
            if (nRow == 0 || nRow == 2)
            {
                if (nRow == 0) { oHint = oRow; }
                else { oOrderHint = oRow; }
                // Recreate the authored outline explicitly: copying the native
                // static filter array did not reproduce it in the owner screenshot.
                oGlow = CreateObject("flash.filters.GlowFilter");
                oFilters = CreateArray();
                if (oGlow != None && oFilters != None)
                {
                    oGlow.SetNumber("color", 401457.0); // 0x062031.
                    oGlow.SetNumber("alpha", 1.0);
                    oGlow.SetNumber("blurX", 2.0);
                    oGlow.SetNumber("blurY", 2.0);
                    oGlow.SetNumber("strength", 10.0);
                    oGlow.SetNumber("quality", 1.0);
                    oGlow.SetBool("inner", FALSE);
                    oGlow.SetBool("knockout", FALSE);
                    oFilters.SetElementObject(0, oGlow);
                    oRow.SetObject("filters", oFilters);
                }
            }
            else
            {
                if (nRow == 1)
                {
                    oIcon = oRow;
                    oIcon.SetText("<font face=\"AeroLight Shared\" size=\"18\"><img src=\"img://GUI_SF_Xbox_ControllerIcons.Xbox_ControllerIcons_RStickPress\" width=\"32\" height=\"32\"/></font>", TRUE);
                }
                else
                {
                    oOrderIcon = oRow;
                    oOrderIcon.SetText("<font face=\"AeroLight Shared\" size=\"18\"><img src=\"img://GUI_SF_Xbox_ControllerIcons.Xbox_ControllerIcons_LBumper\" width=\"32\" height=\"32\"/></font>", TRUE);
                }
            }
        }
    }
    if (oHint == None || oIcon == None || oOrderHint == None || oOrderIcon == None)
    {
        return;
    }
    oEngine = SFXEngine(Class'Engine'.static.GetEngine());
    if (oEngine != None)
    {
        oProfile = oEngine.GetProfileSettings();
        if (oProfile != None)
        {
            sLanguage = Caps(oProfile.GetLanguageText());
        }
    }
    // Spanish text mods may replace INT strings while the profile remains INT.
    if (InStr(sNativeText, "USAR PODER") >= 0 || InStr(sNativeText, "CAMBIAR A") >= 0)
    {
        oHint.SetBool("EPWSpanishText", TRUE);
    }
    else if (InStr(sNativeText, "USE POWER") >= 0 || InStr(sNativeText, "MAP TO") >= 0)
    {
        oHint.SetBool("EPWSpanishText", FALSE);
    }
    sLabel = "Switch wheel";
    bSpanish = sLanguage == "SPA" || Left(sLanguage, 2) == "ES" || oHint.GetBool("EPWSpanishText");
    if (bSpanish)
    {
        sLabel = "Alternar rueda";
    }
    if (oHint.GetString("EPWLabel") != sLabel)
    {
        oHint.SetText("<font face=\"AeroLight Shared\" size=\"18\" color=\"#79c9fd\">" $ sLabel $ "</font>", TRUE);
        oHint.SetString("EPWLabel", sLabel);
    }
    sLabel = bSelected ? (bOccupied ? "Swap" : "Place") : "Reorder power";
    if (bSpanish)
    {
        sLabel = bSelected ? (bOccupied ? "Intercambiar" : "Colocar") : "Reordenar poder";
    }
    if (oOrderHint.GetString("EPWLabel") != sLabel)
    {
        oOrderHint.SetText("<font face=\"AeroLight Shared\" size=\"18\" color=\"#79c9fd\">" $ sLabel $ "</font>", TRUE);
        oOrderHint.SetString("EPWLabel", sLabel);
    }
    oRowDisplay.X = oTemplateDisplay.X;
    oRowDisplay.Y = fTopY + 30.0;
    oOrderHint.SetDisplayInfo(oRowDisplay);
    oRowDisplay.X = oButtonDisplay.X - fIconSize * 0.5 - 2.0;
    oRowDisplay.Y = fTopY + 30.0 + oOrderHint.GetNumber("textHeight") * 0.5 - oOrderIcon.GetNumber("textHeight") * 0.5;
    oOrderIcon.SetDisplayInfo(oRowDisplay);
    oOrderHint.SetVisible(bShowOrder);
    oOrderIcon.SetVisible(bShowOrder);
    oRowDisplay.X = oTemplateDisplay.X;
    oRowDisplay.Y = fTopY;
    oHint.SetDisplayInfo(oRowDisplay);
    oRowDisplay.X = oButtonDisplay.X - fIconSize * 0.5 - 2.0;
    oRowDisplay.Y = fTopY + oHint.GetNumber("textHeight") * 0.5 - oIcon.GetNumber("textHeight") * 0.5;
    oIcon.SetDisplayInfo(oRowDisplay);
    oHint.SetVisible(TRUE);
    oIcon.SetVisible(TRUE);
}
