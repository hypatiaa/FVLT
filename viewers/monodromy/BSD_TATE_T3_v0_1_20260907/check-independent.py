"""Builder's second method: explicit characteristic formulas plus exhaustive minimality.

No JavaScript arithmetic, branch trace, or PARI result is used to choose this Tate path.
This is a method cross-check, not an independent cold-audit seat.
"""
import json, os
from fractions import Fraction as Q
from pathlib import Path

BASE=Path(__file__).parent
def val(x,p):
    x=Q(x)
    if not x:return float('inf')
    a,b=x.numerator,x.denominator;v=0
    while a%p==0:a//=p;v+=1
    while b%p==0:b//=p;v-=1
    return v
def residue(x,p):
    x=Q(x);return x.numerator*pow(x.denominator,-1,p)%p
def inv(a):
    a1,a2,a3,a4,a6=a;b2=a1*a1+4*a2;b4=a1*a3+2*a4;b6=a3*a3+4*a6
    b8=a1*a1*a6+4*a2*a6-a1*a3*a4+a2*a3*a3-a4*a4
    c4=b2*b2-24*b4;c6=-b2**3+36*b2*b4-216*b6
    return b2,b4,b6,b8,c4,c6,(-b2*b2*b8-8*b4**3-27*b6*b6+9*b2*b4*b6)
def transform(a,u=1,r=0,s=0,t=0):
    a1,a2,a3,a4,a6=map(Q,a);u,r,s,t=map(Q,[u,r,s,t])
    return [(a1+2*s)/u,(a2-s*a1+3*r-s*s)/u**2,(a3+r*a1+2*t)/u**3,
      (a4-s*a3+2*r*a2-(t+r*s)*a1+3*r*r-2*s*t)/u**4,
      (a6+r*a4+r*r*a2+r**3-t*a3-r*t*a1-t*t)/u**6]
def roots(c,p):return [x for x in range(p) if sum(residue(v,p)*pow(x,i,p) for i,v in enumerate(c))%p==0]
def repeated(c,p):
    der=[i*c[i] for i in range(1,len(c))]
    return next(x for x in roots(c,p) if x in roots(der,p))
def quad(a,b,c,p):return (residue(b*b-4*a*c,p)!=0,len(roots([c,b,a],p))==2)
def tate(a,p):
    a=list(map(Q,a))
    def move(r=0,s=0,t=0,u=1):
        nonlocal a
        a=transform(a,u,r,s,t)
        assert min(val(x,p) for x in a)>=0
    def result(k,cp,split=None):
        d=val(inv(a)[-1],p)
        if k=='I0':f=0
        elif k.startswith('I') and k[1:].isdigit():f=1
        else:
            components={'II':1,'III':2,'IV':3,'I0*':5,'IV*':7,'III*':8,'II*':9}.get(k)
            if components is None:components=int(k[1:-1])+5
            f=d+1-components
        return {'kodaira':k,'tamagawaNumber':str(cp),'conductorExponent':str(f),'discriminantValuation':str(d),'split':split}
    for cycle in range(33):
        b2,b4,b6,b8,c4,c6,D=inv(a);d=val(D,p)
        if d==0:return result('I0',1)
        a1,a2,a3,a4,a6=a
        if p==2:
            if residue(b2,p)==0:r=residue(a4,p);t=residue(((r+a2)*r+a4)*r+a6,p)
            else:r=residue(a3/a1,p);t=residue((a4+r*r)/a1,p)
        else:
            r=residue(-b6,p) if residue(b2,p)==0 else residue(-b4/b2,p)
            t=residue(a1*r+a3,p)
        move(r=r,t=t);a1,a2,a3,a4,a6=a;b2,b4,b6,b8,c4,c6,D=inv(a)
        if residue(c4,p):
            split=quad(Q(1),a1,-a2,p)[1];return result('I'+str(d),d if split else 1 if d%2 else 2,split)
        if val(a6,p)<2:return result('II',1)
        if val(b8,p)<3:return result('III',2)
        if val(b6,p)<3:return result('IV',3 if quad(Q(1),a3/p,-a6/p**2,p)[1] else 1)
        if p==2:move(s=residue(a2,p),t=p*residue(a6/p**2,p))
        else:move(s=a1,t=a3)
        a1,a2,a3,a4,a6=a;b,c,d0=a2/p,a4/p**2,a6/p**3
        disc=27*d0*d0-b*b*c*c+4*b**3*d0-18*b*c*d0+4*c**3
        if residue(disc,p):return result('I0*',1+len(roots([d0,c,b,Q(1)],p)))
        triple=residue(3*c-b*b,p)==0
        if not triple:
            r=residue(c,p) if p==2 else residue(c/b,p)
            move(r=p*r);x=y=2
            for _ in range(64):
                a1,a2,a3,a4,a6=a;sep,split=quad(Q(1),a3/p**y,-a6/p**(x+y),p)
                if sep:return result('I'+str(x+y-3)+'*',4 if split else 2)
                t=residue(a6/p**(x+y),p) if p==2 else residue(-a3/(2*p**y),p)
                move(t=p**y*t);y+=1;a1,a2,a3,a4,a6=a
                sep,split=quad(a2/p,a4/p**(x+1),a6/p**(x+y),p)
                if sep:return result('I'+str(x+y-3)+'*',4 if split else 2)
                r=residue((a6/p**(x+y))/(a2/p),p) if p==2 else residue(-(a4/p**(x+1))/(2*a2/p),p)
                move(r=p**x*r);x+=1
            raise AssertionError('Independent star cap')
        r=residue(b,p) if p==2 else residue(-d0,p);move(r=p*r);a1,a2,a3,a4,a6=a
        sep,split=quad(Q(1),a3/p**2,-a6/p**4,p)
        if sep:return result('IV*',3 if split else 1)
        t=residue(a6/p**4,p) if p==2 else residue(-a3/(2*p**2),p)
        move(t=p**2*t);a1,a2,a3,a4,a6=a
        if val(a4,p)<4:return result('III*',2)
        if val(a6,p)<6:return result('II*',1)
        assert min(val(x,p)-i for x,i in zip(a,[1,2,3,4,6]))>=0
        move(u=p)
    raise AssertionError('Independent scaling cap')

