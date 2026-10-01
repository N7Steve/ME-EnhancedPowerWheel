public function SelectCurrentWheelItem(SFXPowerWheelMode EMode)
{
    if (EMode == SFXPowerWheelMode.PWM_Weapons)
    {
        SelectCurrentWeapon();
    }
    else if (EMode == SFXPowerWheelMode.PWM_Powers)
    {
        if (m_nCurrentPowerIconIndex < 0 || m_nCurrentPowerIconIndex >= m_aPowerIcons.Length || !m_aPowerIcons[m_nCurrentPowerIconIndex].bVisible || m_aPowerIcons[m_nCurrentPowerIconIndex].pPower == None)
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
