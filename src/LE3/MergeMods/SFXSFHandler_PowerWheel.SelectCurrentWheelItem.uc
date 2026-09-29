public final function SelectCurrentWheelItem(SFXPowerWheelMode eMode)
{
    if (eMode == SFXPowerWheelMode.PWM_Weapons)
    {
        SelectCurrentWeapon();
    }
    else if (eMode == SFXPowerWheelMode.PWM_Powers)
    {
        // Empty slots cannot activate, including through the PC mouse-up path.
        if (m_nCurrentPowerIconIndex < 0 || m_nCurrentPowerIconIndex >= m_aPowerIcons.Length)
        {
            return;
        }
        if (m_aPowerIcons[m_nCurrentPowerIconIndex].eState == SFXPowerWheelPowerState.PWPS_EmptySelectable || m_aPowerIcons[m_nCurrentPowerIconIndex].eState == SFXPowerWheelPowerState.PWPS_EmptySelected)
        {
            return;
        }
        SelectCurrentPower();
    }
}
