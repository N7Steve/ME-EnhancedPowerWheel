public final function int EPWPowerKey(SFXPower oPower)
{
    local string sName;
    local int nChar;
    local int nKey;

    if (oPower == None) { return 0; }
    // LE2's base identity survives evolving a power into a different class.
    sName = Caps(string(oPower.BaseName));
    if (oPower.BaseName == 'None') { sName = Caps(string(oPower.PowerName)); }
    nKey = 1;
    for (nChar = 0; nChar < Len(sName); ++nChar)
    {
        nKey = (nKey * 31 + Asc(Mid(sName, nChar, 1))) % 10000019;
    }
    return nKey + 1;
}
