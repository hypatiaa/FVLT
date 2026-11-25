"""Draft 2020-12 and independent polynomial-substitution checks; writes only in scratch."""
import copy
import json
import os
import sys
from fractions import Fraction as F
from pathlib import Path

vendor = os.environ.get('BSD_SCHEMA_PYTHON_VENDOR')
if vendor:
    sys.path.insert(0, vendor)
from jsonschema import Draft202012Validator

root = Path(__file__).resolve().parent
if os.environ.get('BSD_AUDIT_SCRATCH_ROOT') != str(root.parent) or not (root.parent/'.bsd-audit-scratch.json').exists():
    raise RuntimeError('Use node verify.cjs; workers run only in a staged scratch copy')
schema = json.loads((root / 'minimal-tate-record.schema.json').read_text(encoding='utf-8'))
Draft202012Validator.check_schema(schema)
validator = Draft202012Validator(schema)
checks = []

def passed(name):
    checks.append({'name': name, 'status': 'PASS'})

def plus(*polys):
    result = {}
    for poly in polys:
        for k, v in poly.items():
            result[k] = result.get(k, F(0)) + v
    return {k: v for k, v in result.items() if v}

def scale(poly, value):
    return {k: v * value for k, v in poly.items() if v * value}

def times(left, right):
    result = {}
    for (i, j), a in left.items():
        for (k, l), b in right.items():
            power = i+k, j+l
            result[power] = result.get(power, F(0)) + a*b
    return {k: v for k, v in result.items() if v}

def equation(a, x, y):
    a1,a2,a3,a4,a6 = map(F,a)
    return plus(times(y,y), scale(times(x,y),a1), scale(y,a3),
                scale(times(times(x,x),x),-1),scale(times(x,x),-a2),
                scale(x,-a4),{(0,0):-a6})

fixtures = []
for file in sorted((root / 'fixtures').glob('*.json')):
    packet = json.loads(file.read_text(encoding='utf-8'))
    validator.validate(packet)
    passed('Draft 2020-12: '+file.name)
    fixtures.append(packet)
    models = {m['modelId']:m for m in packet['models']}
    for step in packet['transformations']:
        u,r,s,t = [F(step['urst'][k]) for k in ['u','r','s','t']]
        X,Y = {(1,0):F(1)},{(0,1):F(1)}
        x,y = plus(scale(X,u*u),{(0,0):r}),plus(scale(Y,u**3),scale(X,s*u*u),{(0,0):t})
        source,target = models[step['fromModelId']]['ainvs'],models[step['toModelId']]['ainvs']
        assert equation(source,x,y) == scale(equation(target,X,Y),u**6)
        # Pull back omega_source under the inverse map: dx/(2y+a1*x+a3) = omega_target/u.
        denominator = plus(scale(y,2),scale(x,F(source[0])),{(0,0):F(source[2])})
        target_denominator = plus(scale(Y,2),scale(X,F(target[0])),{(0,0):F(target[2])})
        assert denominator == scale(target_denominator,u**3)
    passed('Independent polynomial and differential substitution: '+file.name)

base = next(p for p in fixtures if p['localData'])
mutations = [
    ('unknown root field', lambda q: q.update(assessment='CERTIFIED')),
    ('unknown model field', lambda q: q['models'][0].update(minimal=True)),
    ('numeric coefficient', lambda q: q['models'][0]['ainvs'].__setitem__(0,0)),
    ('six coefficients', lambda q: q['models'][0]['ainvs'].append('0')),
    ('negative Tamagawa', lambda q: q['localData'][0]['result'].update(tamagawaNumber='-1')),
    ('zero Tamagawa', lambda q: q['localData'][0]['result'].update(tamagawaNumber='0')),
    ('invalid Kodaira', lambda q: q['localData'][0]['result'].update(kodaira='unknown')),
    ('missing differential', lambda q: q['normalization'].pop('modelDifferential')),
    ('false infinity', lambda q: q['points'][0].update(coordinates={'infinity':False})),
    ('mixed affine infinity', lambda q: q['points'][0].update(coordinates={'infinity':True,'x':'0'})),
    ('unknown evidence status', lambda q: q['localData'][0]['evidence'].update(status='PASS')),
    ('audit standing in evidence', lambda q: q['localData'][0]['evidence'].update(standing='LOCKED')),
]
for name, mutate in mutations:
    bad = copy.deepcopy(base)
    mutate(bad)
    assert not validator.is_valid(bad), name
    passed('Structural rejection: '+name)

# Accept missing computation as explicit null; never promote it to a numerical zero.
pending = copy.deepcopy(base)
pending['minimalModel'] = pending['badPrimeInventory'] = pending['aggregate'] = None
pending['localData'] = []
validator.validate(pending)
passed('Unavailable local computation is representable without disabling exact points')
result = {'standing':'LOCAL_STRUCTURAL_AND_INDEPENDENT_SUBSTITUTION_NOT_TATE',
          'total':len(checks),'checks':checks,'jsonSchemaDraft':'2020-12'}
(root/'schema-python-verification.json').write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(str(len(checks))+' Python schema/substitution groups PASS')
