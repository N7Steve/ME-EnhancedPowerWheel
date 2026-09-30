public final function EPWUpdateSwitchHint(bool bVisible)
{
    local GFxValue oWheel;
    local GFxValue oHint;
    local GFxValue oIcon;
    local GFxValue oTemplate;
    local GFxValue oButton;
    local GFxValue oRow;
    local GFxValue oGlow;
    local GFxValue oFilters;
    local array<GFxValue> aTexts;
    local array<GFxValue> aButtons;
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
    local string sNativeText;
    local float fButtonOffset;
    local int nRow;
    local int nArg;

    oWheel = GetVariableObject(m_sWheelInnerPath);
    if (oWheel == None)
    {
        return;
    }
    oHint = oWheel.GetObject("EPWSwitchHint");
    oIcon = oWheel.GetObject("EPWSwitchButton");
    // Native order, top to bottom. Cache authored positions for other wheel modes.
    aTexts.AddItem(GetVariableObject(m_sMapText3Path));
    aButtons.AddItem(GetVariableObject(m_sMapButton3Path));
    aTexts.AddItem(GetVariableObject(m_sMapText2Path));
    aButtons.AddItem(GetVariableObject(m_sMapButton2Path));
    aTexts.AddItem(GetVariableObject(m_sMapText1Path));
    aButtons.AddItem(GetVariableObject(m_sMapButton1Path));
    aTexts.AddItem(GetVariableObject(m_sUseTextPath));
    aButtons.AddItem(GetVariableObject(m_sUseButtonPath));
    for (nRow = 0; nRow < aTexts.Length; ++nRow)
    {
        if (aTexts[nRow] != None && aButtons[nRow] != None && !aTexts[nRow].GetBool("EPWHelpCached"))
        {
            oNativeDisplay = aTexts[nRow].GetDisplayInfo();
            aTexts[nRow].SetNumber("EPWHelpNativeY", oNativeDisplay.Y);
            oNativeDisplay = aButtons[nRow].GetDisplayInfo();
            aButtons[nRow].SetNumber("EPWHelpNativeY", oNativeDisplay.Y);
            aTexts[nRow].SetBool("EPWHelpCached", TRUE);
        }
    }
    if (!bVisible || !m_bShowUseMapText || m_ePowerWheelMode != SFXPowerWheelMode.PWM_Powers)
    {
        if (oHint != None) { oHint.SetVisible(FALSE); }
        if (oIcon != None) { oIcon.SetVisible(FALSE); }
        for (nRow = 0; nRow < aTexts.Length; ++nRow)
        {
            if (aTexts[nRow] != None && aButtons[nRow] != None && aTexts[nRow].GetBool("EPWHelpPacked"))
            {
                oRowDisplay.hasY = TRUE;
                oRowDisplay.Y = aTexts[nRow].GetNumber("EPWHelpNativeY");
                aTexts[nRow].SetDisplayInfo(oRowDisplay);
                oRowDisplay.Y = aButtons[nRow].GetNumber("EPWHelpNativeY");
                aButtons[nRow].SetDisplayInfo(oRowDisplay);
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
    // Pack all visible actions and Switch Wheel with one baseline interval.
    oTemplateDisplay = oTemplate.GetDisplayInfo();
    oButtonDisplay = oButton.GetDisplayInfo();
    oRowDisplay.hasY = TRUE;
    fY = aTexts[0].GetNumber("EPWHelpNativeY");
    for (nRow = 0; nRow < aTexts.Length; ++nRow)
    {
        oRow = aTexts[nRow];
        if (oRow != None && aButtons[nRow] != None && oRow.GetText() != "")
        {
            sNativeText $= Caps(oRow.GetText()) $ " ";
            fButtonOffset = aButtons[nRow].GetNumber("EPWHelpNativeY") - oRow.GetNumber("EPWHelpNativeY");
            // Only Y is ours. Rewriting native text X from _x each frame drifts.
            oRowDisplay.Y = fY;
            oRow.SetDisplayInfo(oRowDisplay);
            oRowDisplay.Y = fY + fButtonOffset;
            aButtons[nRow].SetDisplayInfo(oRowDisplay);
            oRow.SetBool("EPWHelpPacked", TRUE);
            fY += 28.0;
        }
    }
    for (nRow = 0; nRow < 2; ++nRow)
    {
        if ((nRow == 0 && oHint != None) || (nRow == 1 && oIcon != None))
        {
            continue;
        }
        aArgs.Length = 0;
        vDepth = oWheel.Invoke("getNextHighestDepth", aArgs);
        aArgs.Length = 6;
        aArgs[0].Type = ASType.AS_String;
        aArgs[0].S = nRow == 0 ? "EPWSwitchHint" : "EPWSwitchButton";
        for (nArg = 1; nArg < 6; ++nArg)
        {
            aArgs[nArg].Type = ASType.AS_Number;
        }
        aArgs[1].N = vDepth.N;
        aArgs[2].N = oTemplateDisplay.X;
        aArgs[3].N = fY;
        aArgs[4].N = nRow == 0 ? oTemplate.GetNumber("_width") : 32.0;
        aArgs[5].N = 36.0;
        oWheel.Invoke("createTextField", aArgs);
        oRow = oWheel.GetObject(aArgs[0].S);
        if (oRow != None)
        {
            oRow.SetBool("selectable", FALSE);
            oRow.SetBool("embedFonts", TRUE);
            if (nRow == 0)
            {
                oHint = oRow;
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
                    oHint.SetObject("filters", oFilters);
                }
            }
            else
            {
                oIcon = oRow;
                // The same installed texture used by the native R3 control token.
                oIcon.SetText("<font face=\"AeroLight Shared\" size=\"20\"><img src=\"img://BIOA_ControllerIcons_XBOX.xbox_R_press\" width=\"24\" height=\"24\"/></font>", TRUE);
            }
        }
    }
    if (oHint == None || oIcon == None)
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
    if (sLanguage == "SPA" || Left(sLanguage, 2) == "ES" || oHint.GetBool("EPWSpanishText"))
    {
        sLabel = "Alternar rueda";
    }
    if (oHint.GetString("EPWLabel") != sLabel)
    {
        oHint.SetText("<font face=\"AeroLight Shared\" size=\"20\" color=\"#79c9fd\">" $ sLabel $ "</font>", TRUE);
        oHint.SetString("EPWLabel", sLabel);
    }
    oRowDisplay.hasX = TRUE;
    oRowDisplay.X = oTemplateDisplay.X;
    oRowDisplay.Y = fY;
    oHint.SetDisplayInfo(oRowDisplay);
    oRowDisplay.X = oButtonDisplay.X - 12.0;
    oRowDisplay.Y = fY - 2.0;
    oIcon.SetDisplayInfo(oRowDisplay);
    oHint.SetVisible(TRUE);
    oIcon.SetVisible(TRUE);
}
