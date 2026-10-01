public final function EPWUpdateUI(bool bShow)
{
    local array<ASParams> aArgs;
    local int nRow;
    local int nArg;
    local int nSlot;
    local int nIcon;
    local int nSelected;
    local int nPage;
    local float fX;
    local float fY;
    local float fButtonX;
    local string sTextPath;
    local string sButtonPath;
    local string sLabel;
    local string sNativeHelp;
    local bool bEnglish;
    local string sTexture;
    local string sOutlinePath;
    local bool bSelected;

    if (oPanel == None || !oPanel.bInitialized || oPanel.bToBeRemoved)
    {
        return;
    }
    bShow = bShow && m_ePowerWheelMode == SFXPowerWheelMode.PWM_Powers && oPanel.GetVariableBool("EPWLE2Open");
    nSelected = oPanel.GetVariableInt("EPWLE2Selected");
    nPage = oPanel.GetVariableInt("EPWLE2Page");
    if (bShow)
    {
        EPWRefreshMappingIcons();
        EPWUpdateSuggestedDisplay();
    }
    sNativeHelp = Caps(oPanel.GetVariableString(m_sUseTextPath $ ".text") $ " " $ oPanel.GetVariableString(m_sMapText1Path $ ".text") $ " " $ oPanel.GetVariableString(m_sMapText2Path $ ".text"));
    if (InStr(sNativeHelp, "USE POWER") >= 0 || InStr(sNativeHelp, "MAP POWER") >= 0)
    {
        oPanel.SetVariableBool("EPWLE2HelpEnglish", TRUE);
    }
    else if (InStr(sNativeHelp, "USAR PODER") >= 0 || InStr(sNativeHelp, "ASIGNAR") >= 0)
    {
        oPanel.SetVariableBool("EPWLE2HelpEnglish", FALSE);
    }
    bEnglish = oPanel.GetVariableBool("EPWLE2HelpEnglish");
    if (bShow && !oPanel.GetVariableBool("EPWLE2HelpCreated"))
    {
        fX = oPanel.GetVariableFloat(m_sUseTextPath $ "._x");
        fY = oPanel.GetVariableFloat(m_sUseTextPath $ "._y") + 28.0;
        fButtonX = oPanel.GetVariableFloat(m_sUseButtonPath $ "._x") - 16.0;
        // The authored vanilla actions have a 26-28 pixel baseline interval.
        for (nRow = 0; nRow < 2; ++nRow)
        {
            aArgs.Length = 6;
            aArgs[0].Type = ASParamTypes.ASParam_String;
            aArgs[0].sVar = nRow == 0 ? "EPWSwitchHint" : "EPWOrderHint";
            aArgs[1].Type = ASParamTypes.ASParam_Integer;
            aArgs[1].nVar = 900 + nRow * 2;
            for (nArg = 2; nArg < 6; ++nArg) { aArgs[nArg].Type = ASParamTypes.ASParam_Float; }
            aArgs[2].fVar = fX;
            aArgs[3].fVar = fY + nRow * 28.0;
            aArgs[4].fVar = 280.0;
            aArgs[5].fVar = 28.0;
            oPanel.InvokeMethodArgs("mainContent.createTextField", aArgs);
            aArgs[0].sVar = nRow == 0 ? "EPWSwitchButton" : "EPWOrderButton";
            aArgs[1].nVar = 901 + nRow * 2;
            aArgs[2].fVar = fButtonX;
            aArgs[3].fVar = fY + nRow * 28.0 - 2.0;
            aArgs[4].fVar = 34.0;
            aArgs[5].fVar = 28.0;
            oPanel.InvokeMethodArgs("mainContent.createTextField", aArgs);
        }
        oPanel.SetVariableBool("EPWLE2HelpCreated", TRUE);
    }
    for (nRow = 0; nRow < 2; ++nRow)
    {
        sTextPath = nRow == 0 ? "mainContent.EPWSwitchHint" : "mainContent.EPWOrderHint";
        sButtonPath = nRow == 0 ? "mainContent.EPWSwitchButton" : "mainContent.EPWOrderButton";
        oPanel.SetClipVisibility(sTextPath, bShow);
        oPanel.SetClipVisibility(sButtonPath, bShow);
        if (bShow)
        {
            // Runtime text fields default to device fonts and non-HTML text.
            // Use the movie's embedded AeroLight font and parse the icon markup.
            oPanel.SetVariableBool(sTextPath $ ".embedFonts", TRUE);
            oPanel.SetVariableBool(sButtonPath $ ".embedFonts", TRUE);
            oPanel.SetVariableBool(sTextPath $ ".html", TRUE);
            oPanel.SetVariableBool(sButtonPath $ ".html", TRUE);
            oPanel.SetVariableString(sTextPath $ ".shadowStyle", "s{1,1}t{0,0}");
            oPanel.SetVariableInt(sTextPath $ ".shadowColor", 3342336);
            if (bEnglish)
            {
                sLabel = nRow == 0 ? "Switch wheel" : (nSelected >= 0 ? "Place / Swap" : "Reorder power");
            }
            else
            {
                sLabel = nRow == 0 ? "Alternar rueda" : (nSelected >= 0 ? "Colocar / Intercambiar" : "Reordenar poder");
            }
            // Match LE2's authored help font, size and amber color.
            oPanel.SetVariableString(sTextPath $ ".htmlText", "<font face=\"AeroLight Shared\" size=\"16\" color=\"#ffb47b\">" $ sLabel $ "</font>");
            sTexture = nRow == 0 ? "GUI_SF_Xbox_ControllerIcons.Xbox_ControllerIcons_I2E" : "GUI_SF_Xbox_ControllerIcons.Xbox_ControllerIcons_I1F";
            oPanel.SetVariableString(sButtonPath $ ".htmlText", "<p align=\"center\"><font face=\"AeroLight Shared\" size=\"16\"><img src=\"img://" $ sTexture $ "\" width=\"24\" height=\"24\"/></font></p>");
            oPanel.SetVariableBool(sTextPath $ ".selectable", FALSE);
            oPanel.SetVariableBool(sButtonPath $ ".selectable", FALSE);
        }
    }
    EPWLayoutHelp(bShow);
    for (nSlot = 0; nSlot < m_oPowerIndices.aPlayer.Length; ++nSlot)
    {
        nIcon = m_oPowerIndices.aPlayer[nSlot];
        if (nIcon < 0 || nIcon >= m_aPowerIcons.Length) { continue; }
        sOutlinePath = m_aPowerIcons[nIcon].sPath $ ".powerIconMC.sub.EPWMoveOutlineBlue";
        bSelected = bShow && nSelected == nPage * 8 + nSlot && m_aPowerIcons[nIcon].pPower != None;
        if (bSelected && !oPanel.GetVariableBool(sOutlinePath $ ".EPWDrawn"))
        {
            aArgs.Length = 2;
            aArgs[0].Type = ASParamTypes.ASParam_String;
            aArgs[0].sVar = "EPWMoveOutlineBlue";
            aArgs[1].Type = ASParamTypes.ASParam_Integer;
            aArgs[1].nVar = 102;
            oPanel.InvokeMethodArgs(m_aPowerIcons[nIcon].sPath $ ".powerIconMC.sub.createEmptyMovieClip", aArgs);
            aArgs.Length = 3;
            aArgs[0].Type = ASParamTypes.ASParam_Float;
            aArgs[0].fVar = 2.20;
            aArgs[1].Type = ASParamTypes.ASParam_Float;
            aArgs[1].fVar = 3714303.00;
            aArgs[2].Type = ASParamTypes.ASParam_Float;
            aArgs[2].fVar = 100.00;
            oPanel.InvokeMethodArgs(sOutlinePath $ ".lineStyle", aArgs);
            aArgs.Length = 2;
            aArgs[0].Type = ASParamTypes.ASParam_Float;
            aArgs[0].fVar = -37.00;
            aArgs[1].Type = ASParamTypes.ASParam_Float;
            aArgs[1].fVar = -6.45;
            oPanel.InvokeMethodArgs(sOutlinePath $ ".moveTo", aArgs);
            aArgs.Length = 4;
            aArgs[0].Type = ASParamTypes.ASParam_Float;
            aArgs[0].fVar = -10.20;
            aArgs[1].Type = ASParamTypes.ASParam_Float;
            aArgs[1].fVar = -11.25;
            aArgs[2].Type = ASParamTypes.ASParam_Float;
            aArgs[2].fVar = 16.65;
            aArgs[3].Type = ASParamTypes.ASParam_Float;
            aArgs[3].fVar = -4.95;
            oPanel.InvokeMethodArgs(sOutlinePath $ ".curveTo", aArgs);
            aArgs.Length = 2;
            aArgs[0].Type = ASParamTypes.ASParam_Float;
            aArgs[0].fVar = 16.65;
            aArgs[1].Type = ASParamTypes.ASParam_Float;
            aArgs[1].fVar = 22.90;
            oPanel.InvokeMethodArgs(sOutlinePath $ ".lineTo", aArgs);
            aArgs.Length = 2;
            aArgs[0].Type = ASParamTypes.ASParam_Float;
            aArgs[0].fVar = 6.05;
            aArgs[1].Type = ASParamTypes.ASParam_Float;
            aArgs[1].fVar = 33.55;
            oPanel.InvokeMethodArgs(sOutlinePath $ ".lineTo", aArgs);
            aArgs.Length = 2;
            aArgs[0].Type = ASParamTypes.ASParam_Float;
            aArgs[0].fVar = -33.60;
            aArgs[1].Type = ASParamTypes.ASParam_Float;
            aArgs[1].fVar = 33.55;
            oPanel.InvokeMethodArgs(sOutlinePath $ ".lineTo", aArgs);
            aArgs.Length = 2;
            aArgs[0].Type = ASParamTypes.ASParam_Float;
            aArgs[0].fVar = -44.25;
            aArgs[1].Type = ASParamTypes.ASParam_Float;
            aArgs[1].fVar = 22.90;
            oPanel.InvokeMethodArgs(sOutlinePath $ ".lineTo", aArgs);
            aArgs.Length = 2;
            aArgs[0].Type = ASParamTypes.ASParam_Float;
            aArgs[0].fVar = -44.25;
            aArgs[1].Type = ASParamTypes.ASParam_Float;
            aArgs[1].fVar = -4.95;
            oPanel.InvokeMethodArgs(sOutlinePath $ ".lineTo", aArgs);
            aArgs.Length = 2;
            aArgs[0].Type = ASParamTypes.ASParam_Float;
            aArgs[0].fVar = -39.40;
            aArgs[1].Type = ASParamTypes.ASParam_Float;
            aArgs[1].fVar = -6.00;
            oPanel.InvokeMethodArgs(sOutlinePath $ ".lineTo", aArgs);
            aArgs.Length = 2;
            aArgs[0].Type = ASParamTypes.ASParam_Float;
            aArgs[0].fVar = -37.00;
            aArgs[1].Type = ASParamTypes.ASParam_Float;
            aArgs[1].fVar = -6.45;
            oPanel.InvokeMethodArgs(sOutlinePath $ ".lineTo", aArgs);
            oPanel.SetVariableBool(sOutlinePath $ ".EPWDrawn", TRUE);
        }
        oPanel.SetClipVisibility(sOutlinePath, bSelected);
    }
}
