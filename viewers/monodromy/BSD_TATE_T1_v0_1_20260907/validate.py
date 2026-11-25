"""Strict, offline schema gate. No network reference resolution or dependency installation."""
import json, os, sys
from pathlib import Path
if os.environ.get('BSD_SCHEMA_PYTHON_VENDOR'):
    sys.path.insert(0, os.environ['BSD_SCHEMA_PYTHON_VENDOR'])
from jsonschema import Draft202012Validator
from referencing import Registry, Resource

def unique(pairs):
    out = {}
    for key, value in pairs:
        if key in out:
            raise ValueError('Duplicate JSON key: '+key)
        out[key] = value
    return out

def read(raw):
    return json.loads(raw, object_pairs_hook=unique)

def validate(packet, certificate=None):
    base = Path(__file__).parent
    predecessor = read((base.parent/'BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/minimal-tate-record.schema.json').read_text('utf-8'))
    schema = read((base/'t1-packet.schema.json').read_text('utf-8'))
    registry = Registry().with_resource(predecessor['$id'], Resource.from_contents(predecessor))
    Draft202012Validator(schema, registry=registry).validate(packet)
    Draft202012Validator(predecessor).validate(read(packet['parent']['bytes']))
    if certificate is not None:
        Draft202012Validator(read((base/'t1-certificate.schema.json').read_text('utf-8'))).validate(certificate)

if __name__ == '__main__':
    try:
        raw = sys.stdin.buffer.read(8000001)
        if len(raw) > 8000000:
            raise ValueError('T1 input exceeds 8 MB')
        request = read(raw.decode('utf-8'))
        if set(request) != {'packet', 'certificate'}:
            raise ValueError('Expected packet and certificate envelope')
        validate(request['packet'], request['certificate'])
        print('STRUCTURE_PASS')
    except Exception as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
