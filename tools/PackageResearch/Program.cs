using System.Security.Cryptography;
using System.Text.Json;
using System.Text.RegularExpressions;
using LegendaryExplorerCore;
using LegendaryExplorerCore.Packages;
using LegendaryExplorerCore.UnrealScript;
using LegendaryExplorerCore.Unreal;
using LegendaryExplorerCore.Unreal.BinaryConverters;

try { return Run(args); }
catch (Exception exception)
{
    Console.Error.WriteLine($"Research operation failed: {exception.Message}");
    return 1;
}

static int Run(string[] args)
{
    // Read-only inspection and in-memory compilation. Never saves a game package.
    if (args.Length == 2 && args[0] == "packageinfo")
    {
        LegendaryExplorerCoreLib.InitLib(TaskScheduler.Default);
        using var p = MEPackageHandler.OpenMEPackage(Path.GetFullPath(args[1]));
        Console.WriteLine($"{p.FilePath}: flags={p.Flags}");
        foreach (var e in p.Exports.Where(e => e.IsClass || e.ClassName == "Package"))
            Console.WriteLine($"{e.InstancedFullPath}: object={e.ObjectFlags}; export={e.ExportFlags}; super={e.SuperClass?.InstancedFullPath}; archetype={e.Archetype?.InstancedFullPath}");
        return 0;
    }
    if (args.Length == 5 && args[0] == "buildhudcompat")
        return HudCompatibilityBuilder.Build(args[1], args[2], args[3], args[4]);
    if (args.Length == 3 && args[0] == "configdump")
    {
        using var input = File.OpenRead(Path.GetFullPath(args[1]));
        Directory.CreateDirectory(args[2]);
        foreach (var file in LegendaryExplorerCore.Coalesced.CoalescedConverter.DecompileGame3ToMemory(input))
            File.WriteAllText(Path.Combine(args[2], Path.GetFileName(file.Key)), file.Value);
        return 0;
    }
    if (args.Length == 4 && args[0] == "classinfo")
    {
        LegendaryExplorerCoreLib.InitLib(TaskScheduler.Default);
        using var infoPackage = MEPackageHandler.OpenMEPackage(Path.GetFullPath(args[1]));
        var infoFilter = new Regex(args[3], RegexOptions.IgnoreCase | RegexOptions.CultureInvariant, TimeSpan.FromSeconds(2));
        var info = infoPackage.Exports.Where(e => e.IsClass && infoFilter.IsMatch(e.InstancedFullPath)).Select(e =>
        {
            var binary = ObjectBinary.From<UClass>(e);
            var defaults = infoPackage.GetUExport(binary.Defaults);
            return new
            {
                name = e.InstancedFullPath,
                parent = infoPackage.GetEntry(e.idxSuperClass)?.InstancedFullPath,
                virtualFunctions = binary.VirtualFunctionTable.Select(i => new { index = i, path = infoPackage.GetEntry(i)?.InstancedFullPath }).ToArray(),
                strings = defaults.GetProperties().OfType<StrProperty>().Select(p => new { name = p.Name.Instanced, index = p.StaticArrayIndex, value = p.Value }).ToArray(),
                objects = defaults.GetProperties().OfType<ObjectProperty>().Select(p => new { name = p.Name.Instanced, index = p.StaticArrayIndex, path = infoPackage.GetEntry(p.Value)?.InstancedFullPath }).ToArray()
            };
        }).ToArray();
        File.WriteAllText(Path.GetFullPath(args[2]), JsonSerializer.Serialize(info, new JsonSerializerOptions { WriteIndented = true }));
        Console.WriteLine($"Inspected {info.Length} classes without modifying the package.");
        return 0;
    }
    if (args.Length == 2 && args[0] == "auditwheel")
    {
        LegendaryExplorerCoreLib.InitLib(TaskScheduler.Default);
        using var auditPackage = MEPackageHandler.OpenMEPackage(Path.GetFullPath(args[1]));
        return AuditWheel(auditPackage) ? 0 : 1;
    }
    if (args.Length == 4 && args[0] == "extractswf")
    {
        LegendaryExplorerCoreLib.InitLib(TaskScheduler.Default);
        using var moviePackage = MEPackageHandler.OpenMEPackage(Path.GetFullPath(args[1]));
        var movie = moviePackage.Exports.Single(e => e.InstancedFullPath == args[2] && e.ClassName == "GFxMovieInfo");
        var data = movie.GetProperty<ImmutableByteArrayProperty>("RawData")?.Bytes
                   ?? throw new InvalidOperationException("Movie has no RawData.");
        File.WriteAllBytes(Path.GetFullPath(args[3]), data);
        Console.WriteLine($"Extracted {data.Length} bytes for local research only.");
        return 0;
    }
    if (args.Length == 3 && args[0] == "list")
    {
        LegendaryExplorerCoreLib.InitLib(TaskScheduler.Default);
        using var listingPackage = MEPackageHandler.OpenMEPackage(Path.GetFullPath(args[1]));
        var listingFilter = new Regex(args[2], RegexOptions.IgnoreCase | RegexOptions.CultureInvariant, TimeSpan.FromSeconds(2));
        foreach (var export in listingPackage.Exports.Where(e => listingFilter.IsMatch(e.InstancedFullPath)))
            Console.WriteLine($"{export.UIndex}\t{export.ClassName}\t{export.InstancedFullPath}");
        return 0;
    }
    if (args.Length == 4 && args[0] == "validate")
    {
        LegendaryExplorerCoreLib.InitLib(TaskScheduler.Default);
        using var target = MEPackageHandler.OpenMEPackage(Path.GetFullPath(args[1]));
        using var symbols = new FileLib(target);
        var usop = new UnrealScriptOptionsPackage();
        if (!symbols.Initialize(usop)) throw new InvalidOperationException($"Symbol initialization failed: {symbols.InitializationLog}");
        var classData = target.Exports.Where(e => e.IsClass).ToDictionary(e => e.UIndex, e => SHA256.HashData(e.Data));
        var le2WheelLayout = target.Game == MEGame.LE2 ? WheelLayout(target) : null;
        var manifestPath = Path.GetFullPath(args[2]);
        using var manifest = JsonDocument.Parse(File.ReadAllText(manifestPath));
        if (manifest.RootElement.GetProperty("game").GetString() != target.Game.ToString())
            throw new InvalidOperationException("Manifest game does not match the package.");
        Directory.CreateDirectory(args[3]);
        var errors = 0;
        var results = new List<object>();
        var changedClasses = new HashSet<int>();
        foreach (var file in manifest.RootElement.GetProperty("files").EnumerateArray())
        {
            if (file.GetProperty("filename").GetString() != Path.GetFileName(args[1]))
                throw new InvalidOperationException("This validator supports one package per manifest.");
            foreach (var change in file.GetProperty("changes").EnumerateArray())
            {
                var name = change.GetProperty("entryname").GetString()!;
                if (change.TryGetProperty("addtoclassorreplace", out var classUpdate))
                {
                    var classExport = target.Exports.Single(e => e.InstancedFullPath == name && e.IsClass);
                    foreach (var script in classUpdate.GetProperty("scriptfilenames").EnumerateArray())
                    {
                        var memberName = script.GetString()!;
                        if (Path.GetFileName(memberName) != memberName) throw new InvalidOperationException("Script must be beside its manifest.");
                        var memberSource = File.ReadAllText(Path.Combine(Path.GetDirectoryName(manifestPath)!, memberName));
                        var memberLog = UnrealScriptCompiler.AddOrReplaceInClass(classExport, memberSource, symbols, usop);
                        var memberSuccess = !memberLog.HasErrors && !memberLog.HasLexErrors;
                        // Core requires fresh symbols/binaries between mutations.
                        // Cached UField.Next values can otherwise report false loops.
                        if (memberSuccess && !symbols.ReInitializeFile(usop))
                            throw new InvalidOperationException($"Symbol refresh failed after {memberName}: {symbols.InitializationLog}");
                        if (!memberSuccess) errors++;
                        Console.WriteLine($"{name} + {memberName}: {(memberSuccess ? "PASS" : "FAIL")} {memberLog}");
                        results.Add(new { export = name, member = memberName, success = memberSuccess, log = memberLog.ToString() });
                    }
                    changedClasses.Add(classExport.UIndex);
                    // Local research evidence includes the actual dispatch targets
                    // after recompilation, not only inherited function names.
                    var compiledClass = ObjectBinary.From<UClass>(classExport);
                    File.WriteAllLines(Path.Combine(args[3], name + ".virtual-functions.tsv"),
                        (compiledClass.VirtualFunctionTable ?? []).Select(i => $"{i}\t{target.GetEntry(i)?.InstancedFullPath}"));
                    var (classAst, classSource) = UnrealScriptCompiler.DecompileExport(classExport, symbols, usop);
                    if (classAst is null) errors++;
                    File.WriteAllText(Path.Combine(args[3], name + ".uc"), classSource);
                    continue;
                }
                var scriptName = change.GetProperty("scriptupdate").GetProperty("scriptfilename").GetString()!;
                if (Path.GetFileName(scriptName) != scriptName) throw new InvalidOperationException("Script must be beside its manifest.");
                var source = File.ReadAllText(Path.Combine(Path.GetDirectoryName(manifestPath)!, scriptName));
                var export = target.Exports.Single(e => e.InstancedFullPath == name && e.ClassName == "Function");
                var (ast, log) = UnrealScriptCompiler.CompileFunction(export, source, symbols, usop);
                var success = ast is not null && !log.HasErrors && !log.HasLexErrors;
                if (!success) errors++;
                Console.WriteLine($"{name}: {(success ? "PASS" : "FAIL")} {log}");
                if (success)
                {
                    if (!symbols.ReInitializeFile(usop))
                        throw new InvalidOperationException($"Symbol refresh failed after {name}: {symbols.InitializationLog}");
                    var (roundTripAst, text) = UnrealScriptCompiler.DecompileExport(export, symbols, usop);
                    if (roundTripAst is null) { success = false; errors++; }
                    File.WriteAllText(Path.Combine(args[3], name + ".uc"), text);
                }
                results.Add(new { export = name, success, log = log.ToString() });
            }
        }
        foreach (var (index, fingerprint) in classData)
            if (!changedClasses.Contains(index) && !SHA256.HashData(target.GetUExport(index).Data).SequenceEqual(fingerprint))
                throw new InvalidOperationException($"Class export changed during function compilation: {target.GetUExport(index).InstancedFullPath}");
        Console.WriteLine("PASS: only classes explicitly listed for member addition changed class export data.");
        if (le2WheelLayout is not null && changedClasses.Any(index => target.GetUExport(index).InstancedFullPath == "SFXSFHandler_PowerWheel"))
        {
            var layoutSuccess = le2WheelLayout.SequenceEqual(WheelLayout(target));
            var helpers = target.Exports.Where(e => e.ClassName == "Function" && e.Parent?.InstancedFullPath == "SFXSFHandler_PowerWheel" && e.ObjectName.Name.StartsWith("EPW", StringComparison.Ordinal));
            var helperSuccess = helpers.All(e => ObjectBinary.From<UFunction>(e).FunctionFlags.HasFlag(UnrealFlags.EFunctionFlags.Final));
            Console.WriteLine($"{(layoutSuccess && helperSuccess ? "PASS" : "FAIL")}: LE2 wheel class/struct property declarations unchanged; EPW helpers final={helperSuccess}.");
            if (!layoutSuccess || !helperSuccess) errors++;
            results.Add(new { check = "le2-wheel-native-layout", success = layoutSuccess && helperSuccess });
        }
        if (target.Game == MEGame.LE3 && changedClasses.Any(index => target.GetUExport(index).InstancedFullPath == "SFXSFHandler_PowerWheel"))
        {
            var virtualSuccess = AuditWheel(target);
            if (!virtualSuccess) errors++;
            results.Add(new { check = "wheel-virtual-inheritance", success = virtualSuccess });
        }
        File.WriteAllText(Path.Combine(args[3], "validation.json"), JsonSerializer.Serialize(results, new JsonSerializerOptions { WriteIndented = true }));
        File.WriteAllLines(Path.Combine(args[3], "imports.tsv"), target.Imports.Select(e => $"{e.UIndex}\t{e.ClassName}\t{e.InstancedFullPath}"));
        return errors == 0 ? 0 : 1;
    }

    // Full decompilations must stay in ignored local research.
    if (args.Length != 3)
    {
        Console.Error.WriteLine("Usage: PackageResearch <package.pcc> <output-directory> <class-or-function-regex> | list <package.pcc> <export-regex> | validate <package.pcc> <manifest.json> <output-directory> | auditwheel <package.pcc> | configdump <coalesced.bin> <output-directory> | classinfo <package.pcc> <output.json> <class-regex> | buildhudcompat <hud-mod-root> <SFXGame.pcc> <source-directory> <new-output-directory>");
        return 2;
    }

    var path = Path.GetFullPath(args[0]);
    var output = Path.GetFullPath(args[1]);
    var filter = new Regex(args[2], RegexOptions.IgnoreCase | RegexOptions.CultureInvariant, TimeSpan.FromSeconds(2));
    if (!File.Exists(path)) throw new FileNotFoundException("Game package not found", path);
    Directory.CreateDirectory(output);
    LegendaryExplorerCoreLib.InitLib(TaskScheduler.Default);
    using var package = MEPackageHandler.OpenMEPackage(path);
    using var lib = new FileLib(package);
    var options = new UnrealScriptOptionsPackage();
    if (!lib.Initialize(options)) throw new InvalidOperationException($"Symbol initialization failed: {lib.InitializationLog}");

    var exports = package.Exports.Where(e => e.ClassName is "Class" or "Function" or "State").ToList();
    File.WriteAllLines(Path.Combine(output, "exports.tsv"), exports.Select(e => $"{e.UIndex}\t{e.ClassName}\t{e.InstancedFullPath}"));
    var failures = new List<string>();
    var count = 0;
    foreach (var export in exports.Where(e => filter.IsMatch(e.InstancedFullPath)))
    {
        var (ast, source) = UnrealScriptCompiler.DecompileExport(export, lib, options);
        File.WriteAllText(Path.Combine(output, export.InstancedFullPath + ".uc"), source);
        if (ast is null) failures.Add(export.InstancedFullPath);
        count++;
    }
    var metadata = new
    {
        package = path,
        game = package.Game.ToString(),
        sha256 = Convert.ToHexString(SHA256.HashData(File.ReadAllBytes(path))),
        length = new FileInfo(path).Length,
        utc = DateTime.UtcNow,
        filter = args[2],
        exported = count,
        failures,
        coreVersion = typeof(LegendaryExplorerCoreLib).Assembly.GetName().Version?.ToString()
    };
    File.WriteAllText(Path.Combine(output, "inspection.json"), JsonSerializer.Serialize(metadata, new JsonSerializerOptions { WriteIndented = true }));
    Console.WriteLine($"{package.Game}: exported {count}; failed {failures.Count}; SHA256 {metadata.sha256}");
    return failures.Count == 0 ? 0 : 1;
}

