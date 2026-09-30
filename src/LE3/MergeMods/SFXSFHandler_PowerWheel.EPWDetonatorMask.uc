public final function int EPWDetonatorMask(SFXPowerCustomActionBase Power)
{
    local SFXPowerCustomAction Action;
    local int Mask;
    local int Index;
    local Name ComboName;

    // Read the loaded instance: evolutions and companion variants may alter it.
    Action = SFXPowerCustomAction(Power);
    if (Action == None)
    {
        return 0;
    }
    for (Index = 0; Index < Action.ComboDetonators.Length; ++Index)
    {
        ComboName = Action.ComboDetonators[Index].Name;
        switch (ComboName)
        {
            case 'SFXGameEffect_PowerCombo_Biotic':
                Mask = Mask | 1;
                break;
            case 'SFXGameEffect_PowerCombo_Cryo':
                Mask = Mask | 2;
                break;
            case 'SFXGameEffect_PowerCombo_Electric':
                Mask = Mask | 4;
                break;
            case 'SFXGameEffect_PowerCombo_Fire':
                Mask = Mask | 8;
                break;
        }
    }
    return Mask;
}
