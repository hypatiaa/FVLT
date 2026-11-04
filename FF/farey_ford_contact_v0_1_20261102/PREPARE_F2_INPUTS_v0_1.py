"""FF-1 metadata/API intake only: no proof elaboration or feasibility tests."""
import hashlib
import json
import os
from pathlib import Path
import stat
import subprocess
import time

BASE = Path(__file__).resolve().parent
LIB = Path('/home/saphir/rule30_theorem_library/v19')
EXPECTED = {
    'SHA256SUMS': 'e25d4d54d074f152c452aa7247ccbe992e14b29d58306809660a75770ae7ddd5',
    'LIBRARY_MANIFEST.json': 'f0ee6b00fe4a622b63cac1f4fb24146e9b2808bdb0fb430ebdac074fecb258fa',
    'lake-manifest.json': '1f0e0c1c0a06e2a9ecc117aed82f7a8ee62b418235e10686d3bda2d6986ea527',
    'lakefile.toml': '4f0aea1336d288cba45c00727ce81c2cc064c39fca46e8ccf4505ae38ca6191f',
    'lean-toolchain': 'ca5f1f601d34c49079e38d7e7041eb0f2a9c227fbc1df0f404820069a052330c',
}

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def run(args, cwd=LIB):
    p = subprocess.run(args, cwd=cwd, capture_output=True, text=True, timeout=60)
    return {'argv': args, 'exit_code': p.returncode, 'stdout': p.stdout, 'stderr': p.stderr}

observed = {name: sha(LIB / name) for name in EXPECTED}
checksum = run(['sha256sum', '-c', 'SHA256SUMS'])
(BASE / 'F2_LIBRARY_SHA256_CHECK_v0_1.txt').write_text(checksum['stdout'] + checksum['stderr'])
writable, symlinks, scanned = [], [], 0
for root, dirs, files in os.walk(LIB, followlinks=False):
    for name in dirs + files:
        path = Path(root) / name
        if path.is_symlink():
            symlinks.append({'path': str(path.relative_to(LIB)), 'target': str(path.resolve())})
            continue
        scanned += 1
        if path.stat().st_mode & (stat.S_IWUSR | stat.S_IWGRP | stat.S_IWOTH):
            writable.append(str(path.relative_to(LIB)))
checker_hash = sha(BASE / 'IndependentFVLTReplay435.lean')
manifest = json.loads((LIB / 'LIBRARY_MANIFEST.json').read_text())
receipt = {
    'purpose': 'metadata and source API inspection only; no Lean proof elaboration',
    'utc': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()),
    'transport': 'SSH explicit Tailscale HostName=100.105.106.41, HostKeyAlias=192.168.0.177',
    'host': run(['hostname']),
    'available_versions': sorted(p.name for p in LIB.parent.iterdir() if p.is_dir() and p.name.startswith('v') and p.name[1:].isdigit()),
    'library': str(LIB), 'expected': EXPECTED, 'observed': observed,
    'all_top_level_pins_match': observed == EXPECTED,
    'expected_value_provenance': {
        'SHA256SUMS': 'reviewed v0.3 order',
        'LIBRARY_MANIFEST.json': 'v19 release readiness relayed earlier; live observation independently matched',
        'lake-manifest.json': 'previous verified shared toolchain pin; live v19 observation matched',
        'lakefile.toml': 'initial authorized v19 inspection; proposed expected pin requiring this freeze review',
        'lean-toolchain': 'previous verified shared toolchain pin; live v19 observation matched',
    },
    'checksum_exit_code': checksum['exit_code'],
    'checksum_log': 'F2_LIBRARY_SHA256_CHECK_v0_1.txt',
    'checksum_log_sha256': sha(BASE / 'F2_LIBRARY_SHA256_CHECK_v0_1.txt'),
    'listed_check_ok_lines': sum(line.endswith(': OK') for line in checksum['stdout'].splitlines()),
    'read_only': {'scanned_non_symlink_entries': scanned, 'write_mode_entries': writable, 'symlinks_not_followed': symlinks, 'root_mode': oct(LIB.stat().st_mode & 0o777)},
    'checker': {'expected': '9c6f2ac11b50fdb846df2d5099ea673553903275a5dba11fce5a5673cae14bd0', 'observed': checker_hash},
    'compiler': run(['/home/saphir/.elan/bin/lake', 'env', 'lean', '--version']),
    'mathlib_commit': run(['git', '-C', str(LIB / '.lake/packages/mathlib'), 'rev-parse', 'HEAD']),
    'memory': run(['free', '-m']), 'load': run(['uptime']),
    'processes': run(['ps', '-eo', 'pid,comm,pcpu,pmem', '--sort=-pcpu']),
    'manifest_version': manifest.get('version'),
    'status': 'F2_REOBSERVATION_UNDER_ACCEPTED_TEMPLATE',
}
(BASE / 'F2_INPUT_OBSERVATIONS_v0_1.json').write_text(json.dumps(receipt, indent=2) + '\n')
print(json.dumps({k: receipt[k] for k in ['utc', 'library', 'all_top_level_pins_match', 'checksum_exit_code', 'listed_check_ok_lines', 'read_only', 'checker', 'compiler', 'mathlib_commit', 'manifest_version']}, indent=2))
if not receipt['all_top_level_pins_match'] or checksum['exit_code'] or writable or checker_hash != receipt['checker']['expected']:
    raise SystemExit(1)
