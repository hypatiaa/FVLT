"""Independent high-precision real quadrature; no production formulas imported.
Numerical cross-check, not the source of the enclosure proof.
"""
import json, sys
from fractions import Fraction
from decimal import Decimal as D, getcontext
getcontext().prec = 100
# Chudnovsky pi, independent of production Machin/AGM code.
M=1; L=13591409; X=1; K=6; total=D(L)
for k in range(1,10):
    M=M*(K*K*K-16*K)//(k*k*k); L+=545140134; X*=-262537412640768000
    total+=D(M*L)/X; K+=12
PI=D(426880)*D(10005).sqrt()/total
rows=json.load(open(sys.argv[1],encoding='utf-8'))
def number(s):
    f=Fraction(s); return D(f.numerator)/f.denominator
def contains(v,x):
    assert number(v['lo']) <= x <= number(v['hi']), (v, str(x))
nodes={}
def quadrature(fn):
    old=None
    for level in range(3,13):
        h=D(1)/(2**level)
        if level not in nodes:
            ns=[]
            for k in range(0,5*2**level):
                t=k*h; et=t.exp(); sh=(et-1/et)/2; ch=(et+1/et)/2
                z=PI*sh/2; ez=(2*z).exp(); c=(ez+2+1/ez)/4
                x=1/(1+ez); weight=h*PI*ch/(4*c)
                if weight<D('1e-85'):break
                ns.append((x,weight,k==0))
            nodes[level]=ns
        value=sum((w*(fn(x) if center else fn(x)+fn(1-x)) for x,w,center in nodes[level]),D(0))
        if old is not None and abs(value-old)<D('1e-65'):return value
        old=value
    raise AssertionError('Independent quadrature did not converge')

count=0
for row in rows:
    u=row['request']['u1']['result']; A=number(u['shortModel']['A']); B=number(u['shortModel']['B'])
    roots=[]
    for v in u['realRoots']:
        x=(number(v['lo'])+number(v['hi']))/2
        for _ in range(12): x-=(x*x*x+A*x+B)/(3*x*x+A)
        roots.append(x)
    r=max(roots); H=3*r*r+A
    period=quadrature(lambda s: 2/(s**4+3*r*s*s*(1-s)**2+H*(1-s)**4).sqrt())
    exact_aa=list(map(Fraction,row['request']['u1']['request']['ainvs']))
    aa=list(map(number,row['request']['u1']['request']['ainvs']))
    shift=(aa[0]*aa[0]+4*aa[1])/12
    checked=set()
    for p in row['placements']:
        key=json.dumps(p['finalPoint'],sort_keys=True)
        if key in checked:continue
        checked.add(key)
        point=p['finalPoint']
        if point.get('infinity'):
            value=D(0); exact_alpha=D(0)
        else:
            exact_alpha=None
            X=number(point['x'])+shift
            Y=number(str(Fraction(point['y'])+(exact_aa[0]*Fraction(point['x'])+exact_aa[2])/2))
            if Y==0:
                which=min(range(len(roots)),key=lambda i:abs(roots[i]-X))
                exact_alpha=D('0.5') if len(roots)==1 or which in (1,2) else D(0)
                value=period*exact_alpha
            elif p['component']=='IDENTITY':
                # Tail directly on x=r+1/t^2, independent of production Legendre/quartic scaling.
                end=1/(X-r).sqrt()
                tail=end*quadrature(lambda s: 1/(1+3*r*(end*s)**2+H*(end*s)**4).sqrt())
                value=period-tail if Y>0 else tail
            else:
                low,other,high=roots
                end=(X-low).sqrt()
                part=end*quadrature(lambda s: 1/((high-low-(end*s)**2)*(other-low-(end*s)**2)).sqrt())
                value=part if Y>0 else period-part
        contains(p['realLog'],value)
        contains(p['realAdaptedAddress'][0],exact_alpha if exact_alpha is not None else value/period)
        count+=1
json.dump({'status':'PASS','records':len(rows),'distinctPointsPerRecord':count,'method':'100-decimal direct real-cubic quadrature; numerical cross-check only'},open(sys.argv[2],'w'),indent=2)
