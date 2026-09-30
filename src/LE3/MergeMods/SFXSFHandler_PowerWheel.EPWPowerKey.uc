// Stable save identity independent of BBP's mutable WheelDisplayIndex.
public final function int EPWPowerKey(SFXPowerCustomActionBase oPower)
{
    local string sName;
    local int nChar;
    local int nKey;

    sName = Caps(string(oPower.PowerName));
    nKey = 1;
    for (nChar = 0; nChar < Len(sName); ++nChar)
    {
        nKey = (nKey * 31 + Asc(Mid(sName, nChar, 1))) % 10000019;
    }
    return nKey + 1;
}
