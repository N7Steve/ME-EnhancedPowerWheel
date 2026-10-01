// Hit-test the authored mouse zones in stage coordinates, including empty slots.
public final function int EPWPCDropTarget()
{
    local GFxValue oRoot;
    local GFxValue oZone;
    local array<ASValue> aArgs;
    local ASValue oHit;
    local int nIcon;

    oRoot = GetVariableObject("_root");
    if (oRoot == None) { return -1; }
    aArgs.Length = 3;
    aArgs[0].Type = ASType.AS_Number;
    aArgs[0].N = oRoot.GetNumber("_xmouse");
    aArgs[1].Type = ASType.AS_Number;
    aArgs[1].N = oRoot.GetNumber("_ymouse");
    aArgs[2].Type = ASType.AS_Boolean;
    aArgs[2].B = FALSE;
    for (nIcon = 0; nIcon < m_aPowerIcons.Length; ++nIcon)
    {
        // Match the SWF's own mouse callbacks: test clip visibility, not the
        // native bookkeeping flag left by a squad ClearIcon/reconstruction.
        if (!m_aPowerIcons[nIcon].GetBool("_visible")) { continue; }
        oZone = GetVariableObject(m_aPowerIcons[nIcon].sPath $ ".MouseZone");
        if (oZone == None) { continue; }
        oHit = oZone.Invoke("hitTest", aArgs);
        if (oHit.B) { return nIcon; }
    }
    return -1;
}
