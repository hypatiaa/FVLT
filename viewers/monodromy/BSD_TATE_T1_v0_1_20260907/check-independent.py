"""Builder cross-check using Fraction polynomial substitution and tangent cones.
This is an independent calculation method, not an independent audit seat.
"""
import ast, hashlib, json, os
from fractions import Fraction as Q
from pathlib import Path
from validate import validate

base = Path(__file__).parent
root = os.environ.get('BSD_T1_SCRATCH_ROOT')
assert root and base.parent.resolve() == Path(root).resolve()
assert json.loads((Path(root)/'.bsd-t1-scratch.json').read_text())['kind'] == 'BSD_T1_SCRATCH_V1'
checks=[]
def digest(x):
    raw=x if isinstance(x,str) else json.dumps(x,sort_keys=True,separators=(',',':'),ensure_ascii=False)
    return hashlib.sha256(raw.encode()).hexdigest()
def add(*ps):
    out={}
    for p in ps:
        for k,v in p.items():out[k]=out.get(k,Q(0))+v
    return {k:v for k,v in out.items() if v}
def scale(p,c):return {k:v*c for k,v in p.items() if v*c}
def mul(p,q):
    out={}
    for (i,j),a in p.items():
        for (k,l),b in q.items():out[(i+k,j+l)]=out.get((i+k,j+l),Q(0))+a*b
    return {k:v for k,v in out.items() if v}
one={(0,0):Q(1)};X={(1,0):Q(1)};Y={(0,1):Q(1)}
def equation(a,x,y):
    a1,a2,a3,a4,a6=map(Q,a)
    return add(mul(y,y),scale(mul(x,y),a1),scale(y,a3),scale(mul(mul(x,x),x),-1),scale(mul(x,x),-a2),scale(x,-a4),scale(one,-a6))
def delta(a):
    a1,a2,a3,a4,a6=map(Q,a)
    b2=a1*a1+4*a2;b4=a1*a3+2*a4;b6=a3*a3+4*a6
    b8=a1*a1*a6+4*a2*a6-a1*a3*a4+a2*a3*a3-a4*a4
    return -b2*b2*b8-8*b4**3-27*b6**2+9*b2*b4*b6
def vp(a,p):
    a=Q(a);n,d=a.numerator,a.denominator;v=0
    assert n
    while n%p==0:n//=p;v+=1
    while d%p==0:d//=p;v-=1
    return v
def residue(a,p):
    a=Q(a);return a.numerator*pow(a.denominator,-1,p)%p
def count(a,p):
    a1,a2,a3,a4,a6=[residue(x,p) for x in a]
    total=1
    for x in range(p):
        b=(a1*x+a3)%p;c=(-x**3-a2*x*x-a4*x-a6)%p
        if p==2:total+=sum((y*y+b*y+c)%p==0 for y in range(p))
        else:
            d=(b*b-4*c)%p;leg=0 if d==0 else 1 if pow(d,(p-1)//2,p)==1 else -1
            total+=1+leg
    return total

fixtures=json.loads((base/'t1-fixtures.json').read_text('utf-8'))
for item in fixtures:
    q=item['packet'];cert=item['assessment']['certificate'];validate(q,cert)
    assert digest(q['parent']['bytes'])==q['parent']['sha256']
    record=q['record'];models={m['modelId']:m for m in record['models']}
    for m in models.values():
        assert Q(m['invariants']['discriminant'])==delta(m['ainvs'])
    c=Q(record['normalization']['sourceSelectedMultiplier']);U=Q(1)
    for step in record['transformations']:
        a=models[step['fromModelId']]['ainvs'];b=models[step['toModelId']]['ainvs'];u,r,s,t=[Q(step['urst'][k]) for k in ['u','r','s','t']]
        x=add(scale(X,u*u),scale(one,r));y=add(scale(Y,u**3),scale(X,s*u*u),scale(one,t))
        assert equation(a,x,y)==scale(equation(b,X,Y),u**6)
        assert delta(a)==u**12*delta(b)
        assert Q(a[0])+2*s==u*Q(b[0])
        assert Q(a[2])+Q(a[0])*r+2*t==u**3*Q(b[2])
        c/=u;U*=u
        assert Q(step['targetSelectedMultiplier'])==c
    assert Q(record['normalization']['targetSelectedMultiplier'])==c
    assert Q(record['normalization']['composedPullbackFactor'])==U
    for point in record['points']:
        z=point['coordinates']
        if not z.get('infinity'):
            assert equation(models[point['modelId']]['ainvs'],scale(one,Q(z['x'])),scale(one,Q(z['y'])))=={}
    inv=q['inventory'];product=int(inv['remainingCofactor'])
    for factor in inv['factors']:
        p=int(factor['p']);assert all(p%d for d in range(2,int(p**0.5)+1));product*=p**int(factor['exponent'])
    assert product==abs(delta(models[inv['modelId']]['ainvs']))
    assert inv['complete']==(inv['remainingCofactor']=='1')
    if cert:
        assert digest(cert)==item['assessment']['certificateId']
        assert digest(q)==cert['packetHash']
        p=int(cert['p']);a=models[cert['modelId']]['ainvs'];r=cert['result'];n=vp(delta(a),p)
        assert str(n)==r['discriminantValuation']
        N=count(a,p);assert str(p+1-N)==r['ap']
        if n==0:
            assert r['kodaira']=='I0' and r['tamagawaNumber']=='1'
        else:
            # Independent splitting criterion: enumerate the singular point and its tangent cone.
            a1,a2,a3,a4,a6=[residue(x,p) for x in a];sing=[]
            for x in range(p):
                for y in range(p):
                    if (y*y+a1*x*y+a3*y-x**3-a2*x*x-a4*x-a6)%p==0 and (a1*y-3*x*x-2*a2*x-a4)%p==0 and (2*y+a1*x+a3)%p==0:sing.append((x,y))
            assert len(sing)==1
            x,_=sing[0];slopes=[m for m in range(p) if (m*m+a1*m-3*x-a2)%p==0]
            assert len(slopes) in (0,2);split=len(slopes)==2
            assert r['split']==split
            assert r['tamagawaNumber']==str(n if split else 1 if n%2 else 2)
            assert r['kodaira']=='I'+str(n) and r['conductorExponent']=='1'
    else:assert item['expected']['status']=='UNAVAILABLE'
    checks.append({'name':item['name'],'status':'PASS','localOutcome':item['assessment']['status']})
ast.parse((base/'sage-producer.py').read_text('utf-8'))
receipt={'status':'PASS','standing':'BUILDER_INDEPENDENT_METHOD_NOT_COLD_AUDIT','total':len(checks),'checks':checks,'methods':['Fraction polynomial substitution','independent discriminant polynomial','Legendre quadratic discriminant point count','singular tangent-cone splitting'], 'sageProducerSyntax':'PASS','sageLive':'UNAVAILABLE'}
(base/'independent-tests.json').write_text(json.dumps(receipt,indent=2)+'\n',encoding='utf-8')
print(str(len(checks))+' independent Python fixture groups PASS; Sage syntax only')
