"""Prospective computable Ford bridge runner, NOT EXECUTED at paperwork stage.

Derived from accepted RUN_FF2_v0_1.py; explicit final receipt acceptance required.
Invocation: python3 RUN_BRIDGE_v0_1.py JOB.json
The executable smoke driver is finite evidence, never a theorem/replay target.
"""
from pathlib import Path
import hashlib
import json
import os
import resource
import signal
import socket
import subprocess
import sys
import time

PARENT = Path('/home/saphir/fvlt_formalization_20261028/ff1_v03_20261103')
ROOT = PARENT / 'computable_bridge_v1'
LIB = Path('/home/saphir/rule30_theorem_library/v19')
LEAN = Path('/home/saphir/.elan/toolchains/leanprover--lean4---v4.35.0/bin/lean')
CHECKER = ROOT / 'IndependentFVLTReplay435.lean'
PRODUCER = 'FVLTFordRationalV1'
PROOFS = 'FVLTFordExactCoordinatesV1'
SMOKE = 'FVLTFordRationalSmokeV1'
F1_PINS = {
    'FVLTFareyContactV1.lean': '2760392f984bd1375169920a702ae53c13115ddfb36d71bae36b3855950d1e4b',
    'FVLTFordGeometryV1.lean': '0b380fd6cf1319317edbc9bbd5c56ed6f913bfbb7ac45104877b0f754b7e6db8',
    'FVLTFareyContactV1.olean': '202d39c1c940eef0a6cd23ea422e251df2d9e111255bbc460cb14650c8f042e8',
    'FVLTFordGeometryV1.olean': 'ea5dc4ce259c44b6e742ce950dcea3333d83d031511595ac951b68b0570cab54',
}

def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

assert socket.gethostname() == 'nucleus'
assert '100.105.106.41' in os.environ.get('SSH_CONNECTION', '')
assert len(sys.argv) == 2
job_path = Path(sys.argv[1]).resolve()
assert job_path.parent == ROOT
job = json.loads(job_path.read_text())
review = json.loads((ROOT / 'REVIEW_ACCEPTANCE.json').read_text())
assert review['input_review_reference'] and review['signature_review_reference']
assert review['final_template_review_reference']
assert review['runner_sha256'] == sha(Path(__file__))
assert review['F2_outcome_recorded'] is True
outcome_name = review['F2_outcome_record_file']
assert Path(outcome_name).name == outcome_name
assert sha(PARENT / outcome_name) == review['F2_outcome_record_sha256']
for filename, digest in review['reviewed_files'].items():
    path = ROOT / filename
    assert path.resolve().parent == ROOT and sha(path) == digest
assert sha(job_path) in review['accepted_job_manifest_sha256']
assert job['phase'] == 'BRIDGE'
assert job['lean_executable_sha256'] == sha(LEAN)
assert job['mode'] in ('compile', 'replay', 'execute')
assert job['module'] in (PRODUCER, PROOFS, SMOKE)
assert job['module'] + '.lean' in job['source_sha256']
if job['mode'] == 'replay':
    assert job['module'] in (PRODUCER, PROOFS)
    assert job['module'] + '.olean' in job.get('dependency_olean_sha256', {})
if job['mode'] == 'execute':
    assert job['module'] == SMOKE
    assert job['finite_evidence_only'] is True
    assert PRODUCER + '.olean' in job.get('dependency_olean_sha256', {})
if job['module'] == SMOKE:
    assert job['mode'] == 'execute'

deadline = json.loads((ROOT / 'BRIDGE_DEADLINE.json').read_text())
remaining = deadline['deadline_unix'] - time.time()
assert 0 < remaining
wall = min(240, remaining)
for filename, digest in job['source_sha256'].items():
    path = ROOT / filename
    assert path.resolve().parent == ROOT and sha(path) == digest
for filename, digest in review['library_expected'].items():
    assert sha(LIB / filename) == digest
for line in (LIB / 'SHA256SUMS').read_text().splitlines():
    digest, name = line.split(maxsplit=1)
    path = LIB / name.lstrip('*')
    assert sha(path) == digest and path.stat().st_mode & 0o222 == 0
for filename, digest in F1_PINS.items():
    assert sha(PARENT / filename) == digest
for filename, digest in job.get('dependency_olean_sha256', {}).items():
    path = ROOT / filename
    assert path.resolve().parent == ROOT and sha(path) == digest
