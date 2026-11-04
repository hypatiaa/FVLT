"""Static text/JSON/Python-grammar validation only. Never imports or runs the runner."""
import ast
import hashlib
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    ast.parse((ROOT / 'RUN_FF3_v0_1.py').read_text(encoding='utf-8-sig'))
    targets = json.loads((ROOT / 'TARGET_INDEX_v0_1.json').read_text(encoding='utf-8-sig'))
    template = json.loads((ROOT / 'JOB_TEMPLATE_v0_1.json').read_text(encoding='utf-8-sig'))
    headers = (ROOT / 'FF3_HEADERS_PROPOSED_v0_1.lean.txt').read_text(encoding='utf-8-sig')
    data = (ROOT / 'FF3_DEFINITIONS_PROPOSED_v0_1.lean.txt').read_text(encoding='utf-8-sig')
    names = re.findall(r'^theorem\s+(\w+)', headers, re.M)
    assert len(names) == len(set(names)) == 37
    assert set('FVLT.PhasorFordV1.' + n for n in names) == set(t['name'] for t in targets['targets'])
    # The proposition-level let bindings in P5/P6 are not theorem proof bodies.
    without_lets = re.sub(r'^\s*let\s+\w+\s*:=.*$', '', headers, flags=re.M)
    assert ':=' not in without_lets
    assert not re.search(r'\b(sorry|admit|axiom|native_decide|implemented_by|unsafe|extern)\b', data + headers)
    for path_key, hash_key in [('runner', 'runner_sha256'), ('checker', 'checker_sha256'),
                               ('definitions_file', 'definitions_sha256'), ('headers_file', 'headers_sha256'),
                               ('target_index_file', 'target_index_sha256')]:
        assert sha(ROOT / template[path_key]) == template[hash_key]
    assert template['status'].startswith('PROPOSED')
    assert not (ROOT / 'REVIEW_ACCEPTANCE.json').exists()
    result = dict(status='PASS_STATIC_ONLY_NOT_LEAN_ELABORATION', target_count=37,
                  data_declarations=len(targets['data_axiom_targets']), runner_imported=False,
                  runner_executed=False, lean_invoked=False, mathematical_result=False,
                  note='Static validator distinguishes proposition-level let assignments from proof bodies')
    (ROOT / 'STATIC_VALIDATION_v0_1.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
