#!/usr/bin/env python3
"""Check the real startup gate, including release packs with assertions disabled."""
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

project = Path(__file__).resolve().parents[1]
engine = str(Path(sys.argv[1]).resolve())
pack = ["--main-pack", str(Path(sys.argv[2]).resolve())] if len(sys.argv) > 2 else []
results = []
with tempfile.TemporaryDirectory(prefix="lichterhain-content-") as temporary:
    for scenario in ["malformed", "reference", "geometry", "cache", "stats", "active_combat"]:
        profile = Path(temporary) / scenario
        env = dict(os.environ, XDG_DATA_HOME=str(profile / "data"), XDG_CONFIG_HOME=str(profile / "config"))
        command = [engine, "--headless", "--audio-driver", "Dummy", "--path", str(project), *pack,
                   "--script", str(project / "tests/content_startup_probe.gd"), "--", scenario]
        process = subprocess.run(command, env=env, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=40)
        print(process.stdout, end="")
        marker = re.search(r"CONTENT STARTUP RESULT (\d+)/(\d+) " + scenario, process.stdout)
        # An expected push_error reports the bad document. Script/parser/engine errors are never acceptable.
        errors = [line for line in process.stdout.splitlines() if "SCRIPT ERROR" in line or line.startswith("FAIL") or
                  ("ERROR:" in line and not line.startswith("ERROR: res://data/") and not line.startswith("ERROR: data/"))]
        ok = process.returncode == 0 and marker and marker[1] == marker[2] and not errors
        results.append({"case":scenario,"passed":bool(ok),"checks":int(marker[2]) if marker else 0,"exit_code":process.returncode})
print("CONTENT STARTUP SUMMARY " + json.dumps(results))
sys.exit(0 if all(row["passed"] for row in results) else 1)
