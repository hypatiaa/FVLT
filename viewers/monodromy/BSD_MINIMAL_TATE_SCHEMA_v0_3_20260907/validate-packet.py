"""Read-only structural gate for the assessment CLI; JSON arrives on stdin."""
import json
import os
import sys
from pathlib import Path

vendor = os.environ.get('BSD_SCHEMA_PYTHON_VENDOR')
if vendor:
    sys.path.insert(0, vendor)
from jsonschema import Draft202012Validator

def unique(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ValueError('Duplicate JSON key: '+key)
        result[key] = value
    return result

try:
    raw = sys.stdin.buffer.read(4000001)
    if len(raw)>4000000:
        raise ValueError('Packet exceeds 4 MB')
    packet = json.loads(raw.decode('utf-8'), object_pairs_hook=unique)
    schema = json.loads((Path(__file__).parent/'minimal-tate-record.schema.json').read_text(encoding='utf-8'))
    Draft202012Validator(schema).validate(packet)
    print('STRUCTURE_PASS')
except Exception as error:
    print(str(error),file=sys.stderr)
    sys.exit(1)
