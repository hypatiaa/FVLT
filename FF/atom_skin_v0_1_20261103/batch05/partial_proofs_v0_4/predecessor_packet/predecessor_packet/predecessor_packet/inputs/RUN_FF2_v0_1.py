"""Prospective FF-2 runner. Review artifact only; never run during freeze preparation.

Usage on nucleus: python3 -I RUN_FF2_v0_1.py JOB.json
Every concrete job, source set, template, and acceptance file must be pinned first.
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

ROOT = Path('/home/saphir/fvlt_formalization_20261028/ff2_v03_20261103')
LIB = Path('/home/saphir/rule30_theorem_library/v20')
LEAN = Path('/home/saphir/.elan/toolchains/leanprover--lean4---v4.35.0/bin/lean')
MODULES = ('FVLTAtomSkinDataV1', 'FVLTAtomSkinCountsV1', 'FVLTAtomSkinPenV1',
           'FVLTPillowcaseDataV1', 'FVLTPillowcaseV1')


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def member(root, name):
    p = (root / name).resolve()
    assert p.is_relative_to(root.resolve()) and p != root.resolve()
    return p


def read(p):
    return json.loads(p.read_text())


def library_check(expected):
    latest = max(int(p.name[1:]) for p in LIB.parent.iterdir()
                 if p.is_dir() and p.name.startswith('v') and p.name[1:].isdigit())
    assert latest == 20, 'Latest library changed: return for binding review'
    for n, h in expected.items():
        assert sha(member(LIB, n)) == h
    count = 0
    for line in (LIB / 'SHA256SUMS').read_text().splitlines():
        h, n = line.split(maxsplit=1)
        p = member(LIB, n.lstrip('*'))
        assert sha(p) == h and not (p.stat().st_mode & 0o222)
        count += 1
    return count


def limits():
    resource.setrlimit(resource.RLIMIT_AS, (8 * 1024**3, 8 * 1024**3))
    resource.setrlimit(resource.RLIMIT_NPROC, (256, 256))
    resource.setrlimit(resource.RLIMIT_FSIZE, (64 * 1024**2, 64 * 1024**2))
    resource.setrlimit(resource.RLIMIT_CORE, (0, 0))


def main():
    assert socket.gethostname() == 'nucleus'
    assert '[ts-redacted1]' in os.environ.get('SSH_CONNECTION', '')
    assert len(sys.argv) == 2
    jobpath = Path(sys.argv[1]).resolve()
    assert jobpath.parent == ROOT
    review = read(ROOT / 'REVIEW_ACCEPTANCE.json')
    assert review['input_signature_acceptance'] and review['template_acceptance']
    assert sha(Path(__file__)) == review['runner_sha256']
    assert sha(jobpath) in review['accepted_job_sha256']
    templatepath = member(ROOT, review['bound_template_file'])
    assert sha(templatepath) == review['bound_template_sha256']
    template = read(templatepath)
    assert template['status'] == 'BOUND_ACCEPTED'
    assert template['host_reservation_reference']
    assert template['fresh_capacity_receipt_sha256']
    capacity = member(ROOT, template['fresh_capacity_receipt_file'])
    assert sha(capacity) == template['fresh_capacity_receipt_sha256']
    assert time.time() - read(capacity)['observed_unix'] <= 600
    for n, h in review['reviewed_files'].items():
        assert sha(member(ROOT, n)) == h
    job = read(jobpath)
    assert job['phase'] == 'FF2_AB'
    assert job['template_sha256'] == sha(templatepath)
    assert job['module'] in MODULES and job['mode'] in ('compile', 'replay', 'axioms')
    assert job['run_id'].replace('_', '').isalnum()
    assert sha(LEAN) == template['lean_executable_sha256']
    checker = member(ROOT, 'IndependentFVLTReplay435.lean')
    assert sha(checker) == template['checker_sha256']
    assert job['signature_comparison_receipt_sha256']
    comparison = member(ROOT, job['signature_comparison_receipt_file'])
    assert sha(comparison) == job['signature_comparison_receipt_sha256']
    assert read(comparison)['verdict'] == 'PASS'
    assert read(comparison)['source_sha256'] == job['source_sha256']
    assert read(comparison)['freeze_sha256'] == template['signature_freeze_sha256']
    assert read(comparison)['g1_import_closure_excluded'] is True
    attempt = member(ROOT, job['attempt_folder'])
    src, build = attempt / 'src', attempt / 'build'
    assert build.is_dir() and src.is_dir() and not list(src.glob('*.olean*'))
    assert not src.is_symlink() and not build.is_symlink()
    assert src.resolve().is_relative_to(ROOT) and build.resolve().is_relative_to(ROOT)
    assert job['source_sha256'] and job['module'] + '.lean' in job['source_sha256']
    for n, h in job['source_sha256'].items():
        assert sha(member(src, n)) == h
    for n, h in job['dependency_olean_sha256'].items():
        assert sha(member(build, n)) == h
    for n, h in job['prerequisite_receipt_sha256'].items():
        prior = member(ROOT, n)
        assert sha(prior) == h and read(prior)['accepted_result'] is True
    if job['mode'] in ('replay', 'axioms'):
        assert job['module'] + '.olean' in job['dependency_olean_sha256']
        assert job['prerequisite_receipt_sha256'], 'Own successful compile required'
        ownpath = member(ROOT, job['own_compile_receipt_file'])
        assert sha(ownpath) == job['prerequisite_receipt_sha256'][job['own_compile_receipt_file']]
        own = read(ownpath)
        assert own['accepted_result'] and own['job']['mode'] == 'compile'
        assert own['job']['module'] == job['module']
        assert own['job']['source_sha256'] == job['source_sha256']
        assert own['olean_sha256'] == sha(build / (job['module'] + '.olean'))
    if job['mode'] == 'compile':
        assert not (build / (job['module'] + '.olean')).exists()
    library_check(template['library_expected'])
    deadline = read(member(ROOT, job['deadline_file']))
    assert deadline['cap_seconds'] == 1800
    assert deadline['deadline_unix'] == deadline['origin_unix'] + 1800
    assert deadline['origin_unix'] <= time.time() < deadline['deadline_unix']
    wall = min(240, deadline['deadline_unix'] - time.time())
    log = member(ROOT, job['run_id'] + '.log')
    receipt = member(ROOT, job['run_id'] + '.json')
    assert not log.exists() and not receipt.exists()
    lock = ROOT / 'RUNNING.lock'
    fd = os.open(lock, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    os.write(fd, str(os.getpid()).encode())
    os.close(fd)
    try:
        cpu = min(os.sched_getaffinity(0))
        os.sched_setaffinity(0, {cpu})
        os.nice(19)
        paths = [build, LIB / '.lake/build/lib/lean']
        paths += sorted((LIB / '.lake/packages').glob('*/.lake/build/lib/lean'))
        env = dict(os.environ, LEAN_PATH=':'.join(map(str, paths)),
                   LEAN_NUM_THREADS='1', MALLOC_ARENA_MAX='2')
        cmd = [str(LEAN), '-j1', '-s65536', '-M7680', '-D', 'Elab.async=false']
        if job['mode'] == 'compile':
            cmd += ['-o', str(build / (job['module'] + '.olean')),
                    str(src / (job['module'] + '.lean'))]
        elif job['mode'] == 'replay':
            cmd += ['--run', str(checker), job['module']]
        else:
            audit = member(attempt, job['axiom_report_source'])
            assert sha(audit) == job['axiom_report_source_sha256']
            cmd += [str(audit)]
        started = time.time()
        record = dict(job=job, runner_sha256=sha(Path(__file__)), command=cmd,
                      started_unix=started, wall_cap_seconds=wall,
                      transport=os.environ['SSH_CONNECTION'],
                      LEAN_PATH=env['LEAN_PATH'], library=str(LIB),
                      imported_dependencies_reused=True, cpu_affinity=[cpu],
                      address_space_bytes=8 * 1024**3, process_limit=256,
                      output_file_limit_bytes=64 * 1024**2, nice=19)
        receipt.write_text(json.dumps(record, indent=2))
        with log.open('xb') as out:
            proc = subprocess.Popen(cmd, cwd=src, env=env, stdout=out,
                                    stderr=subprocess.STDOUT, start_new_session=True,
                                    preexec_fn=limits)
            timeout = False
            try:
                code = proc.wait(timeout=wall)
            except subprocess.TimeoutExpired:
                timeout = True
                os.killpg(proc.pid, signal.SIGKILL)
                code = proc.wait()
        record.update(exit_code=code, timeout=timeout, seconds=time.time() - started,
                      log_sha256=sha(log), log_bytes=log.stat().st_size,
                      peak_child_rss_kib=resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss)
        unchanged = all(sha(member(src, n)) == h for n, h in job['source_sha256'].items())
        protected = all(sha(member(ROOT, n)) == h for n, h in review['reviewed_files'].items())
        record['source_unchanged'] = unchanged
        record['reviewed_files_unchanged'] = protected
        record['library_checksums_after'] = library_check(template['library_expected'])
        passed = code == 0 and not timeout and unchanged and protected
        if job['mode'] == 'replay' and code == 0:
            report = json.loads(log.read_text().splitlines()[-1])
            passed = passed and report['verdict'] == 'PASS' and report['kernelReplayCompleted']
            passed = passed and report['targetConstants'] > 0 and not report['failures']
            passed = passed and report['unsafeConstants'] == 0 and report['partialConstants'] == 0
        if job['mode'] == 'compile' and code == 0:
            record['olean_sha256'] = sha(build / (job['module'] + '.olean'))
        record['accepted_result'] = bool(passed)
        receipt.write_text(json.dumps(record, indent=2))
        print(json.dumps(record))
        return 0 if passed else 1
    finally:
        lock.unlink()


if __name__ == '__main__':
    sys.exit(main())
