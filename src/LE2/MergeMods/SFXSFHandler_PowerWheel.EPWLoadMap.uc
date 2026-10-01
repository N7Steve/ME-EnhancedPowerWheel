public final function string EPWLoadMap(array<SFXPowerWheelIconPower> aSources)
{
    local BioWorldInfo oWorld;
    local BioGlobalVariableTable oPlot;
    local int nSlot;
    local int nSource;
    local int nKey;
    local string sMap;
    local string sSource;

    oWorld = BioWorldInfo(oWorldInfo);
    if (oWorld == None) { return "01234567--------"; }
    oPlot = oWorld.GetGlobalVariables();
    if (oPlot == None || oPlot.IntVariables.Length < 7417 || oPlot.GetInt(7400) != 1162893105)
    {
        return "01234567--------";
    }
    sMap = "----------------";
    for (nSlot = 0; nSlot < 16; ++nSlot)
    {
        nKey = oPlot.GetInt(7401 + nSlot);
        if (nKey <= 0) { continue; }
        for (nSource = 0; nSource < aSources.Length; ++nSource)
        {
            sSource = Mid("01234567", nSource, 1);
            if (aSources[nSource].pPower != None && EPWPowerKey(aSources[nSource].pPower) == nKey && InStr(sMap, sSource) < 0)
            {
                sMap = Left(sMap, nSlot) $ sSource $ Mid(sMap, nSlot + 1);
                break;
            }
        }
    }
    // New powers take the first free position. Retain the eight-source map
    // invariant by adding native empty entries only after all real powers.
    for (nSource = 0; nSource < aSources.Length; ++nSource)
    {
        sSource = Mid("01234567", nSource, 1);
        nSlot = InStr(sMap, "-");
        if (aSources[nSource].pPower != None && InStr(sMap, sSource) < 0 && nSlot >= 0)
        {
            sMap = Left(sMap, nSlot) $ sSource $ Mid(sMap, nSlot + 1);
        }
    }
    for (nSource = 0; nSource < aSources.Length; ++nSource)
    {
        sSource = Mid("01234567", nSource, 1);
        nSlot = InStr(sMap, "-");
        if (InStr(sMap, sSource) < 0 && nSlot >= 0)
        {
            sMap = Left(sMap, nSlot) $ sSource $ Mid(sMap, nSlot + 1);
        }
    }
    return sMap;
}
