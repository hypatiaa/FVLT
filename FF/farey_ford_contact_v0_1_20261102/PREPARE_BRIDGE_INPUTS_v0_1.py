"""Fresh metadata-only bridge binding: no proof, build or smoke execution."""
from pathlib import Path
import datetime
import hashlib
import json
import os
import subprocess

BASE = Path(__file__).resolve().parent
PARENT = BASE.parent
LIB = Path('/home/saphir/rule30_theorem_library/v19')
EXPECTED = {
 'SHA256SUMS': 'e25d4d54d074f152c452aa7247ccbe992e14b29d58306809660a75770ae7ddd5',
 'LIBRARY_MANIFEST.json': 'f0ee6b00fe4a622b63cac1f4fb24146e9b2808bdb0fb430ebdac074fecb258fa',
 'lake-manifest.json': '1f0e0c1c0a06e2a9ecc117aed82f7a8ee62b418235e10686d3bda2d6986ea527',
 'lakefile.toml': '4f0aea1336d288cba45c00727ce81c2cc064c39fca46e8ccf4505ae38ca6191f',
 'lean-toolchain': 'ca5f1f601d34c49079e38d7e7041eb0f2a9c227fbc1df0f404820069a052330c',
}
F1 = {
 'FVLTFareyContactV1.lean': '2760392f984bd1375169920a702ae53c13115ddfb36d71bae36b3855950d1e4b',
 'FVLTFordGeometryV1.lean': '0b380fd6cf1319317edbc9bbd5c56ed6f913bfbb7ac45104877b0f754b7e6db8',
 'FVLTFareyContactV1.olean': '202d39c1c940eef0a6cd23ea422e251df2d9e111255bbc460cb14650c8f042e8',
 'FVLTFordGeometryV1.olean': 'ea5dc4ce259c44b6e742ce950dcea3333d83d031511595ac951b68b0570cab54',
}
def sha(p):
 return hashlib.sha256(p.read_bytes()).hexdigest()
def run(args, cwd=LIB):
 p = subprocess.run(args, cwd=cwd, text=True, capture_output=True, timeout=60)
 return {'argv': args, 'exit': p.returncode, 'stdout': p.stdout, 'stderr': p.stderr}

versions = sorted((int(p.name[1:]), p.name) for p in LIB.parent.iterdir()
                  if p.is_dir() and p.name.startswith('v') and p.name[1:].isdigit())
checks = run(['sha256sum', '-c', 'SHA256SUMS'])
(BASE / 'BRIDGE_LIBRARY_SHA256_CHECK_v0_1.txt').write_text(checks['stdout'] + checks['stderr'])
writable, symlinks, count = [], [], 0
for root, dirs, files in os.walk(LIB, followlinks=False):
 for name in dirs + files:
  path = Path(root) / name
  if path.is_symlink():
   symlinks.append({'path': str(path), 'target': str(path.resolve())})
   continue
  count += 1
  if path.stat().st_mode & 0o222:
   writable.append(str(path))
observed = {n: sha(LIB / n) for n in EXPECTED}
f1observed = {n: sha(PARENT / n) for n in F1}
outcome = PARENT / 'F2_AUDIT_AND_BRIDGE_RUNNER_DECISION_v0_1.md'
lean = Path('/home/saphir/.elan/toolchains/leanprover--lean4---v4.35.0/bin/lean')
receipt = {
 'status': 'FRESH_BRIDGE_INPUT_BINDINGS_AWAITING_FINAL_REVIEW',
 'utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
 'ssh_connection': os.environ.get('SSH_CONNECTION'),
 'latest_version': versions[-1][1], 'library': str(LIB),
 'expected': EXPECTED, 'observed': observed,
 'checksum_exit': checks['exit'], 'checksum_ok_entries': sum(x.endswith(': OK') for x in checks['stdout'].splitlines()),
 'checksum_log_sha256': sha(BASE / 'BRIDGE_LIBRARY_SHA256_CHECK_v0_1.txt'),
 'read_only': {'entries_scanned': count, 'writable': writable, 'symlinks_skipped': symlinks},
 'F1_expected': F1, 'F1_observed': f1observed,
 'F2_outcome': {'file': outcome.name, 'expected': '95532c2c4101197646a7a310120c9ec766282a1b41537557f585591d0d4968e1', 'observed': sha(outcome)},
 'lean_executable_sha256': sha(lean),
 'compiler': run([str(lean), '--version']),
 'mathlib_head': run(['git', '-C', str(LIB / '.lake/packages/mathlib'), 'rev-parse', 'HEAD']),
 'checker_sha256': sha(BASE / 'IndependentFVLTReplay435.lean'),
 'capacity': run(['free','-m']), 'load': run(['uptime']),
 'processes': run(['ps','-eo','pid,comm,pcpu,pmem','--sort=-pcpu']),
 'bridge_builds': 0, 'mathematical_checks': 0,
}
(BASE / 'BRIDGE_INPUT_OBSERVATIONS_v0_1.json').write_text(json.dumps(receipt, indent=2)+'\n')
assert versions[-1][1] == 'v19'
assert observed == EXPECTED and not writable and checks['exit'] == 0
assert f1observed == F1
assert receipt['F2_outcome']['expected'] == receipt['F2_outcome']['observed']
assert receipt['lean_executable_sha256'] == 'bf8d54e4714cc4b03d3f6bb34c83b7202b87e49c8bfcbff6895c085bb90ceb38'
assert receipt['checker_sha256'] == '9c6f2ac11b50fdb846df2d5099ea673553903275a5dba11fce5a5673cae14bd0'
assert receipt['mathlib_head']['stdout'].strip() == '56a005855ea17e0b0958f73ec801ae140b0a1679'
print(json.dumps({k:receipt[k] for k in ['status','utc','latest_version','checksum_exit','checksum_ok_entries','F2_outcome','bridge_builds','mathematical_checks']},indent=2))
