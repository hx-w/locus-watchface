#!/usr/bin/env python3
"""Run real Monkey C tests serially; the SDK can return 1 for successful tests."""
import argparse
import json
import re
import subprocess
import sys
from pathlib import Path
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
devices = [p.attrib['id'] for p in ET.parse(ROOT/'manifest.xml').findall('.//{*}product')]
parser.add_argument('--device', choices=devices+['all'], default='all')
args = parser.parse_args()
reports = []
for device in (devices if args.device == 'all' else [args.device]):
    build = subprocess.run([sys.executable,str(ROOT/'scripts/build.py'),'--device',device,'--test'],cwd=ROOT,capture_output=True,text=True)
    (ROOT/'build'/f'{device}-test-build.log').write_text(build.stdout+build.stderr)
    if build.returncode:
        print(build.stdout+build.stderr); raise SystemExit(build.returncode)
    if 'WARNING:' in build.stdout+build.stderr:
        raise SystemExit('Compiler warnings require review: '+device)
    test = subprocess.run(['monkeydo',str(ROOT/'build'/f'locus-{device}-tests.prg'),device,'-t'],cwd=ROOT,capture_output=True,text=True,timeout=60)
    log = test.stdout+test.stderr
    (ROOT/'build'/f'{device}-tests.log').write_text(log)
    match = re.search(r'PASSED \(passed=(\d+), failed=0, errors=0\)',log)
    if not match or test.returncode not in [0,1]:
        print(log); raise SystemExit('Native test failure: '+device)
    reports.append({'device':device,'passed':int(match.group(1)),'failed':0,'errors':0,'sdk_exit_code':test.returncode})
    print(log)
(ROOT/'build'/'test-results.json').write_text(json.dumps(reports,indent=2))
print(json.dumps(reports,indent=2))
