// Change this default to TRUE to restore vanilla NotSuggested presentation.
// A future installer can supply the same option without changing gameplay logic.
public final function EPWUpdateSuggestedDisplay(optional bool bShowNotSuggested = FALSE)
{
    local SFXGUIValue_PowerIcon oIcon;
    local GFxValue oNotSuggested;
    local GFxValue oProxy;
    local GFxValue oLoader;
    local array<ASValue> aArgs;
    local string sProxy;
    local string sPreviousProxy;
    local int nVisualState;
    local int nIcon;

    for (nIcon = 0; nIcon < m_aPowerIcons.Length; ++nIcon)
    {
        oIcon = m_aPowerIcons[nIcon];
        oIcon.SetNumber("EPWVisualState", float(oIcon.eState));
        oIcon.SetNumber("EPWVisualDesiredState", float(oIcon.eDesiredState));
        oNotSuggested = GetVariableObject(oIcon.sPath $ ".powerIconMC.sub.notSuggested");
        if (oNotSuggested == None)
        {
            continue;
        }
        sPreviousProxy = oNotSuggested.GetString("EPWProxyPath");
        if (!bShowNotSuggested && oIcon.bVisible && oIcon.pPower != None && (oIcon.eState == SFXPowerWheelPowerState.PWPS_NotSuggested || ((oIcon.eState == SFXPowerWheelPowerState.PWPS_Selectable || oIcon.eState == SFXPowerWheelPowerState.PWPS_Selected) && oIcon.eDesiredState == SFXPowerWheelPowerState.PWPS_NotSuggested)))
        {
            nVisualState = oIcon.bSelected ? int(SFXPowerWheelPowerState.PWPS_Selected) : int(SFXPowerWheelPowerState.PWPS_Selectable);
            sProxy = oIcon.sPath $ ".powerIconMC.sub." $ oIcon.m_aPowerStatePaths[nVisualState];
            oProxy = GetVariableObject(sProxy);
            if (oProxy == None)
            {
                continue;
            }
            if (sPreviousProxy != "" && sPreviousProxy != sProxy)
            {
                oProxy = GetVariableObject(sPreviousProxy);
                if (oProxy != None) { oProxy.SetVisible(FALSE); }
                oProxy = GetVariableObject(sProxy);
            }
            if (sPreviousProxy != sProxy)
            {
                // Initialize the substitute state's loader even when native hover
                // populated only the warning clip. SetIcon is authored in the SWF.
                oLoader = oProxy.GetObject("iconMC");
                if (oLoader != None)
                {
                    aArgs.Length = 2;
                    aArgs[0].Type = ASType.AS_String;
                    aArgs[0].S = oIcon.sIconResource;
                    aArgs[1].Type = ASType.AS_Number;
                    aArgs[1].N = oIcon.nIcon;
                    oLoader.Invoke("SetIcon", aArgs);
                }
            }
            oNotSuggested.SetVisible(FALSE);
            oProxy.SetVisible(TRUE);
            oNotSuggested.SetString("EPWProxyPath", sProxy);
            oIcon.SetNumber("EPWVisualState", float(nVisualState));
            if (oIcon.eDesiredState == SFXPowerWheelPowerState.PWPS_NotSuggested)
            {
                oIcon.SetNumber("EPWVisualDesiredState", float(nVisualState));
            }
        }
        else if (sPreviousProxy != "")
        {
            oProxy = GetVariableObject(sPreviousProxy);
            // Do not hide a substitute that has become the real current state.
            sProxy = oIcon.sPath $ ".powerIconMC.sub." $ oIcon.m_aPowerStatePaths[int(oIcon.eState)];
            if (oProxy != None && sPreviousProxy != sProxy) { oProxy.SetVisible(FALSE); }
            oNotSuggested.SetString("EPWProxyPath", "");
            oIcon.SetStateDisplay();
            if (oIcon.bVisible && oIcon.pPower != None)
            {
                oProxy = GetVariableObject(sProxy);
                if (oProxy != None) { oProxy.SetVisible(TRUE); }
            }
        }
    }
}
