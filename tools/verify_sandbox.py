#!/usr/bin/env python3
"""Run sandbox checks in a disposable profile with production save sentinels."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile

project = Path(__file__).resolve().parents[1]
engine = Path(sys.argv[1]).resolve()
output = Path(os.environ.get('LICHTERHAIN_SANDBOX_OUTPUT', str(project / 'test-output')))
output.mkdir(parents=True, exist_ok=True)
with tempfile.TemporaryDirectory(prefix='lichterhain-sandbox-') as temporary:
    temporary = Path(temporary)
    environment = os.environ.copy()
    environment.update(XDG_DATA_HOME=str(temporary / 'data'), XDG_CONFIG_HOME=str(temporary / 'config'),
                       APPDATA=str(temporary / 'appdata'), LICHTERHAIN_SANDBOX_TEST_ISOLATED='1',
                       LICHTERHAIN_SANDBOX_RESULT=str(output / 'sandbox_results.json'))
    roots = [temporary / 'data/godot/app_userdata/Lichterhain', temporary / 'appdata/Godot/app_userdata/Lichterhain']
    sentinels = {}
    for root in roots:
        root.mkdir(parents=True)
        for suffix in ['', '.bak', '.pre-v03', '.pre-v04']:
            path = root / ('lichtpfad_v1.json' + suffix)
            path.write_bytes((project / 'tests/fixtures/v04_restored_equipped.json').read_bytes())
            sentinels[str(path)] = hashlib.sha256(path.read_bytes()).hexdigest()
    command = [str(engine), '--headless', '--audio-driver', 'Dummy', '--path', str(project), '--script', str(project / 'tests/sandbox_suite.gd')]
    if len(sys.argv) > 2: command[1:1] = ['--main-pack', str(Path(sys.argv[2]).resolve())]
    try:
        run = subprocess.run(command, env=environment, capture_output=True, text=True, timeout=120)
        text = run.stdout + run.stderr
    except subprocess.TimeoutExpired as exc:
        text = (exc.stdout or b'').decode(errors='replace') if isinstance(exc.stdout, bytes) else (exc.stdout or '')
        text += '\nFAIL: sandbox timeout\n'
        run = subprocess.CompletedProcess(command,124)
    (output / 'sandbox_suite.log').write_text(text)
    errors = [line for line in text.splitlines() if 'ERROR:' in line or line.startswith('FAIL') or 'leaked' in line]
    untouched = all(Path(path).is_file() and hashlib.sha256(Path(path).read_bytes()).hexdigest() == digest for path, digest in sentinels.items())
    no_new_saves = all(sorted(p.name for p in root.glob('lichtpfad*')) == ['lichtpfad_v1.json', 'lichtpfad_v1.json.bak', 'lichtpfad_v1.json.pre-v03', 'lichtpfad_v1.json.pre-v04'] for root in roots)
    success = run.returncode == 0 and 'SANDBOX RESULT ' in text and not errors and untouched and no_new_saves
    (output / 'sandbox_isolation.json').write_text(json.dumps({'passed':success,'production_sentinels_unchanged':untouched,'no_new_production_saves':no_new_saves,'exit_code':run.returncode,'errors':errors},indent=2)+'\n')
    print(text, end='')
    print('SANDBOX ISOLATION PASS' if success else 'FAIL SANDBOX ISOLATION')
    sys.exit(0 if success else 1)
