"""Template-bound job receipts and report parsing only. Never invokes Lean."""
from pathlib import Path
import datetime
import hashlib
import json
import re
import shutil
import sys

ROOT=Path(__file__).resolve().parent
SRC=ROOT/'src'
BUILD=ROOT/'build'
BOUND='INTEGRATION_JOB_TEMPLATE_BOUND_v0_1.json'
EXPECTED_BOUND='765025bf6c3001435cbc2fd281d5a3109ed91443d9449a536425665bf41e4de5'
def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()
assert sha(ROOT/BOUND)==EXPECTED_BOUND
t=json.loads((ROOT/BOUND).read_text())
action,module,mode=sys.argv[1:]
assert action in ('prepare','check') and mode in ('compile','replay')
assert module in t['modules_in_order']+[t['entrypoint']]
assert module!=t['entrypoint'] or mode=='compile'
run_id=('Compile' if mode=='compile' else 'Replay')+module
job_name='JOB_'+run_id+'.json'
for n,d in t['staged_source_sha256'].items():
    assert sha(SRC/n)==d
if action=='prepare':
    assert not (ROOT/job_name).exists()
    assert not (ROOT/(run_id+'.json')).exists()
    rpath=ROOT/'INTEGRATION_REVIEW_ACCEPTANCE.json'
    review=json.loads(rpath.read_text())
    assert '1439' in review['final_template_review_reference']
    dependencies={p.name:sha(p) for p in sorted(BUILD.glob('*.olean'))}
    assert all(p[:-6] in t['modules_in_order'] for p in dependencies)
    if mode=='replay':
        assert module+'.olean' in dependencies
    stamp=datetime.datetime.now(datetime.timezone.utc).isoformat()
    job=dict(phase='INTEGRATION',mode=mode,module=module,run_id=run_id,
             template_sha256=EXPECTED_BOUND,lean_executable_sha256=t['lean_executable_sha256'],
             source_sha256=t['staged_source_sha256'],dependency_olean_sha256=dependencies,
             owner_accepted_utc=stamp)
    path=ROOT/job_name
    path.write_text(json.dumps(job,indent=2)+'\n')
    digest=sha(path)
    review['accepted_job_manifest_sha256'].append(digest)
    review['owner_acceptance_log'].append(dict(job=job_name,job_sha256=digest,
        accepted_utc=stamp,template_sha256=EXPECTED_BOUND,
        metadata_helper_sha256=sha(Path(__file__)),source_sha256=t['staged_source_sha256'],
        dependency_olean_sha256=dependencies))
    rpath.write_text(json.dumps(review,indent=2)+'\n')
    snap=ROOT/'snapshots'/run_id
    snap.mkdir(parents=True,exist_ok=False)
    for n in t['staged_source_sha256']:
        shutil.copyfile(SRC/n,snap/n)
    for n in (job_name,'INTEGRATION_REVIEW_ACCEPTANCE.json','RUN_INTEGRATION_v0_1.py',BOUND):
        shutil.copyfile(ROOT/n,snap/n)
    print(json.dumps(dict(run=run_id,prepared=True,job_sha256=digest)))
else:
    rec=json.loads((ROOT/(run_id+'.json')).read_text())
    assert rec['exit_code']==0 and not rec['timeout']
    assert rec['source_unchanged'] and rec['origins_unchanged'] and rec['gates_unchanged']
    assert rec['library_checksum_after_exit']==0
    log=ROOT/(run_id+'.log')
    assert sha(log)==rec['log_sha256']
    summary=dict(run=run_id,exit=0,seconds=rec['seconds'],peak_rss_KiB=rec['peak_child_rss_kib'])
    if mode=='replay':
        report=json.loads(log.read_text().splitlines()[-1])
        assert report['verdict']=='PASS' and report['kernelReplayCompleted']
        assert not report['failures'] and report['unsafeConstants']==0 and report['partialConstants']==0
        assert report['targetConstants']==t['expected_replay_counts'][module]
        allowed={'propext','Classical.choice','Quot.sound'}
        assert all(set(d['axioms'])<=allowed for d in report['declarations'])
        summary['replayed']=report['targetConstants']
    if module==t['entrypoint']:
        body=log.read_text()
        matches=re.findall(r"'([^']+)' depends on axioms:\s*\[([^]]*)\]",body)
        empty=re.findall(r"'([^']+)' does not depend on any axioms",body)
        matrix=json.loads((ROOT/'FIDELITY_MATRIX_v0_1.json').read_text())
        names={r['lean_name'] for r in matrix['original_targets']+matrix['additional_bridge_links']}
        assert len(matches)+len(empty)==72
        assert {m[0] for m in matches}|set(empty)==names
        assert all(set(x.strip() for x in axioms.split(','))<={'propext','Classical.choice','Quot.sound'}
                   for name,axioms in matches)
        summary['entrypoint_axiom_reports']=72
    print(json.dumps(summary))
