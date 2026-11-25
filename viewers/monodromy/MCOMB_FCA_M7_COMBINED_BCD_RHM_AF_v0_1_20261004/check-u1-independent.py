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
for row in rows:
    u=row['result']; A=number(u['shortModel']['A']); B=number(u['shortModel']['B'])
    roots=[]
    for v in u['realRoots']:
        x=(number(v['lo'])+number(v['hi']))/2
        for _ in range(12):x-=(x**3+A*x+B)/(3*x*x+A)
        roots.append(x)
    for v,r in zip(u['realRoots'],roots): contains(v,r)
    r=max(roots)
    # x=r+t^2 removes the endpoint root. t=s/(1-s) compactifies infinity.
    H=3*r*r+A
    def integrand(s):
        if s==1:return D(2)
        return 2/(s**4+3*r*s*s*(1-s)**2+H*(1-s)**4).sqrt()
    period=quadrature(integrand)
    contains(u['primitiveReal'],period)
    contains(u['realTotal'],period*u['realComponents'])
    # Reflected cubic yields the imaginary cycle independently of AGM.
    rr=-min(roots)
    HH=3*rr*rr+A
    def reflected(s):
        if s==1:return D(2)
        return 2/(s**4+3*rr*s*s*(1-s)**2+HH*(1-s)**4).sqrt()
    imaginary=quadrature(reflected)
    if u['shape']=='RHOMBIC':imaginary/=2
    contains(u['omega2'][1],imaginary)
json.dump({'status':'PASS','cases':len(rows),'method':'100-decimal real quadrature on original/reflected cubics; independent numerical cross-check'},open(sys.argv[2],'w'),indent=2)
