#!/usr/bin/env python3
"""Real post-open write/flush failure in an isolated Linux child, after import."""
import os
from pathlib import Path
import signal
import shutil
import subprocess
import sys
import tempfile


def main():
    if sys.platform != 'linux':
        print('SKIP: real RLIMIT_FSIZE write probe requires Linux')
        return 77
    import resource
    project = Path(__file__).resolve().parents[1]
    engine = Path(shutil.which(sys.argv[1]) or sys.argv[1]).resolve()
    with tempfile.TemporaryDirectory(prefix='lichterhain-m01-write-') as temp:
        env = os.environ.copy()
        env['XDG_DATA_HOME'] = str(Path(temp) / 'data')
        env['XDG_CONFIG_HOME'] = str(Path(temp) / 'config')
        env['GODOT_SILENCE_ROOT_WARNING'] = '1'
        user = Path(env['XDG_DATA_HOME']) / 'godot/app_userdata/Lichterhain'
        user.mkdir(parents=True)
        save = user / 'm01_limited_write_only.json'
        save.write_text('{ damaged primary')
        save.with_suffix('.json.bak').write_bytes(
            (project / 'tests/fixtures/v04_restored_equipped.json').read_bytes())

        def limit_child():
            signal.signal(signal.SIGXFSZ, signal.SIG_IGN)
            resource.setrlimit(resource.RLIMIT_FSIZE, (64, 64))

        result = subprocess.run(
            [str(engine), '--headless', '--audio-driver', 'Dummy', '--path', str(project),
             '--script', 'res://tests/save_write_limit_probe.gd'],
            env=env, preexec_fn=limit_child, stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT, text=True, timeout=30)
        print(result.stdout, end='')
        return result.returncode if result.returncode else (
            0 if 'REAL WRITE ERROR PASS' in result.stdout and 'ERROR:' not in result.stdout else 1)


if __name__ == '__main__':
    raise SystemExit(main())
