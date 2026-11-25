"""Distinct builder calculation: short invariants and discriminant-unit star splitting.
No JavaScript algorithm or Tate refinement loop is used here.
"""
import json, os
from pathlib import Path
from fractions import Fraction as Q
from validate import validate
base=Path(__file__).parent
root=os.environ.get('BSD_T2_SCRATCH_ROOT')
assert root and base.parent.resolve()==Path(root).resolve()
assert json.loads((Path(root)/'.bsd-t2-scratch.json').read_text())['kind']=='BSD_T2_SCRATCH_V1'
def vp(a,p):
    a=Q(a)
    if not a:return float('inf')
    n,d=a.numerator,a.denominator;v=0
    while n%p==0:n//=p;v+=1
    while d%p==0:d//=p;v-=1
    return v
def mod(a,p):
    a=Q(a);return a.numerator*pow(a.denominator,-1,p)%p
def square(a,p):
    a=mod(a,p);return a==0 or pow(a,(p-1)//2,p)==1
def invariants(a):
    a1,a2,a3,a4,a6=map(Q,a)
    b2=a1*a1+4*a2;b4=a1*a3+2*a4;b6=a3*a3+4*a6
    b8=a1*a1*a6+4*a2*a6-a1*a3*a4+a2*a3*a3-a4*a4
    return b2*b2-24*b4,-b2**3+36*b2*b4-216*b6,-b2*b2*b8-8*b4**3-27*b6**2+9*b2*b4*b6
def expected(a,p):
    c4,c6,disc=invariants(a);A=-c4/48;B=-c6/864
    while vp(A,p)>=4 and vp(B,p)>=6:A/=p**4;B/=p**6
    D=-16*(4*A**3+27*B**2);n=vp(D,p);v4=vp(A,p)
    if n==0:return 'I0',1,n
    if v4==0:
        split=square(864*B,p);return 'I'+str(n),n if split else 1 if n%2 else 2,n
    jv=3*v4-n
    if jv<0:
        m=-jv;assert n==m+6
        aa=A/p**2;bb=B/p**3
        roots=[x for x in range(p) if mod(x**3+aa*x+bb,p)==0 and mod(3*x*x+aa,p)==0]
        assert len(roots)==1 and roots[0]!=0
        unit=D/p**n
        # Alternative formula: even m tests Delta_unit, odd m tests -3*r*Delta_unit.
        residue=unit if m%2==0 else -3*roots[0]*unit
        return 'I'+str(m)+'*',4 if square(residue,p) else 2,n
    kind={2:'II',3:'III',4:'IV',6:'I0*',8:'IV*',9:'III*',10:'II*'}[n]
    if kind in ['II','II*']:cp=1
    elif kind in ['III','III*']:cp=2
    elif kind=='IV':cp=3 if square(B/p**2,p) else 1
    elif kind=='IV*':cp=3 if square(B/p**4,p) else 1
    else:cp=1+sum(mod(x**3+(A/p**2)*x+B/p**3,p)==0 for x in range(p))
    return kind,cp,n
def add(*ps):
    out={}
    for a in ps:
        for k,v in a.items():out[k]=out.get(k,Q(0))+v
    return {k:v for k,v in out.items() if v}
def times(a,c):return {k:v*c for k,v in a.items() if v*c}
def mul(a,b):
    out={}
    for (i,j),x in a.items():
        for (k,l),y in b.items():out[(i+k,j+l)]=out.get((i+k,j+l),Q(0))+x*y
    return {k:v for k,v in out.items() if v}
one={(0,0):Q(1)};X={(1,0):Q(1)};Y={(0,1):Q(1)}
def equation(a,x,y):
    a1,a2,a3,a4,a6=map(Q,a)
    return add(mul(y,y),times(mul(x,y),a1),times(y,a3),times(mul(mul(x,x),x),-1),times(mul(x,x),-a2),times(x,-a4),times(one,-a6))
checks=[]
for f in json.loads((base/'t2-fixtures.json').read_text('utf-8')):
    q=f['packet'];cert=f['assessment']['certificate'];validate(q,cert);p=int(q['trace']['p'])
    kind,cp,n=expected(q['trace']['sourceAinvs'],p);r=cert['result']
    assert (r['kodaira'],r['tamagawaNumber'],r['discriminantValuation'])==(kind,str(cp),str(n))
    assert int(r['conductorExponent'])==n+1-int(r['geometricComponents'])
    assert len(r['componentMultiplicities'])==int(r['geometricComponents'])
    for event in q['trace']['events']:
        if event['operation']=='MODEL_CHANGE':
            u,r0,s,t=[Q(event['urst'][k]) for k in ['u','r','s','t']]
            x=add(times(X,u*u),times(one,r0));y=add(times(Y,u**3),times(X,s*u*u),times(one,t))
            assert equation(event['fromAinvs'],x,y)==times(equation(event['toAinvs'],X,Y),u**6)
            assert Q(event['selectedMultiplierBefore'])/u==Q(event['selectedMultiplierAfter'])
        if event['operation']=='RESIDUE_POLYNOMIAL':
            w=event['witness'];a=list(map(int,w['coefficients']))
            evaluate=lambda x:sum(c*x**i for i,c in enumerate(a))%p
            assert w['evaluations']==[str(evaluate(x)) for x in range(p)]
            assert [r['root'] for r in w['roots']]==[str(x) for x in range(p) if evaluate(x)==0]
    for point in q['record']['points']:
        z=point['coordinates'];a=next(m['ainvs'] for m in q['record']['models'] if m['modelId']==point['modelId'])
        if not z.get('infinity'):assert not equation(a,times(one,Q(z['x'])),times(one,Q(z['y'])))
    checks.append({'name':f['name'],'status':'PASS','kodaira':kind,'tamagawaNumber':str(cp)})
out={'status':'PASS','standing':'BUILDER_DISTINCT_METHOD_NOT_COLD_AUDIT','total':len(checks),'methods':['Fraction polynomial substitution','short invariant valuation classification','discriminant-unit formula for I_n* splitting','independent residue evaluations'],'checks':checks}
(base/'independent-tests.json').write_text(json.dumps(out,indent=2)+'\n',encoding='utf-8')
print(str(len(checks))+' independent Python tame fixture groups PASS')
