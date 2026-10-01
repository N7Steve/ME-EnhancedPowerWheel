// Change the default to TRUE to restore the native red warning artwork.
// Only Flash presentation changes; native evaluation/activation stays intact.
public final function EPWUpdateSuggestedDisplay(optional bool bShowNotSuggested = FALSE)
{
    local int nIcon;
    local int nState;
    local int nVisualState;
    local string sPath;

    for (nIcon = 0; nIcon < m_aPowerIcons.Length; ++nIcon)
    {
        // Native state/hover updates can re-show this clip after our visibility
        // write. Its own alpha survives those writes and parent hover fades.
        oPanel.SetVariableFloat(m_aPowerIcons[nIcon].sPath $ ".powerIconMC.sub.notSuggested._alpha", bShowNotSuggested ? 100.0 : 0.0);
        if (!m_aPowerIcons[nIcon].bVisible) { continue; }
        nVisualState = int(m_aPowerIcons[nIcon].eState);
        if (m_aPowerIcons[nIcon].pPower != None && (nVisualState == int(SFXPowerWheelPowerState.PWPS_Selectable) || nVisualState == int(SFXPowerWheelPowerState.PWPS_Selected) || (!bShowNotSuggested && nVisualState == int(SFXPowerWheelPowerState.PWPS_NotSuggested))))
        {
            nVisualState = m_aPowerIcons[nIcon].bSelected ? int(SFXPowerWheelPowerState.PWPS_Selected) : int(SFXPowerWheelPowerState.PWPS_Selectable);
        }
        // Native selection can retain its cached state across a slot rebuild.
        // Reassert the authored selected artwork even with a stationary stick.
        for (nState = 0; nState < 8; ++nState)
        {
            sPath = m_aPowerIcons[nIcon].sPath $ ".powerIconMC.sub." $ m_aPowerStatePaths[nState];
            if (nState == nVisualState && m_aPowerIcons[nIcon].pPower != None)
            {
                oPanel.GotoFrameAndStop(sPath $ ".iconMC", m_aPowerIcons[nIcon].nIcon);
            }
            oPanel.SetClipVisibility(sPath, nState == nVisualState);
        }
    }
}
