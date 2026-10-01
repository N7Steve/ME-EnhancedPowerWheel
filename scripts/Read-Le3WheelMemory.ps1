param(
    [string]$OutputDirectory = (Join-Path (Split-Path $PSScriptRoot -Parent) 'research/local/LE3/LiveWheelMemory'),
    [ValidateRange(1,64)][int]$MaxGiB = 16
)
$ErrorActionPreference = 'Stop'
$gameProcesses = @(Get-Process -Name MassEffect3 -ErrorAction Stop)
if ($gameProcesses.Count -ne 1) { throw 'Expected exactly one MassEffect3 process.' }
$gameProcess = $gameProcesses[0]
if (![Environment]::Is64BitProcess) { throw 'Run with 64-bit PowerShell.' }
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
# VM_READ + QUERY_INFORMATION only. No writes, injection, suspension or dumps.
if (!( 'EPWReadOnlyMemory' -as [type])) {
Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Runtime.InteropServices;
using System.Text;
public static class EPWReadOnlyMemory {
    [StructLayout(LayoutKind.Sequential)] struct Region {
        public IntPtr BaseAddress, AllocationBase;
        public uint AllocationProtect;
        public ushort PartitionId;
        public UIntPtr RegionSize;
        public uint State, Protect, Type;
    }
    [DllImport("kernel32.dll", SetLastError=true)] static extern IntPtr OpenProcess(uint access, bool inherit, int processId);
    [DllImport("kernel32.dll", SetLastError=true)] static extern bool ReadProcessMemory(IntPtr handle, IntPtr address, byte[] buffer, UIntPtr size, out UIntPtr read);
    [DllImport("kernel32.dll")] static extern UIntPtr VirtualQueryEx(IntPtr handle, IntPtr address, out Region info, UIntPtr size);
    [DllImport("kernel32.dll")] static extern bool CloseHandle(IntPtr handle);
    public class Hit { public string Address {get;set;} public string Needle {get;set;} public string Encoding {get;set;} public string Context {get;set;} }
    public class Result { public int ProcessId {get;set;} public long BytesRead {get;set;} public int ReadFailures {get;set;} public bool BudgetReached {get;set;} public List<Hit> Hits {get;set;} = new List<Hit>(); }
    public static Result Scan(int processId, long budget) {
        var handle = OpenProcess(0x410, false, processId);
        if (handle == IntPtr.Zero) throw new Win32Exception(Marshal.GetLastWin32Error());
        var result = new Result { ProcessId=processId };
        string[] terms = { "EPW16 ROW", "EPW16 INPUT", "EPWHelpText", "EPWMapTarget", "EPWHelpSourceProcessed", "EPWHelpTexture", "Map power to", "Reorder power", "Switch wheel" };
        var patterns = new List<(string term, Encoding encoding, byte[] bytes)>();
        foreach (var term in terms) foreach (var encoding in new [] {Encoding.UTF8, Encoding.Unicode}) patterns.Add((term,encoding,encoding.GetBytes(term)));
        var counts = new Dictionary<string,int>();
        try {
            long address=0;
            while (address < 0x7FFFFFFF0000 && result.BytesRead < budget) {
                Region region;
                if (VirtualQueryEx(handle,new IntPtr(address),out region,new UIntPtr((uint)Marshal.SizeOf<Region>())).ToUInt64()==0) break;
                long start=region.BaseAddress.ToInt64(), size=(long)region.RegionSize.ToUInt64();
                if (size<=0 || start+size<=address) break;
                address=start+size;
                // Only readable committed private/mapped data, excluding executable image pages.
                if (region.State!=0x1000 || region.Type==0x1000000 || (region.Protect & 0x101)!=0) continue;
                for(long offset=0; offset<size && result.BytesRead<budget; offset+=4*1024*1024) {
                    int length=(int)Math.Min(4*1024*1024+2048,Math.Min(size-offset,budget-result.BytesRead));
                    byte[] buffer=new byte[length]; UIntPtr read;
                    ReadProcessMemory(handle,new IntPtr(start+offset),buffer,new UIntPtr((uint)length),out read);
                    int actual=(int)read.ToUInt64();
                    if(actual==0) { result.ReadFailures++; continue; }
                    result.BytesRead+=actual;
                    foreach(var pattern in patterns) {
                        string key=pattern.term+pattern.encoding.WebName;
                        int count; counts.TryGetValue(key,out count);
                        if(count>=40) continue;
                        int position=0;
                        while(position<actual-pattern.bytes.Length && count<40) {
                            int found=buffer.AsSpan(position,actual-position).IndexOf(pattern.bytes);
                            if(found<0) break;
                            found+=position;
                            bool diagnostic=pattern.term.StartsWith("EPW16 ",StringComparison.Ordinal);
                            int first=found, last=found;
                            int unit=pattern.encoding==Encoding.Unicode ? 2 : 1;
                            int before=diagnostic ? 0 : 240, after=diagnostic ? 8192 : 1200;
                            // Keep only the surrounding terminated string, not
                            // arbitrary adjacent heap data or a process dump.
                            while(first>=unit && found-first<before && (buffer[first-unit]!=0 || (unit==2 && buffer[first-1]!=0))) first-=unit;
                            while(last+unit<=actual && last-found<after && (buffer[last]!=0 || (unit==2 && buffer[last+1]!=0))) last+=unit;
                            string context=pattern.encoding.GetString(buffer,first,last-first);
                            result.Hits.Add(new Hit {Address="0x"+(start+offset+found).ToString("X"),Needle=pattern.term,Encoding=pattern.encoding.WebName,Context=context});
                            position=found+pattern.bytes.Length; count++;
                        }
                        counts[key]=count;
                    }
                }
            }
            result.BudgetReached=result.BytesRead>=budget;
            return result;
        } finally { CloseHandle(handle); }
    }
}
'@
}
$startedUtc = [DateTime]::UtcNow
$result = [EPWReadOnlyMemory]::Scan($gameProcess.Id, [long]$MaxGiB * 1GB)
$record = [ordered]@{ startedUtc=$startedUtc; endedUtc=[DateTime]::UtcNow; executable=$gameProcess.Path; access='PROCESS_VM_READ | PROCESS_QUERY_INFORMATION'; result=$result }
$outputPath = Join-Path $OutputDirectory ('wheel-memory-' + $startedUtc.ToString('yyyyMMdd-HHmmss') + '.json')
$record | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $outputPath -Encoding utf8
Write-Output "Read-only PID $($gameProcess.Id): $($result.BytesRead) bytes, $($result.Hits.Count) scoped hits, $($result.ReadFailures) read failures, budgetReached=$($result.BudgetReached)."
Write-Output "Local research: $outputPath"
