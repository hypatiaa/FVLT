"""Prepare the exact narrow successor allowed by manager decision #1513. No execution."""
from pathlib import Path
import difflib
import hashlib
import json

ROOT = Path(__file__).resolve().parent
OLD = ROOT / 'freeze_packet_v0_1'
OUT = ROOT / 'rebind_v22_v0_1'
PINS = {
    'SHA256SUMS': 'c7b6b52eb173959f360011ddbabd65f5828c8f788cd1b52a066749e2ae567505',
    'LIBRARY_MANIFEST.json': '47b72d67db15badcf4da63c8ded7c9e7a71e12fcb5e8bd1cf69b341d3b4ff92c',
    'lake-manifest.json': '1f0e0c1c0a06e2a9ecc117aed82f7a8ee62b418235e10686d3bda2d6986ea527',
    'lakefile.toml': '3aabc87bcb333679e16900efa8a0d26b1fa18b6995c7da6484ff996a14350be3',
    'lean-toolchain': 'ca5f1f601d34c49079e38d7e7041eb0f2a9c227fbc1df0f404820069a052330c',
}


def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    OUT.mkdir(exist_ok=False)
    original = (OLD / 'RUN_FF3_v0_1.py').read_bytes()
    assert sha(OLD / 'RUN_FF3_v0_1.py') == 'f9acf65a42bc901576cf109b17d5e0911b8b4310c38efc5b2e6044a62f396af5'
    successor = original.replace(b'theorem_library/v21', b'theorem_library/v22').replace(b'latest == 21', b'latest == 22')
    assert successor != original
    (OUT / 'RUN_FF3_v0_1.py').write_bytes(successor)
    template = json.loads((OLD / 'JOB_TEMPLATE_v0_1.json').read_text(encoding='utf-8-sig'))
    old_template = json.loads(json.dumps(template))
    template['library'] = '/home/saphir/rule30_theorem_library/v22'
    template['library_expected'] = PINS
    template['runner_sha256'] = sha(OUT / 'RUN_FF3_v0_1.py')
    (OUT / 'JOB_TEMPLATE_v0_1.json').write_text(json.dumps(template, indent=2) + '\n', encoding='utf-8')
    changed = [k for k in template if template[k] != old_template[k]]
    assert changed == ['library', 'library_expected', 'runner_sha256']
    diffs = []
    for name in ['RUN_FF3_v0_1.py', 'JOB_TEMPLATE_v0_1.json']:
        diffs.extend(difflib.unified_diff((OLD / name).read_text(encoding='utf-8-sig').splitlines(True),
                                        (OUT / name).read_text(encoding='utf-8-sig').splitlines(True),
                                        fromfile='accepted_v21/' + name, tofile='successor_v22/' + name))
    (OUT / 'SCRIPT_DIFF_v0_1.patch').write_text(''.join(diffs), encoding='utf-8')
    receipt = dict(status='PASS_NARROW_REBIND_DIFF_ONLY', decision_sha256=sha(ROOT / 'FF3_REBIND_V22_DECISION_v0_1.md'),
                   runner_changes=['LIB v21 to v22', 'latest guard 21 to22'], template_changed_keys=changed,
                   limits_changed=False, definitions_changed=False, headers_changed=False, index_changed=False,
                   checker_changed=False, binding_created=False, lean_invoked=False,
                   original_runner_sha256=sha(OLD / 'RUN_FF3_v0_1.py'),
                   successor_runner_sha256=sha(OUT / 'RUN_FF3_v0_1.py'),
                   original_template_sha256=sha(OLD / 'JOB_TEMPLATE_v0_1.json'),
                   successor_template_sha256=sha(OUT / 'JOB_TEMPLATE_v0_1.json'))
    (OUT / 'SCRIPT_DIFF_RECEIPT_v0_1.json').write_text(json.dumps(receipt, indent=2) + '\n')
    for name in ['RUN_FF3_v0_1.py', 'JOB_TEMPLATE_v0_1.json', 'SCRIPT_DIFF_v0_1.patch', 'SCRIPT_DIFF_RECEIPT_v0_1.json']:
        print(name, sha(OUT / name))


if __name__ == '__main__':
    main()
