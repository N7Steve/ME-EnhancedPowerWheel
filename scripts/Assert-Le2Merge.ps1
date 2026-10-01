function Assert-Le2Merge {
    param([string]$Artifact, [string]$SourceManifest)
    $reader = [IO.BinaryReader]::new([IO.File]::OpenRead($Artifact))
    try {
        if ([Text.Encoding]::ASCII.GetString($reader.ReadBytes(4)) -ne 'M3MM' -or $reader.ReadByte() -ne 1) { throw 'Expected M3M v1.' }
        $length = $reader.ReadInt32()
        if ($length -ge 0 -or (-2L * $length) -gt ($reader.BaseStream.Length - 9)) { throw 'Invalid merge manifest length.' }
        $embedded = [Text.Encoding]::Unicode.GetString($reader.ReadBytes(-2 * $length)).TrimEnd([char]0) | ConvertFrom-Json
        $authored = Get-Content -Raw -LiteralPath $SourceManifest | ConvertFrom-Json
        if ($embedded.game -ne 'LE2' -or $embedded.files.Count -ne 1 -or $embedded.files[0].filename -ne 'SFXGame.pcc') { throw 'Unexpected merge targets.' }
        if ($embedded.files[0].changes.Count -ne $authored.files[0].changes.Count) { throw 'Merge change count mismatch.' }
        for ($i = 0; $i -lt $authored.files[0].changes.Count; $i++) {
            $change = $authored.files[0].changes[$i]
            $actual = $embedded.files[0].changes[$i]
            if ($actual.entryname -cne $change.entryname) { throw 'Merge operation mismatch.' }
            if ($change.scriptupdate) {
                $expected = [IO.File]::ReadAllText((Join-Path (Split-Path $SourceManifest -Parent) $change.scriptupdate.scriptfilename))
                if ($actual.scriptupdate.scripttext -cne $expected) { throw "Embedded script differs: $($change.entryname)" }
            } elseif ($change.addtoclassorreplace) {
                if ($change.entryname -cne 'SFXSFHandler_PowerWheel') { throw 'Unexpected LE2 class target.' }
                $expectedScripts = @($change.addtoclassorreplace.scriptfilenames)
                $actualScripts = @($actual.addtoclassorreplace.scripts)
                if ($actualScripts.Count -ne $expectedScripts.Count) { throw 'Added member count mismatch.' }
                for ($j = 0; $j -lt $expectedScripts.Count; $j++) {
                    $expected = [IO.File]::ReadAllText((Join-Path (Split-Path $SourceManifest -Parent) $expectedScripts[$j]))
                    if ($actualScripts[$j] -cne $expected) { throw "Embedded member differs: $($expectedScripts[$j])" }
                }
            } else { throw 'Unsupported LE2 merge operation.' }
        }
    } finally { $reader.Dispose() }
}
