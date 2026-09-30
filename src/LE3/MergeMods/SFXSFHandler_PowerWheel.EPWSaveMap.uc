public final function EPWSaveMap(string sMap, array<SFXPowerCustomActionBase> aPowers)
{
    local BioGlobalVariableTable oPlot;
    local int nSlot;
    local int nSource;
    local int nPacked;
    local int nValue;

    oPlot = BioWorldInfo(oWorldInfo).GetGlobalVariables();
    if (oPlot == None)
    {
        return;
    }
    oPlot.SetInt(740200, 0, TRUE);
    for (nSlot = 0; nSlot < 16; ++nSlot)
    {
        nSource = InStr("0123456789ABCDEF", Mid(sMap, nSlot, 1));
        nValue = 16;
        if (nSource >= 0 && nSource < aPowers.Length)
        {
            nValue = nSource;
            oPlot.SetInt(740210 + nSlot, EPWPowerKey(aPowers[nSource]), TRUE);
        }
        else
        {
            oPlot.SetInt(740210 + nSlot, 0, TRUE);
        }
        nPacked = nPacked * 17 + nValue;
        if (nSlot % 4 == 3)
        {
            oPlot.SetInt(740201 + nSlot / 4, nPacked, TRUE);
            nPacked = 0;
        }
    }
    oPlot.SetInt(740200, 3, TRUE);
}