static bool AuditWheel(IMEPackage package)
{
    var parentExport = package.Exports.Single(e => e.IsClass && e.InstancedFullPath == "SFXSFHandler_PowerWheel");
    var childExport = package.Exports.Single(e => e.IsClass && e.InstancedFullPath == "SFXSFHandler_PCPowerWheel");
    var parent = ObjectBinary.From<UClass>(parentExport);
    var child = ObjectBinary.From<UClass>(childExport);
    var childNames = child.VirtualFunctionTable.Select(index => package.GetEntry(index)?.ObjectName.Name).ToHashSet(StringComparer.OrdinalIgnoreCase);
    var missing = parent.VirtualFunctionTable.Select(index => package.GetEntry(index)).Where(entry => !childNames.Contains(entry?.ObjectName.Name)).ToList();
    // Tables are class-specific: compare inherited membership/count, not slot order.
    var success = child.VirtualFunctionTable.Length >= parent.VirtualFunctionTable.Length && missing.Count == 0;
    Console.WriteLine($"{(success ? "PASS" : "FAIL")}: wheel virtual inheritance: base {parent.VirtualFunctionTable.Length}, PC {child.VirtualFunctionTable.Length}; missing inherited functions {missing.Count}.");
    foreach (var entry in missing) Console.WriteLine($"Missing in PC wheel: {entry?.InstancedFullPath}");
    var virtualIndices = parent.VirtualFunctionTable.ToHashSet();
    foreach (var export in package.Exports.Where(e => e.ClassName == "Function" && e.idxLink == parentExport.UIndex && e.ObjectName.Name.StartsWith("EPW", StringComparison.Ordinal)))
    {
        var function = ObjectBinary.From<UFunction>(export);
        var final = function.FunctionFlags.HasFlag(UnrealFlags.EFunctionFlags.Final);
        var isVirtual = virtualIndices.Contains(export.UIndex);
        Console.WriteLine($"{(final && !isVirtual ? "PASS" : "FAIL")}: {export.ObjectName.Name}: final={final}, virtual={isVirtual}");
        success &= final && !isVirtual;
    }
    return success;
}

static string[] WheelLayout(IMEPackage package) => package.Exports
    .Where(e => e.InstancedFullPath.StartsWith("SFXSFHandler_PowerWheel.", StringComparison.Ordinal)
        && e.ClassName.EndsWith("Property", StringComparison.Ordinal)
        && (e.Parent?.IsClass == true || e.Parent?.ClassName == "ScriptStruct"))
    .Select(e =>
    {
        var property = (UProperty)ObjectBinary.From(e);
        return $"{e.InstancedFullPath}|{e.ClassName}|{property.ArraySize}|{property.PropertyFlags}";
    }).Order(StringComparer.Ordinal).ToArray();
