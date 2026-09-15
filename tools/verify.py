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
for script in ['test_suite', 'ui_smoke', 'save_compatibility', 'dungeon_suite', 'migration_suite', 'source_suite']:
    stages.append((script, ['--script', f'res://tests/{script}.gd']))
results = []
for name, args in stages:
    run = subprocess.run([str(engine), '--headless', '--audio-driver', 'Dummy', '--path', str(project), *args],
                         stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=120)
    (output / f'{name}.log').write_text(run.stdout)
    errors = [line for line in run.stdout.splitlines() if 'ERROR:' in line or line.startswith('FAIL')]
    result = {'stage': name, 'passed': run.returncode == 0 and not errors, 'exit_code': run.returncode}
    results.append(result)
    print(name, 'PASS' if result['passed'] else 'FAIL', flush=True)
    if not result['passed']:
        print('\n'.join(errors[:20]), flush=True)
        break
(output / 'verification.json').write_text(json.dumps(results, indent=2) + '\n')
sys.exit(0 if len(results) == len(stages) and all(r['passed'] for r in results) else 1)
