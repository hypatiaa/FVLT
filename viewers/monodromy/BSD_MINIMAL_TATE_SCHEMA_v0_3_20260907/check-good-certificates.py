"""Independent Fraction/Legendre recount and identity check for G2 certificates."""
import hashlib
import json
import os
import sys
from fractions import Fraction as F
from pathlib import Path

vendor=os.environ.get('BSD_SCHEMA_PYTHON_VENDOR')
if vendor: sys.path.insert(0,vendor)
from jsonschema import Draft202012Validator
root=Path(__file__).resolve().parent
if os.environ.get('BSD_AUDIT_SCRATCH_ROOT')!=str(root.parent):
    raise RuntimeError('Use node verify.cjs')
schema=json.loads((root/'good-prime-certificate.schema.json').read_text(encoding='utf-8'))
Draft202012Validator.check_schema(schema)
validator=Draft202012Validator(schema)
certificates=json.loads((root/'good-prime-certificates.json').read_text(encoding='utf-8'))
checks=[]
def hash_obj(obj):
    return hashlib.sha256(json.dumps(obj,sort_keys=True,separators=(',',':'),ensure_ascii=False).encode()).hexdigest()
for cert in certificates:
    validator.validate(cert)
    p=int(cert['p'])
    assert 2<=p<=1009 and all(p%d for d in range(2,int(p**0.5)+1))
    a1,a2,a3,a4,a6=map(F,cert['ainvs'])
    b2=a1*a1+4*a2; b4=2*a4+a1*a3; b6=a3*a3+4*a6
    b8=a1*a1*a6+4*a2*a6-a1*a3*a4+a2*a3*a3-a4*a4
    c4=b2*b2-24*b4; c6=-b2**3+36*b2*b4-216*b6
    delta=-b2*b2*b8-8*b4**3-27*b6*b6+9*b2*b4*b6
    assert c4**3-c6**2==1728*delta
    invs={k:str(v) for k,v in {'b2':b2,'b4':b4,'b6':b6,'b8':b8,'c4':c4,'c6':c6,'discriminant':delta,'j':c4**3/delta}.items()}
    assert cert['modelId']==hash_obj({'field':'Q','ainvs':cert['ainvs'],'invariants':invs})
    assert str(delta)==cert['discriminant']
    def mod(q):
        q=F(q)
        assert q.denominator%p
        return q.numerator*pow(q.denominator,-1,p)%p
    a=list(map(mod,cert['ainvs']))
    assert list(map(str,a))==cert['reducedAinvs']
    assert mod(delta)!=0 and str(mod(delta))==cert['discriminantResidue']
    count=1
    for x in range(p):
        rhs=(x**3+a[1]*x*x+a[3]*x+a[4])%p
        linear=(a[0]*x+a[2])%p
        if p==2:
            count+=sum((y*y+linear*y-rhs)%p==0 for y in range(p))
        else:
            discriminant=(linear*linear+4*rhs)%p
            chi=0 if discriminant==0 else (1 if pow(discriminant,(p-1)//2,p)==1 else -1)
            count+=1+chi
    assert str(count)==cert['pointsIncludingInfinity']
    assert str(p+1-count)==cert['ap']
    assert cert['eulerPolynomial']==['1',str(count-p-1),str(p)]
    assert cert['verifier']['sha256']==hashlib.sha256((root/'model-replay.cjs').read_bytes()).hexdigest()
    checks.append({'name':f'Independent exact invariants and point count at p={p} for {cert["modelId"][:12]}','status':'PASS'})
assert {int(c['p']) for c in certificates}>={2,3,5}
(root/'good-certificates-verification.json').write_text(json.dumps({'total':len(checks),'checks':checks,'method':'Fraction invariants and Legendre-discriminant recount; exhaustive at p=2'},indent=2)+'\n',encoding='utf-8')
print(str(len(checks))+' independent good-prime certificate checks PASS')
