public final function bool EPWSaveMap(string sMap, array<SFXPowerWheelIconPower> aSources)
{
    local BioWorldInfo oWorld;
    local BioGlobalVariableTable oPlot;
    local int nSlot;
    local int nSource;
    local int nPowers;
    local array<int> aKeys;
    local bool bChanged;

    if (Len(sMap) != 16 || aSources.Length != 8) { return FALSE; }
    for (nSource = 0; nSource < aSources.Length; ++nSource)
    {
        if (aSources[nSource].pPower != None) { ++nPowers; }
    }
    // A not-yet-ready native setup must not erase an existing saved layout.
    if (nPowers == 0) { return FALSE; }
    oWorld = BioWorldInfo(oWorldInfo);
    if (oWorld == None) { return FALSE; }
    oPlot = oWorld.GetGlobalVariables();
    if (oPlot == None) { return FALSE; }
    // LE2 serializes dense integer arrays. Use 17 small project-allocated IDs,
    // not LE3's sparse high IDs. Refuse to overwrite an occupied foreign block.
    if (oPlot.IntVariables.Length > 7400 && oPlot.GetInt(7400) != 1162893105)
    {
        for (nSlot = 7400; nSlot < Min(7417, oPlot.IntVariables.Length); ++nSlot)
        {
            if (oPlot.GetInt(nSlot) != 0) { return FALSE; }
        }
    }
    aKeys.Length = 16;
    bChanged = oPlot.IntVariables.Length < 7417;
    for (nSlot = 0; nSlot < 16; ++nSlot)
    {
        nSource = InStr("01234567", Mid(sMap, nSlot, 1));
        if (nSource >= 0) { aKeys[nSlot] = EPWPowerKey(aSources[nSource].pPower); }
        if (oPlot.IntVariables.Length > 7401 + nSlot && oPlot.GetInt(7401 + nSlot) != aKeys[nSlot]) { bChanged = TRUE; }
    }
    if (!bChanged && oPlot.GetInt(7400) == 1162893105) { return TRUE; }
    if (oPlot.IntVariables.Length < 7417) { oPlot.IntVariables.Length = 7417; }
    oPlot.SetInt(7400, 0);
    for (nSlot = 0; nSlot < 16; ++nSlot)
    {
        oPlot.SetInt(7401 + nSlot, aKeys[nSlot]);
    }
    // EPW1 marker is written last. The game persists this table on normal save.
    oPlot.SetInt(7400, 1162893105);
    return TRUE;
}
