# Live wheel memory and tooltip diagnostics, 2026-10-01

## Confirmed observations

The owner reports that 1.9.15 shows dark/inverted-looking text and no destination icons, and authorized memory inspection or instrumentation with the wheel open. Read-only installed-package inspection confirms the 1.9.15 renderer. Installed `SFXGame.pcc` SHA256 is `685DD67FFAEA12DB4A65981135F63CE4CC60175709FB9788EAA35302CB2FF243`.

`scripts/Read-Le3WheelMemory.ps1` opened PID 61528 (`MassEffect3.exe`) using only `PROCESS_VM_READ | PROCESS_QUERY_INFORMATION`. It scanned approximately 5.26 GB of committed private/mapped memory in about five seconds, finding 61 wheel-scoped strings, with zero read failures. It did not write to, inject into, pause or dump the process. The capture is ignored local research at `research/local/LE3/LiveWheelMemory/wheel-memory-20261001-131337.json`. Subsequent refinement limits context to the surrounding terminated string rather than adjacent heap bytes. Syntax and embedded C# compilation pass; that refinement could not be rescanned because the game process had exited.

Three nearby UTF-8 allocations contain the same constructed renderer string:

```html
<font face="AeroLight Shared" size="18">Map power to  </font>
```

The capture also contains UTF-16 native mapping strings with Y, LB and RB image tags, for example:

```html
Map power to <img src='img://BIOA_ControllerIcons_XBOX.xbox_RB' fontvscale='140' vspace='3' valign='bottom' />
```

Thus the proxy strings have no explicit text color and no image. Native image-bearing strings still exist in the process. A string scan cannot assign each allocation to a particular live GFx object or establish whether it is current or retained history; it does not prove which getter/path loses the image. No diagnosis of the native adapter's implementation is claimed.

## Source-based inference and pending hypotheses

The proxy markup omits `color="#79c9fd"`, whereas Reorder/Switch specify it. A newly created TextField's default color is therefore a plausible cause of the reported dark text. The output strings are consistent with the source getter returning text without markup; another possibility is that the source fields already lost their images or that the read occurred at a different stage. The failure should be traced before selecting a fix. Repeated source/processed HTML comparisons were already removed in 1.9.15, but that change did not restore icons.

## Diagnostic build 1.9.16

Preserve the 1.9.15 renderer unchanged. Add final/nonvirtual `EPWTraceHelp`, called after help layout from the existing `Update` override. While the power wheel is visible it samples at most once per second, recording four rows:

- Native `GetText()`, `GetString("htmlText")`, direct `GetVariableString(path + ".htmlText")`, and `Get("htmlText")` type/string.
- Proxy cached source, HTML, chosen texture, visibility, alpha, text color and width.
- Target existence, cached texture, HTML, visibility, alpha and coordinates.
- Hover index, real-time timestamp and native field path.

`SetMapText` also retains the latest raw incoming string and native mapping enum for each mapping row, without changing its native text/visibility writes. Each full `EPW16 ROW…` or `EPW16 INPUT…` record is retained in a wheel property for read-only memory capture. `LogInternal` receives full row records; the existing installed ASI directory contains only AutoTOC, and no usable UnrealScript log file was found, so a file sink is not assumed. `SFXGUIInteraction.AddLogEntry` shows short yellow diagnostic summaries in game, following the locally inspected existing DTW diagnostic pattern. No logger installation or change to Dynamic Time Wheels is made.

The memory reader searches the additional `EPW16 ROW` and `EPW16 INPUT` prefixes and captures up to 8192 bytes of each terminated diagnostic string. Data stays in ignored research output. The trace's rate limit remains in effect even if native `SetMapText` writes repeat.

## Validation, export and owner procedure

All 16 manifest functions compile against installed LE3. Base/PC virtual inheritance passes (110/110); all nine EPW helpers remain final/nonvirtual; only explicitly listed class exports change. `git diff --check` passes. Installed SFXGame hash is unchanged after inspection/build/export. No game installation or process mutation performed.

Reproduce with `scripts/Build-Le3.ps1` and `scripts/Export-Le3Folder.ps1`. Export: `dist/EnhancedPowerWheel-LE3-TooltipDiagnostics-v1.9.16-BC1B6158730D/`. M3M SHA256: `BC1B6158730D047487961C1105568D5255F912B62BB54B7A66E8073537E8156F`.

Owner installation merges only `Game/ME3/BioGame/CookedPCConsole/SFXGame.pcc`. Use Mod Manager's managed basegame backup and record installed mods first. Uninstall by restoring the backup and reapplying desired mods; see [toolchain research](toolchain.md). This build diagnoses the current failure; it does not claim to fix it.

After owner installation/restart, hover an occupied player power for at least five seconds, then hover a different power for five seconds and leave the wheel open. Run `scripts/Read-Le3WheelMemory.ps1` again. Compare raw inputs, all three HTML reads and selected texture across records to identify the first point at which image markup disappears. Only then change the renderer. In-game execution of the trace has not yet been verified.
