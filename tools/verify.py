#!/usr/bin/env python3
"""Repeatable local gate; also catches Godot script errors that exit with code 0."""
import json
from pathlib import Path
import subprocess
import sys

project = Path(__file__).resolve().parents[1]
engine = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else 'godot'
output = project / 'test-output'
output.mkdir(exist_ok=True)
stages = [('import', ['--editor', '--import', '--quit'])]
for script in ['test_suite', 'ui_smoke', 'save_compatibility', 'dungeon_suite', 'migration_suite', 'source_suite',
               'save_io_reproduction', 'save_fault_suite', 'save_scene_smoke',
               'state_replay_reproduction', 'state_actions_suite', 'state_actions_scene']:
    stages.append((script, ['--script', f'res://tests/{script}.gd']))
if sys.platform == 'linux':
    stages.append(('real_write_error', []))
else:
    print('NOT TESTED: Linux-only real RLIMIT_FSIZE write probe; portable fault suite still runs.', flush=True)
results = []
for name, args in stages:
    command = ([sys.executable, str(project / 'tools/reproduce_save_write_error.py'), str(engine)]
               if name == 'real_write_error' else
               [str(engine), '--headless', '--audio-driver', 'Dummy', '--path', str(project), *args])
    run = subprocess.run(command,
                         stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=120)
    (output / f'{name}.log').write_text(run.stdout)
    errors = [line for line in run.stdout.splitlines() if 'ERROR:' in line or line.startswith('FAIL')]
    if name == 'save_scene_smoke' and 'SAVE SCENE RESULT ' not in run.stdout:
        errors.append('Missing completion marker: save/close may have ended the test early.')
    if name == 'state_actions_scene' and 'STATE SCENE RESULT ' not in run.stdout:
        errors.append('Missing completion marker for state action scene.')
    result = {'stage': name, 'passed': run.returncode == 0 and not errors, 'exit_code': run.returncode}
    results.append(result)
    print(name, 'PASS' if result['passed'] else 'FAIL', flush=True)
    if not result['passed']:
        print('\n'.join(errors[:20]), flush=True)
        break
(output / 'verification.json').write_text(json.dumps(results, indent=2) + '\n')
sys.exit(0 if len(results) == len(stages) and all(r['passed'] for r in results) else 1)