def no_rescaling(a,p):
    # Any integral u=p step has representatives r mod p^2, s mod p, t mod p^3.
    # Modular tests, rather than Tate's terminal branch, assess local minimality here.
    a1,a2,a3,a4,a6=[residue(x,p**6) for x in a]
    for s in range(p):
        if (a1+2*s)%p:continue
        for r in range(p*p):
            if (a2-s*a1+3*r-s*s)%p**2:continue
            for t in range(p**3):
                if (a3+r*a1+2*t)%p**3:continue
                if (a4-s*a3+2*r*a2-(t+r*s)*a1+3*r*r-2*s*t)%p**4:continue
                if (a6+r*a4+r*r*a2+r**3-t*a3-r*t*a1-t*t)%p**6:continue
                return False
    return True

def main():
    scratch=os.environ.get('BSD_T3_SCRATCH_ROOT')
    if not scratch or BASE.parent.resolve()!=Path(scratch).resolve() or not (BASE.parent/'.bsd-t3-scratch.json').exists():raise RuntimeError('Run in staged T3 scratch')
    fixtures=json.loads((BASE/'t3-fixtures.json').read_text('utf-8'));checks=[]
    for f in fixtures:
        q=f['packet'];p=int(q['trace']['p']);computed=tate(q['integralSource']['ainvs'],p)
        assert computed==f['expected'],(f['name'],computed,f['expected'])
        a=list(map(Q,q['trace']['targetAinvs']));assert no_rescaling(a,p),f['name']
        for e in q['trace']['events']:
            if e['operation']=='MODEL_CHANGE':
                w=e['urst'];assert transform(e['fromAinvs'],**w)==list(map(Q,e['toAinvs']))
                assert Q(e['selectedMultiplierBefore'])/Q(w['u'])==Q(e['selectedMultiplierAfter'])
            if e['operation']=='RESIDUE_POLYNOMIAL':
                w=e['witness'];c=list(map(Q,w['rationalCoefficients']));assert roots(c,p)==[int(r['root']) for r in w['roots']]
                assert [str(sum(residue(v,p)*pow(x,i,p) for i,v in enumerate(c))%p) for x in range(p)]==w['evaluations']
        for point in q['record']['points']:
            model=next(m for m in q['record']['models'] if m['modelId']==point['modelId'])
            pt=point['coordinates']
            if pt.get('infinity'):continue
            x,y=Q(pt['x']),Q(pt['y']);a1,a2,a3,a4,a6=map(Q,model['ainvs']);assert y*y+a1*x*y+a3*y==x**3+a2*x*x+a4*x+a6
        checks.append({'name':f['name'],'status':'PASS','p':str(p),'result':computed,'minimalityMethod':'EXHAUSTIVE_U_P_CONGRUENCES'})
    out={'status':'PASS','standing':'BUILDER_DISTINCT_METHOD_NOT_COLD_AUDIT','total':len(checks),'checks':checks,'methods':['Characteristic-specific Tate formulas','Exhaustive u=p minimality congruences','Fraction substitutions and point membership','Independent finite-field evaluations']}
    (BASE/'independent-tests.json').write_text(json.dumps(out,indent=2)+'\n','utf-8');print(str(len(checks))+' independent Python small-prime groups PASS')
if __name__=='__main__':main()
