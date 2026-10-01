// Keep the 1.9.16 memory trace available while verifying the metadata fix.
public final function EPWTraceHelp()
{
    local GFxValue oWheel;
    local GFxValue oSource;
    local GFxValue oProxy;
    local GFxValue oTarget;
    local ASDisplayInfo oDisplay;
    local ASValue vHTML;
    local array<string> aPaths;
    local string sHTML;
    local string sDirectHTML;
    local string sTexture;
    local string sRecord;
    local float fNow;
    local int nRow;

    if (!m_bVisible || m_ePowerWheelMode != SFXPowerWheelMode.PWM_Powers || m_pPlayerController == None || m_pPlayerController.WorldInfo == None)
    {
        return;
    }
    oWheel = GetVariableObject(m_sWheelInnerPath);
    if (oWheel == None) { return; }
    fNow = m_pPlayerController.WorldInfo.RealTimeSeconds;
    if (fNow < oWheel.GetNumber("EPWDiagNext")) { return; }
    oWheel.SetNumber("EPWDiagNext", fNow + 1.0);
    aPaths.AddItem(m_sMapText3Path);
    aPaths.AddItem(m_sMapText2Path);
    aPaths.AddItem(m_sMapText1Path);
    aPaths.AddItem(m_sUseTextPath);
    for (nRow = 0; nRow < aPaths.Length; ++nRow)
    {
        oSource = GetVariableObject(aPaths[nRow]);
        oProxy = oWheel.GetObject("EPWHelpText" $ string(nRow));
        oTarget = oWheel.GetObject("EPWMapTarget" $ string(nRow));
        sRecord = "EPW16 ROW" $ string(nRow) $ " t=" $ string(fNow) $ " hover=" $ string(m_nCurrentPowerIconIndex) $ " path=" $ aPaths[nRow];
        if (oSource != None)
        {
            sHTML = oSource.GetString("htmlText");
            sDirectHTML = GetVariableString(aPaths[nRow] $ ".htmlText");
            vHTML = oSource.Get("htmlText");
            oDisplay = oSource.GetDisplayInfo();
            sRecord $= " | native.text={" $ oSource.GetText() $ "} member.html={" $ sHTML $ "} direct.html={" $ sDirectHTML $ "} get.type=" $ string(vHTML.Type) $ " get.S={" $ vHTML.S $ "} native.visible=" $ string(oDisplay.visible) $ " native.color=" $ string(oSource.GetNumber("textColor"));
        }
        else { sRecord $= " | native=NONE"; }
        if (oProxy != None)
        {
            sTexture = oProxy.GetString("EPWHelpTexture");
            oDisplay = oProxy.GetDisplayInfo();
            sRecord $= " | proxy.source={" $ oProxy.GetString("EPWHelpSourceProcessed") $ "} proxy.html={" $ oProxy.GetString("htmlText") $ "} texture={" $ sTexture $ "} proxy.visible=" $ string(oDisplay.visible) $ " proxy.alpha=" $ string(oDisplay.Alpha) $ " proxy.color=" $ string(oProxy.GetNumber("textColor")) $ " proxy.textWidth=" $ string(oProxy.GetNumber("textWidth"));
        }
        else { sRecord $= " | proxy=NONE"; }
        if (oTarget != None)
        {
            oDisplay = oTarget.GetDisplayInfo();
            sRecord $= " | target.texture={" $ oTarget.GetString("EPWTexture") $ "} target.html={" $ oTarget.GetString("htmlText") $ "} target.visible=" $ string(oDisplay.visible) $ " target.alpha=" $ string(oDisplay.Alpha) $ " target.x=" $ string(oDisplay.X) $ " target.y=" $ string(oDisplay.Y);
        }
        else { sRecord $= " | target=NONE"; }
        // Persist one bounded latest record per row for read-only memory capture.
        // LogInternal is also available if the owner has a working log sink.
        oWheel.SetString("EPWDiagRow" $ string(nRow), sRecord);
        LogInternal(sRecord, 'EPW16');
    }
}
