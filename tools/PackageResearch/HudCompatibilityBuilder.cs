using System.Security.Cryptography;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Xml.Linq;
using LegendaryExplorerCore;
using LegendaryExplorerCore.Coalesced;
using LegendaryExplorerCore.Coalesced.Config;
using LegendaryExplorerCore.GameFilesystem;
using LegendaryExplorerCore.Packages;
using LegendaryExplorerCore.Packages.CloningImportingAndRelinking;
using LegendaryExplorerCore.Unreal;
using LegendaryExplorerCore.Unreal.BinaryConverters;
using LegendaryExplorerCore.UnrealScript;
using LegendaryExplorerCore.TLK;
using LegendaryExplorerCore.TLK.ME2ME3;

internal static class HudCompatibilityBuilder
{
    private const string Dlc = "DLC_MOD_EPWHUDCompat";
    private const string Startup = "Startup_MOD_EPWHUDCompat_INT.pcc";
    private const string ClassPath = "EPWHUDCompat.EPWHUDConsoleWheel";
    private const string PCClassPath = "EPWHUDCompat.EPWHUDPCWheel";
    private const int NameId = 10740200;

    // Generates only original compatibility content in a new output directory.
    // Dependencies are opened read-only and are never saved or copied into output.
    public static int Build(string hudRoot, string gamePath, string source, string output)
    {
        LegendaryExplorerCoreLib.InitLib(TaskScheduler.Default);
        output = Path.GetFullPath(output);
        if (Directory.Exists(output)) throw new InvalidOperationException("Output already exists; use a new directory.");
        var hudCooked = Path.Combine(Path.GetFullPath(hudRoot), "DLC_MOD_HUDEnhance", "CookedPCConsole");
        var hudPath = Path.Combine(hudCooked, "Startup_MOD_HUDEnhance_INT.pcc");
        using var hud = MEPackageHandler.OpenMEPackage(hudPath);
        using var game = MEPackageHandler.OpenMEPackage(Path.GetFullPath(gamePath));
        if (hud.Game != MEGame.LE3 || game.Game != MEGame.LE3) throw new InvalidOperationException("LE3 inputs required.");
        var inputHashes = new[] { hudPath, game.FilePath, Path.Combine(hudCooked, "Default_DLC_MOD_HUDEnhance.bin"), Path.Combine(hudCooked, "Mount.dlc") }.ToDictionary(p => p, Hash);
        var hudHash = "6F2F829EA51B9B6650F72101EAED2C1AAD344485E999B7DD792CA3A594C0323D";
        if (Hash(hudPath) != hudHash) throw new InvalidOperationException("This POC requires the inspected HUD Enhancements 1.1 package.");
        if (game.FindExport("SFXSFHandler_PowerWheel.Update") is null || game.FindExport("SFXSFHandler_PowerWheel.EPWRefreshMappingIcons") is null
            || game.FindExport("SFXSFHandler_PCPowerWheel.EPWPCTick") is null || game.FindExport("SFXSFHandler_PCPowerWheel.EPWPCFinishDrag") is null)
            throw new InvalidOperationException("Install EPW 1.10.3 before building this PC/controller patch.");

        var cooked = Path.Combine(output, Dlc, "CookedPCConsole");
        Directory.CreateDirectory(cooked);
        using var package = MEPackageHandler.CreateMemoryEmptyPackage(Path.Combine(cooked, Startup), MEGame.LE3);
        package.LECLTagData.ImportHintFiles.Add(Path.GetFileName(hudPath));
        using var cache = new PackageCache();
        var options = new UnrealScriptOptionsPackage
        {
            Cache = cache,
            GamePathOverride = Directory.GetParent(game.FilePath)!.Parent!.Parent!.FullName,
            CustomFileResolver = (name, _) => name.Equals("SFXGame.pcc", StringComparison.OrdinalIgnoreCase) ? game
                : name.Equals(Path.GetFileName(hudPath), StringComparison.OrdinalIgnoreCase) || name.Equals("HUDEnhanced.pcc", StringComparison.OrdinalIgnoreCase) ? hud : null!
        };
        using var symbols = new FileLib(package);
        if (!symbols.Initialize(options)) throw new InvalidOperationException($"Symbol initialization failed: {symbols.InitializationLog}");
        // Both retained HUD Update and EPW Update invoke this adapter. Reject
        // packages with adapter work rather than silently processing it twice.
        using var gameSymbols = new FileLib(game);
        if (!gameSymbols.Initialize(options)) throw new InvalidOperationException("Game symbol initialization failed.");
        var (_, adapterSource) = UnrealScriptCompiler.DecompileExport(game.FindExport("SFXGUIMovieLegacyAdapter.Update")!, gameSymbols, options);
        var adapterWithoutComments = Regex.Replace(adapterSource, @"//[^\r\n]*|/\*[\s\S]*?\*/", "");
        if (!Regex.IsMatch(adapterWithoutComments, @"\{\s*\}\s*$")) throw new InvalidOperationException("PC bridge requires an empty legacy adapter Update; refusing duplicate work.");
        var referencer = package.CreateObjectReferencer(isStartupPackage: true);
        var root = package.CreatePackageExport("EPWHUDCompat", cache: cache);
        var (ast, log) = UnrealScriptCompiler.CompileClass(package, File.ReadAllText(Path.Combine(source, "EPWHUDConsoleWheel.uc")), symbols, options, parent: root);
        if (ast is null || log.HasErrors || log.HasLexErrors) throw new InvalidOperationException($"Class compilation failed: {log}");
        var cls = package.FindExport(ClassPath) ?? throw new InvalidOperationException("Missing compiled class.");
        var binary = ObjectBinary.From<UClass>(cls);
        if (cls.SuperClass?.InstancedFullPath != "HUDEnhanced.SFXModHandler_HybridPowerWheel_Console") throw new InvalidOperationException("Wrong superclass.");
        var update = package.FindExport(ClassPath + ".Update") ?? throw new InvalidOperationException("Missing Update bridge.");
        if (!binary.VirtualFunctionTable.Contains(update.UIndex)) throw new InvalidOperationException("Update absent from virtual dispatch.");
        if (package.FindImport("SFXGame.SFXSFHandler_PowerWheel.Update") is null) throw new InvalidOperationException("Bridge does not reference EPW Update.");
        // LE3 startup files require this exact root referencer. Merely compiling
        // forced exports does not make the startup loader retain/load the class.
        IEntryExtensions.AddObjectsToReferencer(referencer, [cls, package.GetUExport(binary.Defaults)]);
        if (referencer.InstancedFullPath != "CombinedStartupReferencer") throw new InvalidOperationException("Wrong startup referencer name.");
        if (package.Exports.Any(e => e != referencer && e.InstancedFullPath != "EPWHUDCompat" && !e.InstancedFullPath.StartsWith("EPWHUDCompat.", StringComparison.Ordinal)))
            throw new InvalidOperationException("Unexpected dependency export; refusing to distribute it.");
        var intrinsicTypes = new HashSet<string> { "Core.Package", "Core.Function", "Core.FloatProperty", "Core.ByteProperty", "Core.BoolProperty" };
        var (roundTrip, roundTripSource) = UnrealScriptCompiler.DecompileExport(cls, symbols, options);
        if (roundTrip is null || !roundTripSource.Contains("Super(SFXSFHandler_PowerWheel).Update(fDeltaT)"))
            throw new InvalidOperationException("Bridge source read-back failed.");

        var (pcAst, pcLog) = UnrealScriptCompiler.CompileClass(package, File.ReadAllText(Path.Combine(source, "EPWHUDPCWheel.uc")), symbols, options, parent: root);
        if (pcAst is null || pcLog.HasErrors || pcLog.HasLexErrors) throw new InvalidOperationException($"PC class compilation failed: {pcLog}");
        var pcClass = package.FindExport(PCClassPath) ?? throw new InvalidOperationException("Missing PC compatibility class.");
        var pcBinary = ObjectBinary.From<UClass>(pcClass);
        if (pcClass.SuperClass?.InstancedFullPath != "HUDEnhanced.SFXModHandler_HybridPowerWheel_PC") throw new InvalidOperationException("Wrong PC superclass.");
        foreach (var name in new[] { "Update", "HandleInputEvent" })
        {
            var function = package.FindExport(PCClassPath + "." + name) ?? throw new InvalidOperationException("Missing PC bridge: " + name);
            if (!pcBinary.VirtualFunctionTable.Contains(function.UIndex)) throw new InvalidOperationException("PC bridge absent from virtual dispatch: " + name);
            if (package.FindImport("SFXGame.SFXSFHandler_PCPowerWheel." + name) is null) throw new InvalidOperationException("Missing EPW PC bridge import: " + name);
            if (package.FindImport("HUDEnhanced.SFXModHandler_HybridPowerWheel_PC." + name) is null) throw new InvalidOperationException("Missing retained HUD PC bridge import: " + name);
        }
        foreach (var name in new[] { "ExInt_IconMouseDown", "ExInt_IconMouseUp" })
        {
            // External mouse callbacks are final, not virtual-table entries.
            var callback = game.FindExport("SFXSFHandler_PCPowerWheel." + name);
            if (callback is null || !ObjectBinary.From<UFunction>(callback).FunctionFlags.HasFlag(UnrealFlags.EFunctionFlags.Final)
                || hud.FindExport("HUDEnhanced.SFXModHandler_HybridPowerWheel_PC." + name) is not null)
                throw new InvalidOperationException("Final PC mouse callback inheritance was not recognized: " + name);
        }
        var (_, pcRoundTripSource) = UnrealScriptCompiler.DecompileExport(pcClass, symbols, options);
        if (!pcRoundTripSource.Contains("Super(SFXSFHandler_PCPowerWheel).Update(fDeltaT)") || !pcRoundTripSource.Contains("Super(SFXSFHandler_PCPowerWheel).HandleInputEvent(Event, fValue)"))
            throw new InvalidOperationException("PC bridge source read-back failed.");
        IEntryExtensions.AddObjectsToReferencer(referencer, [pcClass, package.GetUExport(pcBinary.Defaults)]);
        if (package.Exports.Any(e => e != referencer && e.InstancedFullPath != "EPWHUDCompat" && !e.InstancedFullPath.StartsWith("EPWHUDCompat.", StringComparison.Ordinal)))
            throw new InvalidOperationException("Unexpected dependency export after PC compilation.");
        // Audit both classes together. Native reflection types above have no
        // script export in Core; all dependency functions must resolve exactly.
        var pcImports = package.Imports.Where(i => i.ClassName != "Package").Select(i =>
        {
            var resolved = EntryImporter.ResolveImport(i, cache, "INT", gameRootOverride: options.GamePathOverride, fileResolver: options.CustomFileResolver);
            var path = resolved?.InstancedFullPath;
            if (resolved is not null && path != i.InstancedFullPath) path = resolved.FileRef.FileNameNoExtension + "." + path;
            return new { path = i.InstancedFullPath, resolved = intrinsicTypes.Contains(i.InstancedFullPath) ? i.InstancedFullPath : path,
                intrinsic = intrinsicTypes.Contains(i.InstancedFullPath) };
        }).ToArray();
        if (pcImports.Any(i => i.path != i.resolved)) throw new InvalidOperationException("Unresolved PC imports: " + string.Join(", ", pcImports.Where(i => i.path != i.resolved).Select(i => i.path)));
        package.Save();
        using (var reread = MEPackageHandler.OpenMEPackage(package.FilePath, forceLoadFromDisk: true))
        {
            if (reread.FindExport(ClassPath + ".Update") is null || reread.FindExport(PCClassPath + ".Update") is null || reread.FindExport(PCClassPath + ".HandleInputEvent") is null || reread.Exports.Count != package.Exports.Count)
                throw new InvalidOperationException("Saved package read-back failed.");
            var refs = reread.FindExport("CombinedStartupReferencer")?.GetProperty<ArrayProperty<ObjectProperty>>("ReferencedObjects");
            if (refs is null || !refs.Select(p => reread.GetEntry(p.Value)?.InstancedFullPath).SequenceEqual(new[] { ClassPath, "EPWHUDCompat.Default__EPWHUDConsoleWheel", PCClassPath, "EPWHUDCompat.Default__EPWHUDPCWheel" }))
                throw new InvalidOperationException("Saved startup referencer does not retain the compatibility class/defaults.");
        }

        var hudMount = new MountFile(Path.Combine(hudCooked, "Mount.dlc"));
        var priority = Math.Max(4001, hudMount.MountPriority + 1);
        var mount = new MountFile { Game = MEGame.LE3, MountPriority = priority, MountFlags = new MountFlag(EME3MountFileFlag.LoadsInSingleplayer), TLKID = NameId };
        mount.WriteMountFile(Path.Combine(cooked, "Mount.dlc"));
        if (new MountFile(Path.Combine(cooked, "Mount.dlc")).MountPriority != priority) throw new InvalidOperationException("Mount read-back failed.");

        using var hudConfig = File.OpenRead(Path.Combine(hudCooked, "Default_DLC_MOD_HUDEnhance.bin"));
        var configs = CoalescedConverter.DecompileGame3ToMemory(hudConfig);
        var ui = XDocument.Parse(configs.Single(p => p.Key.Equals("BioUI.xml", StringComparison.OrdinalIgnoreCase)).Value);
        var original = ui.Descendants("Value").Single(e => (string?)e.Attribute("type") == "3" && e.Value.Contains("Tag=ConsolePowerWheel,")).Value;
        var replacement = original.Replace("HUDEnhanced.SFXModHandler_HybridPowerWheel_Console", ClassPath, StringComparison.Ordinal);
        if (replacement == original) throw new InvalidOperationException("HUD console registration was not recognized.");
        var pcOriginal = ui.Descendants("Value").Single(e => (string?)e.Attribute("type") == "3" && e.Value.Contains("Tag=PowerWheel,")).Value;
        var pcReplacement = pcOriginal.Replace("HUDEnhanced.SFXModHandler_HybridPowerWheel_PC", PCClassPath, StringComparison.Ordinal);
        if (pcReplacement == pcOriginal) throw new InvalidOperationException("HUD PC registration was not recognized.");
        var xml = new Dictionary<string, string>
        {
            ["BioEngine.xml"] = Asset("BioEngine", new XElement("Section", new XAttribute("name", "engine.startuppackages"),
                new XElement("Property", new XAttribute("name", "dlcstartuppackage"), new XAttribute("type", "3"), "Startup_MOD_EPWHUDCompat"),
                new XElement("Property", new XAttribute("name", "dlcstartuppackagename"), new XAttribute("type", "3"), "Startup_MOD_EPWHUDCompat_INT"),
                // Both import packages use RequireImportsAlreadyLoaded. Explicitly
                // preload the dependency before our new subclass, as well as
                // registering the DLC startup and the runtime class mapping.
                new XElement("Property", new XAttribute("name", "package"),
                    new XElement("Value", new XAttribute("type", "3"), "Startup_MOD_HUDEnhance_INT"),
                    new XElement("Value", new XAttribute("type", "3"), "Startup_MOD_EPWHUDCompat_INT"))),
                new XElement("Section", new XAttribute("name", "core.system"), new XElement("Property", new XAttribute("name", "seekfreepcpaths"), new XAttribute("type", "3"), $"..\\..\\BIOGame\\DLC\\{Dlc}\\CookedPCConsole")),
                new XElement("Section", new XAttribute("name", "sfxgame.sfxengine"),
                    new XElement("Property", new XAttribute("name", "dynamicloadmapping"),
                        new XElement("Value", new XAttribute("type", "3"), $"(ObjectName=\"{ClassPath}\",SeekFreePackageName=\"Startup_MOD_EPWHUDCompat_INT\")"),
                        new XElement("Value", new XAttribute("type", "3"), $"(ObjectName=\"{PCClassPath}\",SeekFreePackageName=\"Startup_MOD_EPWHUDCompat_INT\")")))),
            ["BioUI.xml"] = Asset("BioUI", new XElement("Section", new XAttribute("name", "sfxgame.sfxguiinteraction"),
                new XElement("Property", new XAttribute("name", "movielibrary"),
                    new XElement("Value", new XAttribute("type", "4"), original), new XElement("Value", new XAttribute("type", "3"), replacement),
                    new XElement("Value", new XAttribute("type", "4"), pcOriginal), new XElement("Value", new XAttribute("type", "3"), pcReplacement)))),
            ["BioWeapon.xml"] = Asset("BioWeapon")
        };
        using (var compiled = CoalescedConverter.CompileFromMemory(xml))
        using (var destination = File.Create(Path.Combine(cooked, $"Default_{Dlc}.bin"))) compiled.CopyTo(destination);
        using (var readConfig = File.OpenRead(Path.Combine(cooked, $"Default_{Dlc}.bin")))
        {
            var readAssets = CoalescedConverter.DecompileGame3ToMemory(readConfig);
            var readUi = XDocument.Parse(readAssets["BioUI.xml"]);
            var values = readUi.Descendants("Value").ToArray();
            if (!values.Select(e => e.Value).SequenceEqual(new[] { original, replacement, pcOriginal, pcReplacement })) throw new InvalidOperationException("PC/console registration round-trip failed.");
            var engine = XDocument.Parse(readAssets["BioEngine.xml"]);
            var preload = engine.Descendants("Property").Single(e => (string?)e.Attribute("name") == "package").Elements("Value").Select(e => e.Value).ToArray();
            if (!preload.SequenceEqual(new[] { "Startup_MOD_HUDEnhance_INT", "Startup_MOD_EPWHUDCompat_INT" }))
                throw new InvalidOperationException("Runtime dependency preload order was not preserved.");
            if (!engine.Descendants("Property").Single(e => (string?)e.Attribute("name") == "dynamicloadmapping").Elements("Value").Select(e => e.Value)
                .SequenceEqual(new[] { $"(ObjectName=\"{ClassPath}\",SeekFreePackageName=\"Startup_MOD_EPWHUDCompat_INT\")", $"(ObjectName=\"{PCClassPath}\",SeekFreePackageName=\"Startup_MOD_EPWHUDCompat_INT\")" }))
                throw new InvalidOperationException("Runtime class mapping was not preserved.");
        }
        var merged = ConfigAssetBundle.FromSingleFile(MEGame.LE3, Path.Combine(hudCooked, "Default_DLC_MOD_HUDEnhance.bin"));
        string[] ActiveMovies() => merged.GetAsset("BioUI").Sections["sfxgame.sfxguiinteraction"]["movielibrary"]
            .Where(v => v.ParseAction != CoalesceParseAction.Remove).Select(v => v.Value).ToArray();
        var expectedMovies = ActiveMovies().Select(v => v == original ? replacement : v == pcOriginal ? pcReplacement : v).Order().ToArray();
        ConfigAssetBundle.FromSingleFile(MEGame.LE3, Path.Combine(cooked, $"Default_{Dlc}.bin")).MergeInto(merged);
        if (!ActiveMovies().Order().SequenceEqual(expectedMovies) || ActiveMovies().Count(v => v.Contains("Tag=ConsolePowerWheel,")) != 1 || ActiveMovies().Count(v => v.Contains("Tag=PowerWheel,")) != 1)
            throw new InvalidOperationException("Compatibility config did not replace exactly one PC and one console registration.");
        foreach (var language in new[] { "INT", "DEU", "ESN", "FRA", "ITA", "JPN", "POL", "RUS" })
            HuffmanCompression.SaveToTlkFile(Path.Combine(cooked, $"{Dlc}_{language}.tlk"), new List<TLKStringRef> { new(NameId, "EPW - HUD Enhancements Compatibility\0") });
        File.Copy(Path.Combine(source, "moddesc.ini"), Path.Combine(output, "moddesc.ini"));
        foreach (var input in inputHashes) if (Hash(input.Key) != input.Value) throw new InvalidOperationException("An input changed during build.");
        var evidence = new { version = "0.4", inputHashes, startupReferencerVerified = true, mountPriority = priority, configMergeVerified = true, adapterUpdateEmptyVerified = true, originalRegistration = original, replacementRegistration = replacement,
            pcOriginalRegistration = pcOriginal, pcReplacementRegistration = pcReplacement,
            exports = package.Exports.Select(e => new { e.ClassName, e.InstancedFullPath, flags = e.ExportFlags.ToString() }), imports = pcImports, roundTripSource, pcRoundTripSource,
            virtualFunctions = binary.VirtualFunctionTable.Select(i => package.GetEntry(i)?.InstancedFullPath),
            pcVirtualFunctions = pcBinary.VirtualFunctionTable.Select(i => package.GetEntry(i)?.InstancedFullPath),
            files = Directory.EnumerateFiles(output, "*", SearchOption.AllDirectories).Order().Select(p => new { path = Path.GetRelativePath(output, p), sha256 = Hash(p) }).ToArray() };
        File.WriteAllText(Path.Combine(output, "build-evidence.json"), JsonSerializer.Serialize(evidence, new JsonSerializerOptions { WriteIndented = true }));
        Console.WriteLine($"Built original compatibility DLC in {output}; mount {priority}. No installation performed.");
        return 0;
    }

    private static string Hash(string path) => Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(path)));
    private static string Asset(string id, params XElement[] sections) => new XDocument(new XElement("CoalesceAsset", new XAttribute("id", id),
        new XAttribute("name", id.ToLowerInvariant() + ".ini"), new XAttribute("source", "..\\..\\biogame\\config\\" + id.ToLowerInvariant() + ".ini"), new XElement("Sections", sections))).ToString();
}
