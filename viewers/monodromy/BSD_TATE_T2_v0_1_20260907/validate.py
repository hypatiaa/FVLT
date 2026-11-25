"""Offline structural gate, including duplicate keys in bound parent bytes."""
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
def validate(packet,certificate=None):
    base=Path(__file__).parent
    pre=read((base.parent/'BSD_MINIMAL_TATE_SCHEMA_v0_3_20260907/minimal-tate-record.schema.json').read_text('utf-8'))
    t1=read((base.parent/'BSD_TATE_T1_v0_1_20260907/t1-packet.schema.json').read_text('utf-8'))
    registry=Registry().with_resources([(s['$id'],Resource.from_contents(s)) for s in [pre,t1]])
    schema=read((base/'t2-packet.schema.json').read_text('utf-8'))
    Draft202012Validator(schema,registry=registry).validate(packet)
    Draft202012Validator(pre).validate(read(packet['parent']['bytes']))
    if packet['comparison'] is not None:Draft202012Validator(pre).validate(read(packet['comparison']['parent']['bytes']))
    if certificate is not None:Draft202012Validator(read((base/'t2-certificate.schema.json').read_text('utf-8'))).validate(certificate)
if __name__=='__main__':
    try:
        raw=sys.stdin.buffer.read(16000001)
        if len(raw)>16000000:raise ValueError('T2 envelope exceeds 16 MB')
        q=read(raw.decode('utf-8'))
        if set(q)!={'packet','certificate'}:raise ValueError('Invalid request envelope')
        validate(q['packet'],q['certificate']);print('STRUCTURE_PASS')
    except Exception as error:
        print(str(error),file=sys.stderr);sys.exit(1)
