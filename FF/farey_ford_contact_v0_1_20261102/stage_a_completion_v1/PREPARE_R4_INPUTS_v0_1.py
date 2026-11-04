"""Metadata-only nucleus preflight; no theorem or proof compilation."""
from pathlib import Path
import datetime
import hashlib
import json
import os
import socket
import subprocess

BASE = Path(__file__).resolve().parent
PARENT = BASE.parent
def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()
def run(args, cwd):
    p = subprocess.run(args, cwd=cwd, text=True, capture_output=True, timeout=60)
    return dict(argv=args, exit=p.returncode, stdout=p.stdout, stderr=p.stderr)

assert socket.gethostname() == 'nucleus'
assert '100.105.106.41' in os.environ.get('SSH_CONNECTION', '')
assert sha(BASE/'R4_JOB_TEMPLATE_v0_1.json') == '6f59c2e5ca54f7591f53c20c1b4b53ea61719edaee06d54d27ac3460c41528fb'
assert sha(BASE/'R4_TEMPLATE_DECISION_v0_1.md') == 'f53647f25f5439c46eb2f028cf04796de8c972e9d6400e86fec3fc3b3795bf17'
t = json.loads((BASE/'R4_JOB_TEMPLATE_v0_1.json').read_text())
lib = Path(t['library'])
versions = sorted(int(p.name[1:]) for p in lib.parent.iterdir()
                  if p.is_dir() and p.name.startswith('v') and p.name[1:].isdigit())
check = run(['sha256sum','-c','SHA256SUMS'],lib)
checklog = BASE/'R4_LIBRARY_SHA256_CHECK_v0_1.txt'
checklog.write_text(check['stdout']+check['stderr'])
writable, symlinks, count = [], [], 0
for root, dirs, files in os.walk(lib, followlinks=False):
    for name in dirs+files:
        p=Path(root)/name
        if p.is_symlink():
            symlinks.append(dict(path=str(p),target=str(p.resolve())))
            continue
        count+=1
        if p.stat().st_mode & 0o222:
            writable.append(str(p))
observed={n:sha(lib/n) for n in t['library_expected']}
predecessors={n:sha(PARENT/n) for n in t['predecessor_pins']}
gates={n:sha(PARENT/n) for n in t['manager_pass_records']}
compiler=run([t['lean_executable'],'--version'],lib)
mathlib=run(['git','-C',str(lib/'.lake/packages/mathlib'),'rev-parse','HEAD'],lib)
receipt=dict(utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
    transport=os.environ['SSH_CONNECTION'], latest_version='v'+str(versions[-1]),
    library=str(lib),expected=t['library_expected'],observed=observed,
    predecessor_expected=t['predecessor_pins'],predecessor_observed=predecessors,
    gate_expected=t['manager_pass_records'],gate_observed=gates,
    checksum_exit=check['exit'], checksum_ok_entries=sum(x.endswith(': OK') for x in check['stdout'].splitlines()),
    checksum_log_sha256=sha(checklog),
    read_only=dict(entries_scanned=count,writable=writable,symlinks_skipped=symlinks),
    compiler=compiler,mathlib_head=mathlib,
    lean_executable_sha256=sha(Path(t['lean_executable'])),
    checker_sha256=sha(BASE/'IndependentFVLTReplay435.lean'),
    runner_sha256=sha(BASE/t['runner']),capacity=run(['free','-m'],lib),
    load=run(['uptime'],lib),processes=run(['ps','-eo','pid,comm,pcpu,pmem','--sort=-pcpu'],lib),
    mathematical_checks=0,proof_compilations=0)
checks=[versions[-1]==19, observed==t['library_expected'],predecessors==t['predecessor_pins'],
    gates==t['manager_pass_records'],check['exit']==0,not writable,
    compiler['exit']==0,'4.35.0' in compiler['stdout'],
    'eb6cafb7290e8bd5f2937522d8d804f58f02bafc' in compiler['stdout'],
    mathlib['exit']==0,mathlib['stdout'].strip()==t['mathlib_commit'],
    receipt['lean_executable_sha256']==t['lean_executable_sha256'],
    receipt['checker_sha256']==t['checker_sha256'],receipt['runner_sha256']==t['runner_sha256']]
receipt['all_expected_equal']=all(checks)
(BASE/'R4_INPUT_OBSERVATIONS_v0_1.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps({k:receipt[k] for k in ['utc','latest_version','all_expected_equal','checksum_exit','checksum_ok_entries','mathematical_checks','proof_compilations']}))
assert all(checks), 'Mismatch: return to manager before proof work'
