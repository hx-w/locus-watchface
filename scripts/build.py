#!/usr/bin/env python3
"""Build native Connect IQ code. Preview fixtures never enter a normal build."""
import argparse
import os
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--device', choices=['fr265', 'fr265s'], default='fr265')
parser.add_argument('--test', action='store_true')
parser.add_argument('--preview', action='store_true', help='Build an isolated simulator demo')
parser.add_argument('--scenario', choices=['normal', 'missing', 'extreme', 'aod', 'loops'], default='normal')
parser.add_argument('--release', action='store_true')
args = parser.parse_args()
if args.preview and args.test:
    parser.error('Choose either preview or tests')
if args.release and (args.preview or args.test):
    parser.error('Release builds cannot contain demo data or tests')
if args.scenario != 'normal' and not args.preview:
    parser.error('--scenario requires --preview')
compiler = shutil.which('monkeyc')
if not compiler:
    raise SystemExit('Install Connect IQ SDK and add its bin directory to PATH')
key = Path(os.environ.get('CIQ_SIGNING_KEY', ROOT/'private/developer_key.der')).expanduser().resolve()
if not key.is_file():
    raise SystemExit('Developer key missing. See docs/DEVELOPMENT.md or set CIQ_SIGNING_KEY.')
build = ROOT/'build'; build.mkdir(exist_ok=True)
jungle = str(ROOT/'monkey.jungle')
suffix = 'tests' if args.test else 'live'
if args.test:
    (build/'tests.jungle').write_text('base.sourcePath = ../source;../tests\nbase.excludeAnnotations = preview\n')
    jungle += ';'+str(build/'tests.jungle')
if args.preview:
    fixture = build/'preview'; fixture.mkdir(exist_ok=True)
    # A simulator retains properties between runs. Demo configuration is isolated
    # along with its data so that older live settings cannot relabel the fixture.
    settings_source = (ROOT/'source/settings/LocusSettings.mc').read_text().replace('(:live)\n', '')
    demo_fields = '[1,8,3,4,5,6]' if args.scenario == 'loops' else '[1,2,3,4,5,6]'
    settings_source = settings_source.replace('function reload() as Void {', 'function readProperties() as Void {')
    settings_source = settings_source.replace('function initialize() { reload(); }',
        'function initialize() { reload(); }\n    function reload() as Void { readProperties(); fields = '+demo_fields+
        '; accent = 0; miles = false; is24 = true; showDate = true; aod = true; }')
    (fixture/'LocusSettings.mc').write_text(settings_source)
    demo = (ROOT/'tests/preview/AthleteData.mc').read_text()
    demo = demo.replace('const SCENARIO = 0;', 'const SCENARIO = '+str(['normal','missing','extreme','aod','loops'].index(args.scenario))+';')
    (fixture/'AthleteData.mc').write_text(demo)
    (build/'preview.jungle').write_text('base.sourcePath = ../source;preview\nbase.excludeAnnotations = live;test\n')
    jungle += ';'+str(build/'preview.jungle')
    suffix = f'demo-{args.scenario}'
out = build/f'locus-{args.device}-{suffix}.prg'
cmd = [compiler,'-f',jungle,'-d',args.device,'-y',str(key),'-o',str(out),'-w','-l','2','--build-stats','0']
if args.test: cmd += ['-t']
if args.release: cmd += ['-r']
subprocess.run(cmd,cwd=build,check=True)
print(out)
