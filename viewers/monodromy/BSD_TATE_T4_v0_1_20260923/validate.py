"""Offline strict structure and duplicate-key gate; no external schema retrieval."""
import json, os, sys
from pathlib import Path
if os.environ.get('BSD_SCHEMA_PYTHON_VENDOR'):
    sys.path.insert(0,os.environ['BSD_SCHEMA_PYTHON_VENDOR'])
from jsonschema import Draft202012Validator
from referencing import Registry, Resource

def unique(pairs):
    out={}
    for k,v in pairs:
        if k in out:raise ValueError('Duplicate JSON key: '+k)
        out[k]=v
    return out
def read(raw):return json.loads(raw,object_pairs_hook=unique)
BASE=Path(__file__).parent
def validate(packet,certificate=None):
    files=['BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/minimal-tate-record.schema.json','BSD_TATE_T1_v0_1_20260907/t1-packet.schema.json',
      'BSD_TATE_T2_v0_1_20260907/t2-packet.schema.json','BSD_TATE_T2_v0_1_20260907/t2-certificate.schema.json',
      'BSD_TATE_T3_v0_1_20260907/t3-packet.schema.json','BSD_TATE_T3_v0_1_20260907/t3-certificate.schema.json']
    schemas=[read((BASE.parent/f).read_text('utf-8')) for f in files]
    registry=Registry().with_resources([(s['$id'],Resource.from_contents(s)) for s in schemas])
    Draft202012Validator(read((BASE/'t4-packet.schema.json').read_text('utf-8')),registry=registry).validate(packet)
    def parent(q):
        raw=q['parent']['bytes']
        if len(raw.encode('utf-8'))>4000000:raise ValueError('Parent exceeds 4 MB')
        Draft202012Validator(schemas[0]).validate(read(raw))
    parent(packet)
    for stage in packet['stages']:
        parent(stage['localPacket'])
        if stage['localPacket']['comparison'] is not None:raise ValueError('T4 local proofs require comparison=null')
    if certificate is not None:
        Draft202012Validator(read((BASE/'t4-certificate.schema.json').read_text('utf-8')),registry=registry).validate(certificate)
if __name__=='__main__':
    try:
        raw=sys.stdin.buffer.read(34000001)
        if len(raw)>34000000:raise ValueError('Envelope exceeds 34 MB')
        q=read(raw.decode('utf-8'))
        if sys.argv[1:]==['--custom-input']:
            if not isinstance(q,dict) or set(q)!={'ainvs','points','selectedMultiplier'}:raise ValueError('Invalid custom input fields')
            print('STRUCTURE_PASS');sys.exit(0)
        if sys.argv[1:]:raise ValueError('Unknown argument')
        if not isinstance(q,dict) or set(q)!={'packet','certificate'}:raise ValueError('Invalid request envelope')
        validate(q['packet'],q['certificate']);print('STRUCTURE_PASS')
    except Exception as e:print(str(e),file=sys.stderr);sys.exit(1)
