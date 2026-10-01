public final function EPWLayoutHelp(bool bShow)
{
    local array<string> aTexts;
    local array<string> aButtons;
    local array<string> aTargets;
    local int nRow;
    local int nVisible;
    local float fBaseY;
    local float fY;
    local float fTextX;
    local float fButtonX;
    local float fButtonOffset;
    local string sPath;
    local bool bRowVisible;

    // Keep native action order, followed by switch/order. Cache before moving
    // anything so reopening and weapon/PC modes can restore authored positions.
    aTexts.AddItem(m_sMapText2Path);
    aTexts.AddItem(m_sMapText1Path);
    aTexts.AddItem(m_sUseTextPath);
    aButtons.AddItem(m_sMapButton2Path);
    aButtons.AddItem(m_sMapButton1Path);
    aButtons.AddItem(m_sUseButtonPath);
    aTargets.AddItem(m_oMapTextIcon2.sPath);
    aTargets.AddItem(m_oMapTextIcon1.sPath);
    aTargets.AddItem("");
    for (nRow = 0; nRow < 3; ++nRow)
    {
        // Text, action glyph and trailing mapping glyph each have native offsets.
        for (nVisible = 0; nVisible < 3; ++nVisible)
        {
            sPath = nVisible == 0 ? aTexts[nRow] : (nVisible == 1 ? aButtons[nRow] : aTargets[nRow]);
            if (sPath == "") { continue; }
            if (!oPanel.GetVariableBool(sPath $ ".EPWHelpPositionCached"))
            {
                if (!bShow) { continue; }
                oPanel.SetVariableFloat(sPath $ ".EPWHelpX", oPanel.GetVariableFloat(sPath $ "._x"));
                oPanel.SetVariableFloat(sPath $ ".EPWHelpY", oPanel.GetVariableFloat(sPath $ "._y"));
                oPanel.SetVariableBool(sPath $ ".EPWHelpPositionCached", TRUE);
            }
            if (!bShow)
            {
                oPanel.SetVariableFloat(sPath $ "._x", oPanel.GetVariableFloat(sPath $ ".EPWHelpX"));
                oPanel.SetVariableFloat(sPath $ "._y", oPanel.GetVariableFloat(sPath $ ".EPWHelpY"));
            }
        }
    }
    if (!bShow) { return; }
    fBaseY = FMin(oPanel.GetVariableFloat(aTexts[0] $ ".EPWHelpY"), FMin(oPanel.GetVariableFloat(aTexts[1] $ ".EPWHelpY"), oPanel.GetVariableFloat(aTexts[2] $ ".EPWHelpY")));
    fTextX = oPanel.GetVariableFloat(m_sUseTextPath $ ".EPWHelpX");
    fButtonX = oPanel.GetVariableFloat(m_sUseButtonPath $ ".EPWHelpX");
    fButtonOffset = oPanel.GetVariableFloat(m_sUseButtonPath $ ".EPWHelpY") - oPanel.GetVariableFloat(m_sUseTextPath $ ".EPWHelpY");
    nVisible = 0;
    for (nRow = 0; nRow < 3; ++nRow)
    {
        bRowVisible = oPanel.GetVariableString(aTexts[nRow] $ ".text") != "";
        if (!bRowVisible) { continue; }
        fY = fBaseY + nVisible * 28.0;
        oPanel.SetVariableFloat(aTexts[nRow] $ "._x", fTextX);
        oPanel.SetVariableFloat(aTexts[nRow] $ "._y", fY);
        oPanel.SetVariableFloat(aButtons[nRow] $ "._x", fButtonX);
        oPanel.SetVariableFloat(aButtons[nRow] $ "._y", fY + fButtonOffset);
        if (aTargets[nRow] != "")
        {
            // X remains native: it follows the localized mapping label width.
            oPanel.SetVariableFloat(aTargets[nRow] $ "._y", fY + oPanel.GetVariableFloat(aTargets[nRow] $ ".EPWHelpY") - oPanel.GetVariableFloat(aTexts[nRow] $ ".EPWHelpY"));
        }
        ++nVisible;
    }
    for (nRow = 0; nRow < 2; ++nRow)
    {
        sPath = nRow == 0 ? "mainContent.EPWSwitchHint" : "mainContent.EPWOrderHint";
        fY = fBaseY + (nVisible + nRow) * 28.0;
        oPanel.SetVariableFloat(sPath $ "._x", fTextX);
        oPanel.SetVariableFloat(sPath $ "._y", fY);
        sPath = nRow == 0 ? "mainContent.EPWSwitchButton" : "mainContent.EPWOrderButton";
        oPanel.SetVariableFloat(sPath $ "._x", fButtonX - 16.0);
        oPanel.SetVariableFloat(sPath $ "._y", fY - 2.0);
    }
}
