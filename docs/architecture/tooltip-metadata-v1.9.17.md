# Native tooltip destination metadata, version 1.9.17

## Confirmed live diagnosis

The owner installed 1.9.16 and left the wheel open for read-only inspection. PID 58280 yielded 177 scoped memory strings, approximately 5.17 GB read, zero read failures and no process mutations. Local capture: `research/local/LE3/LiveWheelMemory/wheel-memory-20261001-132302.json` (ignored).

Full `EPW16` records identify live native/proxy values, unlike the earlier unlabelled string scan. Steady-state records at real-time seconds 27–29 report:

- Native mapping text and all three HTML reads (`GetString("htmlText")`, `GetVariableString(path + ".htmlText")`, and `Get("htmlText").S`) equal `Map power to  `, with no IMG markup. `Get("htmlText")` returns `AS_String`.
- Raw `SetMapText` inputs retain `[XBoxB_Btn_Y]`, `[XBoxB_Btn_RB]`, `[XBoxB_Btn_LB]` and matching enums `PWBI_FaceButtonTop`, `PWBI_ShoulderRight`, `PWBI_ShoulderLeft`.
- The mapping proxy has `texture={}` and `target=NONE`: the IMG-dependent branch cannot choose/create a destination.
- Use and mapping proxies serialize `COLOR="#000000"`, with `proxy.color=0`; native fields report `native.color=7981565`, which is `0x79C9FD`.
- Proxies are visible with alpha 100, so their dark color is not explained by the page fade.

These observations confirm the failure of recovering destination metadata from native TextField HTML in this runtime, and the explicit color omission in newly created proxies. They do not establish the underlying native/Scaleform implementation detail that returns plain text, nor independently trace 1.9.13/14's first-frame flicker.

## Fix

`SetMapText` preserves native writes/visibility and records a destination texture per help row from its enum while the raw arguments are available. Empty native rows clear their destination. Y and squad D-pad targets map directly; logical shoulder targets follow the existing handler's Southpaw/ShoulderSwapped helpers to select physical bumper/trigger artwork. This uses the same controller-side conversion as the existing mapping badge helper; alternate controller settings remain an owner visual check.

`EPWUpdateSwitchHint` reads localized plain text with `GetText`, trims trailing spaces left by native image removal, escapes HTML special characters and renders it with explicit AeroLight Shared, size 18 and color `#79c9fd`, matching Reorder/Switch. It no longer parses IMG tags or normalizes serialized HTML. Destination metadata is read independently of changes to label text, so different mapping targets can update even when localized labels are identical.

Existing 32-pixel target fields, positions, row interval, contextual ordering labels and native restoration are retained. No quickslot assignments, pagination, opening override, inherited `Super.Update`, fades or persistence code change.

The once-per-second memory trace remains for verification, using the same `EPW16` record prefix and reader. Its yellow on-screen summaries are removed so the resulting help can be assessed clearly. Raw input and full row records remain available in memory and through `LogInternal`. This is temporary verification instrumentation, pending owner confirmation.

## Validation and export

All 16 manifest functions compile against the installed diagnostic LE3 package. Base/PC virtual inheritance passes (110/110); all nine EPW helpers remain final/nonvirtual; only explicitly listed class exports change. `git diff --check` passes. Installed SFXGame SHA256 before and after capture, build and export is unchanged: `04C2282306702A2CB3996400DFB7E824063ECBDAB4F2F4A847DD9A77189270CB`. No installation or process mutation performed.

Reproduce using the pinned `scripts/Build-Le3.ps1` and `scripts/Export-Le3Folder.ps1` workflow. Export: `dist/EnhancedPowerWheel-LE3-TooltipMetadata-v1.9.17-1D3793039F35/`. M3M SHA256: `1D3793039F35A13D6B685B3B513C15509A3A789F7E73A6139F4FF2A4C9525C45`.

Owner installation merges only `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc`. Use Mod Manager's managed basegame backup and record installed mods first. Uninstall by restoring that backup and reapplying desired mods; see [toolchain research](../research/toolchain.md).

Pending owner checks: hover two different occupied powers, retaining each for 30 seconds; confirm blue text and persistent Y/LB/RB destination glyphs; check already-mapped exclusions, empty slots, squad targets, page switches, repeated close/reopen, both languages, Southpaw/ShoulderSwapped settings and weapon/PC restoration. If a visual failure remains, capture the retained memory trace to inspect chosen texture, target presence/visibility and proxy color. This fix is compiler-validated; its in-game result is not yet confirmed. Save/quit/reload remains separately unconfirmed.
