#!/usr/bin/env python3
"""Export both release packs and check their compiled gameplay/startup gates.

Usage: python tools/verify_exports.py GODOT [OUTPUT_DIRECTORY]
Requires official Godot 4.5.1 Linux and Windows release templates installed in
Godot's usual export_templates directory (honors XDG_DATA_HOME on Linux).
This verifies Windows pack contents on Linux, not native Windows execution.
"""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

project = Path(__file__).resolve().parents[1]
engine = Path(sys.argv[1]).resolve()
output = Path(sys.argv[2]).resolve() if len(sys.argv) > 2 else project / 'builds/release-validation'
output.mkdir(parents=True, exist_ok=True)
windows = output / 'Lichterhain.exe'
linux = output / 'Lichterhain.x86_64'
base = ['--headless', '--audio-driver', 'Dummy', '--path', str(project)]
smoke = str(project / 'tests/export_smoke.gd')
startup = str(project / 'tools/verify_content_startup.py')
stages = [
    ('windows_export', [str(engine), *base, '--export-release', 'Windows Desktop', str(windows)]),
    ('linux_export', [str(engine), *base, '--export-release', 'Linux Desktop', str(linux)]),
    ('linux_release_smoke', [str(linux), *base, '--script', smoke]),
    ('windows_pack_smoke', [str(engine), *base, '--main-pack', str(windows), '--script', smoke]),
    ('linux_release_startup', [sys.executable, startup, str(linux)]),
    ('windows_pack_startup', [sys.executable, startup, str(engine), str(windows)]),
]
markers = ['EXPORT DATA CONSISTENCY PASS', 'EXPORT INTERACTION CONTRACT PASS',
           'EXPORT HIT RESOLUTION PASS', 'EXPORT ACTIVE COMBAT PASS',
           'EXPORT STATE REPLAY PASS', 'EXPORT REGION LIFECYCLE PASS',
           'EXPORT SAVE RECOVERY PASS', 'EXPORT SAVE ERROR PASS', 'EXPORT SMOKE PASS']
results = []
for name, command in stages:
    if name == 'linux_release_smoke': linux.chmod(linux.stat().st_mode | 0o111)
    try:
        run = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=240)
    except subprocess.TimeoutExpired as exc:
        text = exc.stdout or b''
        if isinstance(text, bytes): text = text.decode('utf-8', errors='replace')
        run = subprocess.CompletedProcess(command, 124, text + '\nFAIL: export gate timeout\n')
    (output / (name + '.log')).write_text(run.stdout)
    errors = [line for line in run.stdout.splitlines() if 'ERROR:' in line or line.startswith('FAIL')]
    if name.endswith('_startup'):
        errors = [line for line in errors if not line.startswith(('ERROR: data/', 'ERROR: res://data/'))]
        if 'CONTENT STARTUP SUMMARY ' not in run.stdout: errors.append('Missing startup completion')
    if name.endswith('_smoke'):
        errors += ['Missing ' + marker for marker in markers if marker not in run.stdout]
    if name.endswith('_export'):
        destination = windows if name == 'windows_export' else linux
        if not destination.is_file() or destination.stat().st_size < 1000000: errors.append('No release binary')
    results.append({'stage': name, 'passed': run.returncode == 0 and not errors,
                    'exit_code': run.returncode, 'errors': errors})
    print(name, 'PASS' if results[-1]['passed'] else 'FAIL', flush=True)
    if not results[-1]['passed']:
        print('\n'.join(errors[:20]), flush=True)
        break
report = {'stages': results, 'native_windows_tested': False,
          'binaries': {p.name: {'size_bytes': p.stat().st_size, 'sha256': hashlib.sha256(p.read_bytes()).hexdigest()}
                       for p in [windows, linux] if p.is_file()}}
(output / 'export_results.json').write_text(json.dumps(report, indent=2) + '\n')
sys.exit(0 if len(results) == len(stages) and all(x['passed'] for x in results) else 1)
