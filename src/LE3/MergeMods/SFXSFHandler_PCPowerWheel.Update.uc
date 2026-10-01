public event function Update(float fDeltaT)
{
    Super.Update(fDeltaT);
    EPWPCTick();
    EPWPCPresentation();
}
