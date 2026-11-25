"""Builder's distinct global check. Fraction transport, exhaustive small-prime
minimality, and an invariant/residue formula at tame primes. Not a cold seat.
"""
import importlib.util, json, os
from fractions import Fraction as Q
from pathlib import Path
BASE=Path(__file__).parent
spec=importlib.util.spec_from_file_location('frozen_t3_fraction',BASE.parent/'BSD_TATE_T3_v0_1_20260907/check-independent.py')
old=importlib.util.module_from_spec(spec);spec.loader.exec_module(old)
val,inv,transform,residue=old.val,old.inv,old.transform,old.residue

def tame(a,p):
    c4,c6,D=inv(list(map(Q,a)))[-3:];A,B=-c4/48,-c6/864
    assert val(A,p)<4 or val(B,p)<6,'Tame model not minimal'
    n=val(D,p);square=lambda x:pow(residue(x,p),(p-1)//2,p)==1
    if n==0:return 'I0',1,0,n
    if val(c4,p)==0:return 'I'+str(n),n if square(-c6) else 1 if n%2 else 2,1,n
    jv=3*val(c4,p)-n
    if jv<0:
        m=-jv;assert n==m+6
        aa,bb=A/p**2,B/p**3
        roots=[x for x in range(p) if residue(x**3+aa*x+bb,p)==0 and residue(3*x*x+aa,p)==0]
        assert len(roots)==1 and roots[0]!=0
        unit=D/p**n;test=unit if m%2==0 else -3*roots[0]*unit
        return 'I'+str(m)+'*',4 if square(test) else 2,2,n
    kind={2:'II',3:'III',4:'IV',6:'I0*',8:'IV*',9:'III*',10:'II*'}[n]
    if kind in ['II','II*']:cp=1
    elif kind in ['III','III*']:cp=2
    elif kind=='IV':cp=3 if square(B/p**2) else 1
    elif kind=='IV*':cp=3 if square(B/p**4) else 1
    else:cp=1+sum(residue(x**3+(A/p**2)*x+B/p**3,p)==0 for x in range(p))
    return kind,cp,2,n

def point(a,z):
    if z.get('infinity'):return
    a1,a2,a3,a4,a6=map(Q,a);x,y=Q(z['x']),Q(z['y'])
    assert y*y+a1*x*y+a3*y==x**3+a2*x*x+a4*x+a6

def main():
    root=os.environ.get('BSD_T4_SCRATCH_ROOT')
    assert root and BASE.parent.resolve()==Path(root).resolve()
    assert json.loads((BASE.parent/'.bsd-t4-scratch.json').read_text())['kind']=='BSD_T4_SCRATCH_V1'
    fixtures=json.loads((BASE/'t4-fixtures.json').read_text('utf-8'));checks=[]
    for f in fixtures:
        q=f['packet'];record=q['record'];models={m['modelId']:list(map(Q,m['ainvs'])) for m in record['models']};a=models[record['normalization']['targetModelId']]
        assert all(x.denominator==1 for x in a);D=inv(a)[-1];assert D!=0
        for w in record['transformations']:
            assert transform(models[w['fromModelId']],**w['urst'])==models[w['toModelId']]
        input_record=json.loads(q['parent']['bytes']);u=Q(q['adapter']['composite']['u']);norm=record['normalization']
        assert Q(norm['targetSelectedMultiplier'])*u==Q(input_record['normalization']['targetSelectedMultiplier'])
        assert Q(norm['composedPullbackFactor'])==Q(input_record['normalization']['composedPullbackFactor'])*u
        for st in q['stages']:
            p=int(st['p']);w=st['localPacket']['adapter']['composite'];v=st['lift'];r,s,t,U=map(Q,[w['r'],w['s'],w['t'],w['u']]);R,S,T=map(Q,[v['r'],v['s'],v['t']]);k=val(U,p)
            assert U==Q(v['u']) and k>=0 and U==p**k
            assert val(R-r,p)>=2*k and val(S-s,p)>=k and val(T-t-s*(R-r),p)>=3*k
            assert transform(list(map(Q,st['localPacket']['trace']['targetAinvs'])),**st['localToIntegral'])==list(map(Q,st['target']['ainvs']))
        N=cp_product=1;bad=[]
        for t in q['proof']['transfers']:
            p=int(t['p']);assert transform(list(map(Q,next(s['localPacket']['trace']['targetAinvs'] for s in q['stages'] if s['p']==t['p']))),**t['localToFinal'])==a
            w=t['localToFinal'];assert val(w['u'],p)==0 and all(val(w[k],p)>=0 for k in ['r','s','t'])
            if p in [2,3]:
                assert old.no_rescaling(a,p);r=old.tate(a,p);kind,cp,fp,n=r['kodaira'],int(r['tamagawaNumber']),int(r['conductorExponent']),int(r['discriminantValuation'])
            else:kind,cp,fp,n=tame(a,p)
            got=t['result'];assert (got['kodaira'],got['tamagawaNumber'],got['conductorExponent'],got['discriminantValuation'])==(kind,str(cp),str(fp),str(n))
            if n:bad.append(str(p));N*=p**fp;cp_product*=cp
        remaining=abs(int(D))
        for x in q['candidateInventory']['factors']:
            p,n=int(x['p']),int(x['exponent']);assert n==val(D,p);remaining//=p**n
        assert remaining==int(q['candidateInventory']['remainingCofactor'])
        assert q['candidateInventory']['complete']==(remaining==1)
        assert q['proof']['knownPrimeProducts']['conductor']==str(N) and q['proof']['knownPrimeProducts']['tamagawaProduct']==str(cp_product)
        if remaining==1:
            r=f['assessment']['certificate']['result'];assert r['minimalDiscriminant']==str(D) and r['curveBadPrimes']==bad and r['conductor']==str(N) and r['tamagawaProduct']==str(cp_product)
            z=r['normalization'];assert Q(z['neronOverSelectedMultiplier'])*Q(norm['targetSelectedMultiplier'])==1
            assert Q(z['absoluteRealMeasureFactorFromInput'])==abs(u)
            assert Q(z['absoluteRealMeasureFactorFromAnchor'])==abs(Q(norm['composedPullbackFactor']))
            assert Q(z['absoluteRealMeasureFactorFromSelected'])==abs(1/Q(norm['targetSelectedMultiplier']))
            assert z['realComponents']==('2' if D>0 else '1');assert z['periodValue']=='NOT_COMPUTED'
        else:assert f['assessment']['status']=='UNAVAILABLE' and q['proof']['globalResult'] is None
        for pt in record['points']:point(models[pt['modelId']],pt['coordinates'])
        checks.append({'name':f['name'],'status':'PASS','assessment':f['assessment']['status'],'knownPrimes':bad,'knownConductor':str(N),'knownTamagawaProduct':str(cp_product)})
    result={'status':'PASS','standing':'BUILDER_DISTINCT_METHOD_NOT_COLD_AUDIT','total':len(checks),'methods':['Fraction coefficient substitution and signed differential transport','Integral-lift congruences including t cross term','Exhaustive u=p minimality at 2 and 3','Independent short-invariant tame minimality and component splitting','Independent product and support reconciliation','Exact point membership'],'checks':checks}
    (BASE/'independent-tests.json').write_text(json.dumps(result,indent=2)+'\n','utf-8');print(str(len(checks))+' Python global reconciliation groups PASS')
if __name__=='__main__':main()
