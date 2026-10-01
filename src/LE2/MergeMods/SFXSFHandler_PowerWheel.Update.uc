public event function Update(float fDeltaT)
{
    local int nPhase;
    local int nIcon;
    local float fAlpha;

    Super.Update(fDeltaT);
    // Teardown never touches Flash: CleanupReferences remains exactly vanilla.
    if (oPanel == None || !oPanel.bInitialized || oPanel.bToBeRemoved || m_pPlayerController == None || m_ePowerWheelMode != SFXPowerWheelMode.PWM_Powers)
    {
        return;
    }
    if (!oPanel.GetVariableBool("EPWLE2Open"))
    {
        return;
    }
    nPhase = oPanel.GetVariableInt("EPWLE2FadePhase");
    if (nPhase != 0)
    {
        fAlpha = oPanel.GetVariableFloat("EPWLE2FadeAlpha");
        if (nPhase == 1)
        {
            fAlpha = FMax(0.0, fAlpha - FMax(0.0, fDeltaT) * 600.0);
            if (fAlpha <= 0.0)
            {
                oPanel.SetVariableInt("EPWLE2Page", oPanel.GetVariableInt("EPWLE2FadeTarget"));
                HandleInputEvent(BioGuiEvents.BIOGUI_EVENT_BUTTON_LTHUMB, -1.0);
                oPanel.SetVariableInt("EPWLE2FadePhase", 2);
            }
        }
        else
        {
            fAlpha = FMin(100.0, fAlpha + FMax(0.0, fDeltaT) * 600.0);
            if (fAlpha >= 100.0)
            {
                oPanel.SetVariableInt("EPWLE2FadePhase", 0);
            }
        }
        oPanel.SetVariableFloat("EPWLE2FadeAlpha", fAlpha);
        // Keep portraits, vignette and ring outside the transition.
        for (nIcon = 0; nIcon < m_aPowerIcons.Length; ++nIcon)
        {
            oPanel.SetVariableFloat(m_aPowerIcons[nIcon].sPath $ "._alpha", fAlpha);
            oPanel.SetVariableFloat(m_aPowerIcons[nIcon].oMappedIcon.sPath $ "._alpha", fAlpha);
            oPanel.SetVariableFloat("mainContent." $ m_aPowerIcons[nIcon].sMappedBGPath $ "._alpha", fAlpha);
        }
    }
    EPWUpdateUI(TRUE);
}
