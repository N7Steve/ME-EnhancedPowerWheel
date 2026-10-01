// Track only newly requested EPW wrappers, never persistent native icons.
public final function GFxValue EPWTempValue(GFxValue oValue, out array<GFxValue> aTemps)
{
    if (oValue != None && oValue.Outer == Self && aTemps.Find(oValue) < 0)
    {
        aTemps.AddItem(oValue);
    }
    return oValue;
}
