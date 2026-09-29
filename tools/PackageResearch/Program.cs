using System.Security.Cryptography;
using System.Text.Json;
using System.Text.RegularExpressions;
using LegendaryExplorerCore;
using LegendaryExplorerCore.Packages;
using LegendaryExplorerCore.UnrealScript;
using LegendaryExplorerCore.Unreal;

try { return Run(args); }
catch (Exception exception)
{
    Console.Error.WriteLine($"Research operation failed: {exception.Message}");
    return 1;
}

static int Run(string[] args)
{
    // Read-only inspection and in-memory compilation. Never saves a game package.
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
                        if (!memberSuccess) errors++;
                        Console.WriteLine($"{name} + {memberName}: {(memberSuccess ? "PASS" : "FAIL")} {memberLog}");
                        results.Add(new { export = name, member = memberName, success = memberSuccess, log = memberLog.ToString() });
                    }
                    changedClasses.Add(classExport.UIndex);
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
        File.WriteAllText(Path.Combine(args[3], "validation.json"), JsonSerializer.Serialize(results, new JsonSerializerOptions { WriteIndented = true }));
        return errors == 0 ? 0 : 1;
    }

    // Full decompilations must stay in ignored local research.
    if (args.Length != 3)
    {
        Console.Error.WriteLine("Usage: PackageResearch <package.pcc> <output-directory> <class-or-function-regex> | list <package.pcc> <export-regex> | validate <package.pcc> <manifest.json> <output-directory>");
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
