#!/usr/bin/env python3
"""Build separate developer apps. Usage: export_sandbox.py GODOT OUTPUT_DIRECTORY.

Official 4.5.1 templates must be installed. Source project settings stay intact.
"""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

project = Path(__file__).resolve().parents[1]
engine = Path(sys.argv[1]).resolve()
output = Path(sys.argv[2]).resolve()
output.mkdir(parents=True, exist_ok=True)
stage = output / 'project'
stage.mkdir(exist_ok=True)
for directory in ['assets', 'scripts', 'scenes', 'data', 'developer', 'licenses']:
    shutil.copytree(project / directory, stage / directory, dirs_exist_ok=True)
for name in ['project.godot', 'export_presets.cfg', 'icon.svg']:
    shutil.copy2(project / name, stage / name)
settings = (stage / 'project.godot').read_text()
settings = settings.replace('config/name="Lichterhain"', 'config/name="Lichterhain Developer Sandbox"\nconfig/use_custom_user_dir=true\nconfig/custom_user_dir_name="Lichterhain_DeveloperSandbox"')
settings = settings.replace('res://scenes/game.tscn', 'res://developer/sandbox.tscn')
settings = settings.replace('viewport_width=640', 'viewport_width=1280').replace('viewport_height=360', 'viewport_height=720')
(stage / 'project.godot').write_text(settings)
presets = (stage / 'export_presets.cfg').read_text().replace('developer/*,', '').replace('include_filter="data/*.json"', 'include_filter="data/*.json,developer/*.json"')
presets = presets.replace('application/product_name="Lichterhain"', 'application/product_name="Lichterhain Developer Sandbox"')
(stage / 'export_presets.cfg').write_text(presets)
windows = output / 'Lichterhain_DeveloperSandbox.exe'
linux = output / 'Lichterhain_DeveloperSandbox.x86_64'
base = [str(engine), '--headless', '--audio-driver', 'Dummy', '--path', str(stage)]
commands = [
    ('import', base + ['--editor', '--import', '--quit']),
    ('windows_export', base + ['--export-release', 'Windows Desktop', str(windows)]),
    ('linux_export', base + ['--export-release', 'Linux Desktop', str(linux)]),
    ('linux_sandbox', [sys.executable, str(project / 'tools/verify_sandbox.py'), str(linux)]),
    ('windows_sandbox_pack', [sys.executable, str(project / 'tools/verify_sandbox.py'), str(engine), str(windows)]),
]
results = []
for name, command in commands:
    environment = os.environ.copy()
    environment['LICHTERHAIN_SANDBOX_OUTPUT'] = str(output / name)
    environment['LICHTERHAIN_SANDBOX_EXPORT'] = '1'
    if name == 'linux_sandbox': linux.chmod(linux.stat().st_mode | 0o111)
    try:
        run = subprocess.run(command, env=environment, capture_output=True, text=True, timeout=240)
        text = run.stdout + run.stderr
    except subprocess.TimeoutExpired:
        run = subprocess.CompletedProcess(command, 124)
        text = 'FAIL: export gate timeout'
    (output / (name + '.log')).write_text(text)
    errors = [line for line in text.splitlines() if 'ERROR:' in line or line.startswith('FAIL') or 'leaked' in line]
    if name in ['linux_sandbox', 'windows_sandbox_pack'] and 'SANDBOX ISOLATION PASS' not in text: errors.append('No completion marker')
    passed = run.returncode == 0 and not errors
    results.append({'stage':name,'passed':passed,'exit_code':run.returncode,'errors':errors})
    print(name, 'PASS' if passed else 'FAIL', flush=True)
    if not passed:
        print('\n'.join(errors[:12]), flush=True)
        break
report = {'stages':results,'native_windows_tested':False,'binaries':{p.name:{'size_bytes':p.stat().st_size,'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} for p in [windows,linux] if p.is_file()}}
(output / 'export_results.json').write_text(json.dumps(report,indent=2)+'\n')
sys.exit(0 if len(results)==len(commands) and all(r['passed'] for r in results) else 1)
