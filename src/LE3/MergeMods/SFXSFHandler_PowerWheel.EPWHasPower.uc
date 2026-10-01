public final function bool EPWHasPower(SFXGUIValue_PowerIcon oIcon)
{
    if (oIcon == None || oIcon.eState == SFXPowerWheelPowerState.PWPS_EmptySelectable || oIcon.eState == SFXPowerWheelPowerState.PWPS_EmptySelected)
    {
        return FALSE;
    }
    // Native squad presentation can identify an order by pawn/name.
    return oIcon.pPower != None || (oIcon.bHenchIcon && oIcon.pPawn != None && oIcon.nmPowerName != 'None');
}
