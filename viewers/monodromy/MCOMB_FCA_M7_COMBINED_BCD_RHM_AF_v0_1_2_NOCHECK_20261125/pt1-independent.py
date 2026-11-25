"""Independent Fraction arithmetic in completed-square, depressed-cubic coordinates.
No production module is imported. Used only by the scratch verification worker.
"""
import json, sys
from fractions import Fraction as F

def codec(a):
    a1,a2,a3,a4,a6=map(F,a)
    shift=(a2+a1*a1/4)/3
    A=a4+a1*a3/2-3*shift*shift
    def to(p):
        if p.get('infinity'): return None
        x,y=F(p['x']),F(p['y'])
        return x+shift,y+(a1*x+a3)/2
    def back(p):
        if p is None: return {'infinity':True}
        X,Y=p; x=X-shift
        return {'x':str(x),'y':str(Y-(a1*x+a3)/2)}
    def add(p,q):
        if p is None:return q
        if q is None:return p
        x,y=p;u,v=q
        if x==u and y==-v:return None
        m=(3*x*x+A)/(2*y) if p==q else (v-y)/(u-x)
        z=m*m-x-u
        return z,m*(x-z)-y
    def times(p,n):
        if n<0:p=(p[0],-p[1]) if p else None;n=-n
        r=None
        # Repeated addition deliberately differs from binary production multiplication.
        for _ in range(n):r=add(r,p)
        return r
    return to,back,add,times

packets=json.load(sys.stdin);checks=[]
for item in packets:
    p=item['packet'];parent=json.loads(p['parent']['bytes'])
    a=next(m['ainvs'] for m in parent['models'] if m['modelId']==parent['normalization']['targetModelId'])
    to,back,add,times=codec(a);points=p['subgroup']['elements'];image=[to(x) for x in points]
    table=item['sumTable']
    for i,x in enumerate(image):
        for j,y in enumerate(image):assert back(add(x,y))==table[i][j]
    for x in image:
        for y in image:
            for z in image:assert add(add(x,y),z)==add(x,add(y,z))
    for op in p['operations']:
        if op['kind']=='MULTIPLY':assert back(times(to(op['points'][0]),int(op['scalar'])))==op['output']
    for w in p['bound']['witnesses']:
        prime=int(w['p']);aa=[(F(v).numerator*pow(F(v).denominator,-1,prime))%prime for v in a]
        n=1+sum((y*y+aa[0]*x*y+aa[2]*y-x*x*x-aa[1]*x*x-aa[3]*x-aa[4])%prime==0 for x in range(prime) for y in range(prime))
        assert str(n)==w['pointsIncludingInfinity']
    checks.append({'name':item['id']+' independent short-coordinate pair sums, associativity, multiples and exhaustive counts','status':'PASS'})
print(json.dumps({'status':'PASS','checks':checks}))
