"""Static regression check for authored LE3 GFx wrapper scopes (no game access).

This is a source lint, not a control-flow proof or runtime memory measurement.
The installed-package compiler and in-game A/B measurement remain required.
"""
from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[1]
FACTORY = re.compile(r'\b(?:GetVariableObject|CreateObject|CreateArray|GetObject|CreateEmptyMovieClip|AttachMovie|CastTo|GetElementObject|GetElementMemberObject|ActionScriptObject|ActionScriptArray)\s*\(')

def code_only(source):
    # Preserve offsets while masking comments and strings for the source lint.
    token = r'//[^\n]*|/\*[\s\S]*?\*/|"(?:\\.|[^"\\])*"'
    return re.sub(token, lambda match: ' ' * len(match.group()), source)

def audit_source(source):
    code = code_only(source)
    errors = []
    for match in FACTORY.finditer(code):
        prefix = code[:match.start()].rstrip()
        # A receiver (and optional array subscript) may follow EPWTempValue(.
        prefix = re.sub(r'\w+(?:\[[^\]]+\])?\.$', '', prefix).rstrip()
        if not prefix.endswith('EPWTempValue('):
            errors.append('unscoped factory at line ' + str(code[:match.start()].count('\n') + 1))
    if FACTORY.search(code) and 'local array<GFxValue> aEPWTemps;' not in code:
        errors.append('factory without a local temporary scope')
    if 'local array<GFxValue> aEPWTemps;' in code:
        for match in re.finditer(r'\breturn\b', code):
            if not code[:match.start()].rstrip().endswith('EPWReleaseTemps(aEPWTemps);'):
                errors.append('return without release at line ' + str(code[:match.start()].count('\n') + 1))
        tail = code.rstrip().removesuffix('}').rstrip()
        if not (tail.endswith('EPWReleaseTemps(aEPWTemps);') or re.search(r'EPWReleaseTemps\(aEPWTemps\);\s*return[^;]*;$', tail)):
            errors.append('fallthrough without release')
    return errors

def main():
    # Negative cases make sure new raw lookups and missed early exits are caught.
    assert audit_source('function F() { o = GetVariableObject("x"); }')
    assert audit_source('function F() { local array<GFxValue> aEPWTemps; return; }')
    assert not audit_source('function F() { local array<GFxValue> aEPWTemps; o = EPWTempValue(oParent.GetObject("x"), aEPWTemps); EPWReleaseTemps(aEPWTemps); return; }')
    manifest = json.loads((ROOT / 'src/LE3/MergeMods/EnhancedPowerWheel.json').read_text())
    names = []
    for package in manifest['files']:
        for change in package['changes']:
            names += change.get('addtoclassorreplace', {}).get('scriptfilenames', [])
            if 'scriptupdate' in change:
                names.append(change['scriptupdate']['scriptfilename'])
    failures = []
    for name in names:
        if name.endswith(('.EPWTempValue.uc', '.EPWReleaseTemps.uc')):
            continue
        failures += [name + ': ' + error for error in audit_source((ROOT / 'src/LE3/MergeMods' / name).read_text())]
    if failures:
        raise SystemExit('\n'.join(failures))
    print(f'PASS: {len(names)} manifest functions; scoped factories, early returns and fallthrough; negative fixtures.')

if __name__ == '__main__':
    main()
