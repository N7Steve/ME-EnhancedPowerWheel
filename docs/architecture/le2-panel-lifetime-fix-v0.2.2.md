# LE2 panel lifetime correction 0.2.2

## Confirmed evidence

The owner reports that 0.2.1 still crashes at “Press any key to continue”, after restoring the game before installing that candidate. They restored again after the crash. Removing native class recompilation did not resolve the failure; that previous hypothesis was insufficient.

Windows Application Error reports from 2026-10-01 at 01:04:24 and 01:15:52 both identify `MassEffect2.exe`, exception `c0000005`, and fault offset `0x1a73e7`. The available WER archives retain reports but no crash dump or stack. The installed executable SHA256 is `71976F300EA7159CA22574D2904355BEDFAFA8DB9C56029B55D3C9801AC2D8CF`, matching the previously captured local executable sections used for static inspection.

The fault is inside native function RVA `0x1a7310–0x1a746a`. It converts two Unreal strings to UTF-8 and sets up a Flash string value. At `0x1a7345` it reads a movie pointer from the panel object at offset `0x68`; at the reported fault, `0x1a73e7`, it dereferences that pointer for a virtual call at vtable offset `0x80`. The Unreal VM wrapper at `0x4b7660–0x4b775d` parses two string arguments and calls this routine. Another wrapper appends text to the path first, consistent with `SetTextFieldText` sharing the same string setter. The routine's behavior identifies it as a Flash string setter; its exact registration and crash caller are not established by a full stack.

Local vanilla package inspection confirms that `SFXSFHandler_PowerWheel.OnPanelRemoved` and `GameSessionEnded` call `CleanupReferences` before the superclass clears `oPanel`. Vanilla `CleanupReferences` only clears Unreal object references. Versions 0.2 and 0.2.1 added `oPanel.SetVariableString` calls there, guarded only by `oPanel != None`.

## Source-based inference and minimal correction

A non-null Unreal panel reference does not establish that its native Flash movie still exists during removal. The added cleanup writes match both the faulting native operation and the pre-menu transition timing. This is the leading explanation; without a crash stack or successful owner retest it remains an inference.

0.2.2 removes all panel access from `CleanupReferences` and restores the vanilla body. The replacement remains in the manifest so a merge also replaces the defective body from 0.2.1. All other wheel function sources remain identical to 0.2.1. There are no added class members, no class recompilation, no native hook, no save writes and no quickslot changes.

The layout lives in Flash variables. Panel destruction discards it; a session transition that reuses the same panel has not been tested and is no longer claimed to reset it explicitly. R3 pagination and LT move/swap still require gameplay verification after startup succeeds.

## Validation and reproducible artifact

All five existing-function replacements compile and round-trip against the registered vanilla LE2 backup. Every original class export keeps its data hash. The compiled/decompiled cleanup body matches vanilla after whitespace normalization and contains no panel access. The other four function sources are byte-identical to the archived 0.2.1 sources. The M3M contents are checked against the source manifest and embedded scripts.

Export: `dist/EnhancedPowerWheel-LE2-PanelLifetimeFix-v0.2.2-D7D02E9E0888`.

M3M SHA256: `D7D02E9E08887A65B8A64BCA6E5E64B18D7F59E65392E8D13645E8298408000B`.

Build and export do not install. The installed `SFXGame.pcc` remains the restored vanilla package, SHA256 `681F3FC72C08C66BC6D77CA91102E08CEAD7C6A5586C22BAD0A8F7085BE38D77`.

## Owner installation and removal

The owner has already restored after 0.2.1. Import the new folder into Mod Manager and install 0.2.2 with LE2 closed, keeping the registered vanilla backup at `Y:/Mass Effect/Backups/LE2` and a record of other installed mods. The only game file changed is `Game/ME2/BioGame/CookedPCConsole/SFXGame.pcc`; the merge replaces the five functions listed in the exported `INSTALL.txt`. If either failing candidate is still installed on a different setup, restore basegame and reapply desired mods before testing.

First verify that startup passes “Press any key to continue” and reaches the main menu. Only then load a test save and test the pages, placeholders, LT moves/swaps and A activation. The owner subsequently confirmed that 0.2.2 works, reporting only stale First Aid charge text after moving powers. See the 0.2.3 counter correction. Uninstall by restoring the verified LE2 basegame backup through Mod Manager, then reapplying wanted basegame mods.
