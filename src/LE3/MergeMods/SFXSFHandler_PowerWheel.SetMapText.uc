public event function SetMapText(string sText1, SFXPowerWheelMapButtonIcon eIcon1, optional string sText2 = "", optional SFXPowerWheelMapButtonIcon eIcon2 = 0, optional string sText3 = "", optional SFXPowerWheelMapButtonIcon eIcon3 = 0)
{
    local array<GFxValue> aEPWTemps;
    local GFxValue oWheel;
    local array<string> aTexts;
    local array<SFXPowerWheelMapButtonIcon> aIcons;
    local string sTexture;
    local int nRow;
    local int nSide;
    if (!m_bShowUseMapText)
    {
        EPWReleaseTemps(aEPWTemps); return;
    }
    oPanel.SetTextFieldText(m_sMapText1Path, sText1);
    oPanel.SetClipVisibility(m_sMapButton1Path, sText1 != "");
    oPanel.SetTextFieldText(m_sMapText2Path, sText2);
    oPanel.SetClipVisibility(m_sMapButton2Path, sText2 != "");
    oPanel.SetTextFieldText(m_sMapText3Path, sText3);
    oPanel.SetClipVisibility(m_sMapButton3Path, sText3 != "");
    oWheel = EPWTempValue(GetVariableObject(m_sWheelInnerPath), aEPWTemps);
    if (oWheel != None)
    {
        oWheel.SetString("EPWDiagInput0", "EPW16 INPUT0 raw={" $ sText3 $ "} enum=" $ string(eIcon3));
        oWheel.SetString("EPWDiagInput1", "EPW16 INPUT1 raw={" $ sText2 $ "} enum=" $ string(eIcon2));
        oWheel.SetString("EPWDiagInput2", "EPW16 INPUT2 raw={" $ sText1 $ "} enum=" $ string(eIcon1));
        aTexts.AddItem(sText3);
        aTexts.AddItem(sText2);
        aTexts.AddItem(sText1);
        aIcons.AddItem(eIcon3);
        aIcons.AddItem(eIcon2);
        aIcons.AddItem(eIcon1);
        // htmlText reads on native fields lose image markup at runtime. Keep
        // the native destination enum at the write boundary instead.
        for (nRow = 0; nRow < aTexts.Length; ++nRow)
        {
            sTexture = "";
            nSide = 0;
            if (aTexts[nRow] != "")
            {
                switch (aIcons[nRow])
                {
                    case SFXPowerWheelMapButtonIcon.PWBI_FaceButtonTop:
                        sTexture = "YBtn";
                        break;
                    case SFXPowerWheelMapButtonIcon.PWBI_ShoulderLeft:
                        nSide = 1;
                        break;
                    case SFXPowerWheelMapButtonIcon.PWBI_ShoulderRight:
                        nSide = 2;
                        break;
                    case SFXPowerWheelMapButtonIcon.PWBI_TriggerLeft:
                        sTexture = "LTrigger";
                        break;
                    case SFXPowerWheelMapButtonIcon.PWBI_TriggerRight:
                        sTexture = "RTrigger";
                        break;
                    case SFXPowerWheelMapButtonIcon.PWBI_DPadLeft:
                        sTexture = "DpadLeft";
                        break;
                    case SFXPowerWheelMapButtonIcon.PWBI_DPadRight:
                        sTexture = "DpadRight";
                        break;
                }
                if (nSide != 0)
                {
                    if (IsTriggerSouthpaw()) { nSide = 3 - nSide; }
                    if (IsTriggerShoulderSwapped())
                    {
                        sTexture = nSide == 1 ? "LTrigger" : "RTrigger";
                    }
                    else
                    {
                        sTexture = nSide == 1 ? "LBumper" : "RBumper";
                    }
                }
            }
            oWheel.SetString("EPWMapTexture" $ string(nRow), sTexture);
        }
    }
    EPWReleaseTemps(aEPWTemps);
}