assert sha(PARENT / 'F1_AUDIT_AND_BRIDGE_DECISION_v0_1.md') == \
    'd5470d9b2353ca9de7309064dad363955e567a356fb5075dae04c0f9f32c7526'
assert sha(CHECKER) == '9c6f2ac11b50fdb846df2d5099ea673553903275a5dba11fce5a5673cae14bd0'

run_id = job['run_id']
assert run_id.replace('_', '').isalnum()
log = ROOT / (run_id + '.log')
receipt = ROOT / (run_id + '.json')
assert not log.exists() and not receipt.exists()
lock = ROOT / 'RUNNING.lock'
lock_fd = os.open(lock, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
os.write(lock_fd, str(os.getpid()).encode())
os.close(lock_fd)
cpu = min(os.sched_getaffinity(0))
os.sched_setaffinity(0, {cpu})
os.nice(19)
paths = [ROOT, PARENT, LIB / '.lake/build/lib/lean']
paths += sorted((LIB / '.lake/packages').glob('*/.lake/build/lib/lean'))
env = dict(os.environ, LEAN_PATH=':'.join(map(str, paths)), LEAN_NUM_THREADS='1',
           MALLOC_ARENA_MAX='2', PATH=str(LEAN.parent) + ':' + os.environ.get('PATH', ''))
cmd = [str(LEAN), '-j1', '-s65536', '-M7680', '-D', 'Elab.async=false']
if job['mode'] == 'compile':
    cmd += ['-o', str(ROOT / (job['module'] + '.olean')), str(ROOT / (job['module'] + '.lean'))]
elif job['mode'] == 'replay':
    cmd += ['--run', str(CHECKER), job['module']]
else:
    cmd += ['--run', str(ROOT / (SMOKE + '.lean'))]

def limits():
    resource.setrlimit(resource.RLIMIT_AS, (8 * 1024**3, 8 * 1024**3))
    resource.setrlimit(resource.RLIMIT_NPROC, (256, 256))
    resource.setrlimit(resource.RLIMIT_FSIZE, (64 * 1024**2, 64 * 1024**2))
    resource.setrlimit(resource.RLIMIT_CORE, (0, 0))

started = time.time()
record = dict(job=job, runner_sha256=sha(Path(__file__)), command=cmd,
              wall_cap_seconds=wall, address_space_bytes=8 * 1024**3,
              process_limit=256, output_file_limit_bytes=64 * 1024**2,
              cpu_affinity=[cpu], nice=19, started_unix=started,
              library=str(LIB), transport=os.environ['SSH_CONNECTION'],
              lean_executable_sha256=sha(LEAN), LEAN_PATH=env['LEAN_PATH'],
              F1_dependency_pins=F1_PINS,
              F2_outcome_record_sha256=review['F2_outcome_record_sha256'],
              finite_evidence_only=(job['mode'] == 'execute'))
receipt.write_text(json.dumps(record, indent=2))
try:
    with log.open('xb') as out:
        p = subprocess.Popen(cmd, cwd=ROOT, env=env, stdout=out, stderr=subprocess.STDOUT,
                             start_new_session=True, preexec_fn=limits)
        timed_out = False
        try:
            code = p.wait(timeout=wall)
        except subprocess.TimeoutExpired:
            timed_out = True
            os.killpg(p.pid, signal.SIGKILL)
            code = p.wait()
    record.update(exit_code=code, timeout=timed_out, seconds=time.time()-started,
                  log_sha256=sha(log), log_bytes=log.stat().st_size,
                  peak_child_rss_kib=resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss)
    record['source_unchanged'] = all(sha(ROOT / n) == d for n, d in job['source_sha256'].items())
    record['F1_dependencies_unchanged'] = all(sha(PARENT / n) == d for n, d in F1_PINS.items())
    check = subprocess.run(['sha256sum', '-c', 'SHA256SUMS'], cwd=LIB,
                           stdout=subprocess.PIPE, stderr=subprocess.STDOUT, timeout=60)
    (ROOT / (run_id + '.library_after.txt')).write_bytes(check.stdout)
    record['library_checksum_after_exit'] = check.returncode
    if job['mode'] == 'compile' and code == 0:
        record['olean_sha256'] = sha(ROOT / (job['module'] + '.olean'))
    receipt.write_text(json.dumps(record, indent=2))
    print(json.dumps(record))
    assert code == 0 and not timed_out and record['source_unchanged']
    assert record['F1_dependencies_unchanged'] and check.returncode == 0
finally:
    lock.unlink()
