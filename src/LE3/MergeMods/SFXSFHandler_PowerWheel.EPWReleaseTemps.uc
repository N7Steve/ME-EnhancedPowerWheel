// Remove movie ownership after the last use. Normal engine GC owns destruction.
// Flash children/filters retain their Flash references independently of wrappers.
public final function EPWReleaseTemps(out array<GFxValue> aTemps)
{
    local int nValue;
    for (nValue = aTemps.Length - 1; nValue >= 0; --nValue)
    {
        if (aTemps[nValue] != None && aTemps[nValue].Outer == Self)
        {
            UnregisterGFxValue(aTemps[nValue]);
        }
    }
    aTemps.Length = 0;
}
