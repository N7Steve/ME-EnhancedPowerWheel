public final function int EPWPrimerMask(Name PowerName)
{
    // Biotic=1, Cryo=2, Electric=4, Fire=8. These are potential
    // primers; lift, freeze, ammo and evolution requirements still apply.
    switch (PowerName)
    {
        case 'Barrier':
        case 'DarkChannel':
        case 'Lash':
        case 'LiftGrenade':
        case 'Pull':
        case 'Reave':
        case 'Shockwave':
        case 'Singularity':
        case 'Slam':
        case 'Stasis':
        case 'Warp':
            return 1;
        case 'CryoAmmo':
        case 'CryoBlast':
            return 2;
        case 'DisruptorAmmo':
        case 'EnergyDrain':
        case 'Overload':
        case 'Sabotage':
            return 4;
        case 'Carnage':
        case 'IncendiaryAmmo':
        case 'Incinerate':
        case 'InfernoGrenade':
            return 8;
        case 'ConcussiveShot':
        case 'SentryTurret':
            return 10; // Cryo or Fire with the required evolution/ammo.
        case 'StickyGrenade':
            return 14; // Ammo-dependent Cryo, Electric or Fire.
    }
    return 0;
}
