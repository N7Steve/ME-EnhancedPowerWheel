// Use the installed manager's eligibility rules, before the native eight-icon limit.
public final function EPWPlayerPowers(out array<SFXPowerCustomActionBase> aPowers)
{
    local array<SFXPowerCustomActionBase> aAvailable;
    local int nPower;
    local int nOther;
    local bool bDuplicate;

    aPowers.Length = 0;
    if (m_pShepardPawn == None || m_pShepardPawn.PowerManager == None)
    {
        return;
    }
    m_pShepardPawn.PowerManager.GetPowerWheelPowers(aAvailable);
    for (nPower = 0; nPower < aAvailable.Length; ++nPower)
    {
        bDuplicate = FALSE;
        for (nOther = 0; nOther < aPowers.Length; ++nOther)
        {
            if (aPowers[nOther].PowerName == aAvailable[nPower].PowerName)
            {
                bDuplicate = TRUE;
                break;
            }
        }
        if (!bDuplicate && aPowers.Length < 16)
        {
            aPowers.AddItem(aAvailable[nPower]);
        }
    }
}
