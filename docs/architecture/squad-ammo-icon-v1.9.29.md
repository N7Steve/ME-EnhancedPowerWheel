# Squad equipped-ammo image / proxy cache v1.9.29

## Observation and evidence

The owner reports squad ammo images still missing on opening after v1.9.24's
all-state loader initialization. Hover or moving reveals them. The owner suspects
ammo already equipped; this correlation is not independently established here.

Read-only scoped memory inspection of the running game finds complete prior
reconstruction records for Garrus ArmorPiercingAmmo (frame 58) and Liara WarpAmmo
(frame 54), both with state and desired state PWPS_NotSuggested and resource
GUI_SF_PowerIcons.PowerIcons. These are cached diagnostic records, not a live
render-tree measurement. EPW displays a normal-state proxy for this native state;
it should not be assumed these icons are PWPS_Activated merely because ammo is on.

The currently installed wheel SWF was extracted read-only and its SHA256 matches
the previously analyzed local wheel exactly:
`135AFADAE2AA1D653A56570F40CE5F7CAD4992F0E696A475BE8012C91499D538`.
Confirmed authored IconResourceLoader.SetIcon behavior: when resource is already
loaded, it rejects undefined requested frames OR an OLD m_nIcon <= 1 before
assigning the requested frame. Therefore calling SetIcon with a valid new frame
once cannot repair that cleared-index case. This is a confirmed source property,
not proof that the affected live loaders had that value. Captured records before
this fix lacked loader cache/visibility fields.

Confirmed current source: the NotSuggested proxy cache tracks only its clip path.
Squad reconstruction calls ClearIcon but did not invalidate that cached path.
The subsequent proxy helper can skip image initialization if the path is unchanged.
The prior all-state initialization also did not seed the old cached index before
SetIcon. This combination is a source-based explanation of the symptom. Native
ClearIcon internals and the exact failed render-tree state remain unverified.

## Minimal image repair

After squad ClearIcon, invalidate the transient NotSuggested EPWProxyPath cache,
so the active normal proxy is initialized again during the existing display pass.
For the six occupied state image loaders, seed m_nIcon from the reconstructed
icon before calling authored SetIcon. Do the same in the proxy initializer and
explicitly reveal that proxy's iconMC. Other state clips retain native visibility;
no native availability, cooldown, ammo effect, state or all-icon alpha is forced.
No frame-loop loader refresh or gameplay/quickslot changes are introduced.

The existing bounded EPWSquadImage record now appends each occupied state's OLD
cached index, loading and visibility flags before repair, once per reconstruction.
This will distinguish the cleared-index hypothesis if the owner reproduces again.
The diagnostic uses the existing read-only reader, stays local/ignored, and is
not an engine-memory write or injection. Transient GFx cache writes are ordinary
in-mod UI operations.

Previous combo fades, static empty slots, green move-hover outlines, opening P,
Super.Update/reveal, native squad availability refresh and saved ordering remain.
Existing LE2/README/squad local changes are preserved.

## Verification and artifact

All 18 manifest functions compile/decompile against installed LE3; output retains
proxy invalidation, index seeding before SetIcon, and proxy image visibility.
Inheritance passes 110/110, eleven helpers remain final/nonvirtual, and only
listed class exports change. git diff --check passes. Owner in-game confirmation
of the missing-image fix is pending; compilation cannot validate render timing.

Installed package hash changed during investigation, between the initial live
capture and subsequent package inspection. The agent performed no installation
or package writes. Build/export target SFXGame.pcc SHA256, unchanged across build
and export:
`2314C99A209A4C56AD25A95D2B4C045F5C6F95E73A025B013021D85755A0152B`.
Research is ignored under research/local/LE3/AmmoIcon-v1.9.29 and Validation.

Export: `dist/EnhancedPowerWheel-LE3-SquadAmmoIcon-v1.9.29-578FBBD9C366/`.
M3M SHA256:
`578FBBD9C366C6FD36A67FFC54C1869977835467D46C83E9EFDF2E39E233510C`.
Reproduce with scripts/Build-Le3.ps1 using installed LE3/pinned Mod Manager paths,
then scripts/Export-Le3Folder.ps1. No installation performed.

Check already equipped Armor Piercing Ammo and Warp Ammo on first opening before
moving the stick; repeat without ammo equipped, hover/leave, move, close/reopen and
R3 away/back. Check other squad ammo powers and the retained cooldown/availability
appearance, squad ordering, static holes and green moving outlines. If still
missing, capture the latest EPWSquadImage records using Read-Le3WheelMemory.ps1
while the wheel is open. Exact visibility/alpha at failure remains a runtime question.

Installation merges only Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc through
Mod Manager. Keep its managed LE3 basegame backup, record installed mods and a
pre-test save. Uninstall by restoring the backup and reapplying desired mods/the
previous checkpoint; restore the save copy to undo ordering. INSTALL.txt in the
export documents changed file, backup and uninstall instructions.
