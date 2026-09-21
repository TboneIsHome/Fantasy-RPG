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
               'state_replay_reproduction', 'state_actions_suite', 'state_actions_scene',
               'region_replay_reproduction', 'region_lifecycle_suite',
               'content_validation_suite', 'data_consistency_suite',
               'interaction_contract_suite', 'interaction_scene_suite']:
    stages.append((script, ['--script', f'res://tests/{script}.gd']))
stages.append(('content_startup', []))
if sys.platform == 'linux':
    stages.append(('real_write_error', []))
else:
    print('NOT TESTED: Linux-only real RLIMIT_FSIZE write probe; portable fault suite still runs.', flush=True)
results = []
for name, args in stages:
    if name == 'content_startup':
        command = [sys.executable, str(project / 'tools/verify_content_startup.py'), str(engine)]
    else:
        command = ([sys.executable, str(project / 'tools/reproduce_save_write_error.py'), str(engine)]
               if name == 'real_write_error' else
               [str(engine), '--headless', '--audio-driver', 'Dummy', '--path', str(project), *args])
    try:
        run = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=120)
    except subprocess.TimeoutExpired as error:
        partial = error.stdout or b''
        if isinstance(partial, bytes): partial = partial.decode('utf-8', errors='replace')
        run = subprocess.CompletedProcess(command, 124, partial + '\nFAIL: Stage timed out after 120 seconds.\n')
    (output / f'{name}.log').write_text(run.stdout)
    errors = [line for line in run.stdout.splitlines() if 'ERROR:' in line or line.startswith('FAIL')]
    if name == 'content_startup':
        errors = [line for line in errors if not line.startswith(('ERROR: data/', 'ERROR: res://data/'))]
        if 'CONTENT STARTUP SUMMARY ' not in run.stdout: errors.append('Missing content startup completion')
    for suite, marker in [('content_validation_suite', 'CONTENT VALIDATION RESULT '), ('data_consistency_suite', 'DATA CONSISTENCY RESULT ')]:
        if name == suite and marker not in run.stdout: errors.append('Missing M04 completion marker')
    for suite, marker in [('interaction_contract_suite', 'INTERACTION CONTRACT RESULT '), ('interaction_scene_suite', 'INTERACTION SCENE RESULT ')]:
        if name == suite and marker not in run.stdout: errors.append('Missing M05 completion marker')
    if name == 'save_scene_smoke' and 'SAVE SCENE RESULT ' not in run.stdout:
        errors.append('Missing completion marker: save/close may have ended the test early.')
    if name == 'state_actions_scene' and 'STATE SCENE RESULT ' not in run.stdout:
        errors.append('Missing completion marker for state action scene.')
    if name in ('region_replay_reproduction', 'region_lifecycle_suite'):
        marker = 'REGION REPLAY RESULT ' if name == 'region_replay_reproduction' else 'REGION LIFECYCLE RESULT '
        if marker not in run.stdout:
            errors.append('Missing completion marker for region lifecycle tests.')
    result = {'stage': name, 'passed': run.returncode == 0 and not errors, 'exit_code': run.returncode}
    results.append(result)
    print(name, 'PASS' if result['passed'] else 'FAIL', flush=True)
    if not result['passed']:
        print('\n'.join(errors[:20]), flush=True)
        break
(output / 'verification.json').write_text(json.dumps(results, indent=2) + '\n')
sys.exit(0 if len(results) == len(stages) and all(r['passed'] for r in results) else 1)
