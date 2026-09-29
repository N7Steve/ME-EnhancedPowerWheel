public final function SelectCurrentWheelItem(SFXPowerWheelMode eMode)
{
    if (eMode == SFXPowerWheelMode.PWM_Weapons)
    {
        SelectCurrentWeapon();
    }
    else if (eMode == SFXPowerWheelMode.PWM_Powers)
    {
        // This also guards the PC movie's mouse-up selection path.
        if (m_aPowerIcons.Length > 5 && !m_aPowerIcons[5].bVisible)
        {
            return;
        }
        SelectCurrentPower();
    }
}
