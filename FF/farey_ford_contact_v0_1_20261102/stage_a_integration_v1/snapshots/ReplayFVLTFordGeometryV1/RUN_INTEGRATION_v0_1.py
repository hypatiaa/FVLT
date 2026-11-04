"""Prospective source-rebuild integration runner. NOT EXECUTED during review preparation.

Invocation: python3 RUN_INTEGRATION_v0_1.py JOB.json
Requires a recorded R5 audit and explicit integration-template/input acceptance.
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
ROOT = PARENT/'stage_a_integration_v1'
SRC = ROOT/'src'
BUILD = ROOT/'build'
LIB = Path('/home/saphir/rule30_theorem_library/v19')
LEAN = Path('/home/saphir/.elan/toolchains/leanprover--lean4---v4.35.0/bin/lean')
CHECKER = ROOT/'IndependentFVLTReplay435.lean'
MODULES = (
    'FVLTFareyContactV1', 'FVLTFordGeometryV1', 'FVLTFareyCertificatesV1',
    'FVLTFareyArithmeticCompletionV1', 'FVLTFordGeometryCompletionV1',
    'FVLTUnitFractionSpineV1', 'FVLTPhasePartnersV1', 'FVLTFareyFixturesCompletionV1',
    'FVLTFordRationalV1', 'FVLTFordExactCoordinatesV1',
)
ENTRY = 'FVLTStageAIntegrationV1'

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def local(root, name):
    path = root/name
    assert path.resolve().parent == root
    return path

assert socket.gethostname() == 'nucleus'
assert '[ts-redacted1]' in os.environ.get('SSH_CONNECTION', '')
assert len(sys.argv) == 2
job_path = Path(sys.argv[1]).resolve()
assert job_path.parent == ROOT
job = json.loads(job_path.read_text())
review = json.loads((ROOT/'INTEGRATION_REVIEW_ACCEPTANCE.json').read_text())
assert review['input_review_reference'] and review['final_template_review_reference']
assert review['runner_sha256'] == sha(Path(__file__))
for name, digest in review['reviewed_files'].items():
    assert sha(local(ROOT,name)) == digest
bound_path = local(ROOT,review['bound_template_file'])
assert sha(bound_path) == review['bound_template_sha256'] == job['template_sha256']
bound = json.loads(bound_path.read_text())
assert bound['R5_manager_gate']['status'] == 'RECORDED_PASS'
assert bound['R5_manager_gate']['sha256']
assert sha(PARENT/bound['R5_manager_gate']['file']) == bound['R5_manager_gate']['sha256']
for name, digest in bound['recorded_manager_gates'].items():
    assert sha(PARENT/name) == digest
assert sha(job_path) in review['accepted_job_manifest_sha256']
assert job['phase'] == 'INTEGRATION'
assert job['mode'] in ('compile','replay')
assert not list(SRC.glob('*.olean')), 'Source folder must contain no project objects'
module = job['module']
assert module in MODULES+(ENTRY,)
assert job['run_id'] == ('Compile' if job['mode']=='compile' else 'Replay')+module
assert module != ENTRY or job['mode'] == 'compile'
assert job['lean_executable_sha256'] == sha(LEAN) == bound['lean_executable_sha256']
assert sha(CHECKER) == bound['checker_sha256']
assert max(int(p.name[1:]) for p in LIB.parent.iterdir()
           if p.is_dir() and p.name.startswith('v') and p.name[1:].isdigit()) == 19
for name, digest in bound['library_expected'].items():
    assert sha(LIB/name) == digest
for line in (LIB/'SHA256SUMS').read_text().splitlines():
    digest, name = line.split(maxsplit=1)
    path = LIB/name.lstrip('*')
    assert sha(path) == digest and path.stat().st_mode & 0o222 == 0
assert set(job['source_sha256']) == {m+'.lean' for m in MODULES+(ENTRY,)}
for name, digest in job['source_sha256'].items():
    assert sha(local(SRC,name)) == digest == bound['staged_source_sha256'][name]
for name, digest in bound['protected_origin_sha256'].items():
    assert sha(PARENT/name) == digest
for name, digest in job['dependency_olean_sha256'].items():
    assert sha(local(BUILD,name)) == digest
if job['mode'] == 'replay':
    assert module+'.olean' in job['dependency_olean_sha256']
    own_compile = json.loads((ROOT/('Compile'+module+'.json')).read_text())
    assert own_compile['exit_code']==0 and not own_compile['timeout']
    assert own_compile['source_unchanged'] and own_compile['origins_unchanged']
    assert own_compile['olean_sha256']==sha(BUILD/(module+'.olean'))
prior = MODULES if module==ENTRY else MODULES[:MODULES.index(module)]
for old in prior:
    for mode in ('Compile','Replay'):
        old_receipt = json.loads((ROOT/(mode+old+'.json')).read_text())
        assert old_receipt['exit_code'] == 0 and not old_receipt['timeout']
        assert old_receipt['source_unchanged'] and old_receipt['origins_unchanged']
        assert old_receipt['library_checksum_after_exit'] == 0
    old_report = json.loads((ROOT/('Replay'+old+'.log')).read_text().splitlines()[-1])
    assert old_report['verdict']=='PASS' and old_report['kernelReplayCompleted']
    assert old_report['targetConstants'] > 0 and not old_report['failures']
    assert old_report['targetConstants']==bound['expected_replay_counts'][old]
    assert old_report['unsafeConstants']==0 and old_report['partialConstants']==0
deadline = json.loads((ROOT/'INTEGRATION_DEADLINE.json').read_text())
assert deadline['active_cap_seconds'] == 1800
remaining = deadline['deadline_unix']-time.time()
assert remaining > 0
wall = min(240,remaining)
run_id = job['run_id']
log = ROOT/(run_id+'.log')
receipt = ROOT/(run_id+'.json')
assert not log.exists() and not receipt.exists()
lock = PARENT/'RUNNING.lock'
lock_fd = os.open(lock,os.O_WRONLY|os.O_CREAT|os.O_EXCL,0o600)
os.write(lock_fd,str(os.getpid()).encode())
os.close(lock_fd)

def limits():
    resource.setrlimit(resource.RLIMIT_AS,(8*1024**3,8*1024**3))
    resource.setrlimit(resource.RLIMIT_NPROC,(256,256))
    resource.setrlimit(resource.RLIMIT_FSIZE,(64*1024**2,64*1024**2))
    resource.setrlimit(resource.RLIMIT_CORE,(0,0))

try:
    BUILD.mkdir(exist_ok=True)
    if module==MODULES[0] and job['mode']=='compile':
        assert not list(BUILD.glob('*.olean')), 'Fresh project-object folder required'
    cpu = min(os.sched_getaffinity(0))
    os.sched_setaffinity(0,{cpu})
    os.nice(19)
    paths = [BUILD,LIB/'.lake/build/lib/lean']
    paths += sorted((LIB/'.lake/packages').glob('*/.lake/build/lib/lean'))
    env = dict(os.environ,LEAN_PATH=':'.join(map(str,paths)),LEAN_NUM_THREADS='1',
               MALLOC_ARENA_MAX='2',PATH=str(LEAN.parent)+':'+os.environ.get('PATH',''))
    cmd = [str(LEAN),'-j1','-s65536','-M7680','-D','Elab.async=false']
    command_cwd = SRC if job['mode']=='compile' else ROOT
    if job['mode']=='compile':
        cmd += ['-o',str(BUILD/(module+'.olean')),str(SRC/(module+'.lean'))]
    else:
        cmd += ['--run',str(CHECKER),module]
    started = time.time()
    record = dict(job=job,runner_sha256=sha(Path(__file__)),command=cmd,
                  started_unix=started,wall_cap_seconds=wall,address_space_bytes=8*1024**3,
                  process_limit=256,output_file_limit_bytes=64*1024**2,cpu_affinity=[cpu],
                  nice=19,transport=os.environ['SSH_CONNECTION'],LEAN_PATH=env['LEAN_PATH'],
                  library=str(LIB),lean_executable_sha256=sha(LEAN),
                  command_cwd=str(command_cwd),
                  imported_dependencies_reused=True,prior_project_objects_excluded=True)
    receipt.write_text(json.dumps(record,indent=2))
    with log.open('xb') as out:
        proc = subprocess.Popen(cmd,cwd=command_cwd,env=env,stdout=out,stderr=subprocess.STDOUT,
                                start_new_session=True,preexec_fn=limits)
        timed_out = False
        try:
            code = proc.wait(timeout=wall)
        except subprocess.TimeoutExpired:
            timed_out = True
            os.killpg(proc.pid,signal.SIGKILL)
            code = proc.wait()
    record.update(exit_code=code,timeout=timed_out,seconds=time.time()-started,
                  log_sha256=sha(log),log_bytes=log.stat().st_size,
                  peak_child_rss_kib=resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss)
    record['source_unchanged'] = all(sha(SRC/n)==d for n,d in job['source_sha256'].items())
    record['origins_unchanged'] = all(sha(PARENT/n)==d for n,d in bound['protected_origin_sha256'].items())
    record['gates_unchanged'] = all(sha(PARENT/n)==d for n,d in bound['recorded_manager_gates'].items())
    check = subprocess.run(['sha256sum','-c','SHA256SUMS'],cwd=LIB,
                           stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=60)
    (ROOT/(run_id+'.library_after.txt')).write_bytes(check.stdout)
    record['library_checksum_after_exit'] = check.returncode
    if job['mode']=='compile' and code==0:
        record['olean_sha256'] = sha(BUILD/(module+'.olean'))
    receipt.write_text(json.dumps(record,indent=2))
    print(json.dumps(record))
    assert code==0 and not timed_out and record['source_unchanged']
    assert record['origins_unchanged'] and record['gates_unchanged'] and check.returncode==0
finally:
    lock.unlink()
