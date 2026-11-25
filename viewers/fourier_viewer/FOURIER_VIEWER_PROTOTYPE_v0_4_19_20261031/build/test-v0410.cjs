'use strict';
// v0.4.10 unit check (SCHEMA_ADDENDUM_18): host-core/branch-disk-core.js (exact register).
//  A. Branch primitivity: exact table n = 1..359 against orbit-core, an independent Euclid gcd and independent trial division; fixtures; gates; the refuted c = ±1 criterion; no Number arithmetic in the core.
//  B. Poincare disk: cusp images, Farey-edge geodesics (three routes), Astra's orbit points on n <= 30 against disk_checks.py (run live, python -I, stdin closed), unchanged files.
const fs=require('fs'),path=require('path'),crypto=require('crypto'),cp=require('child_process');
const X=require('../exact-lib/exact-lib-0.2.0.js'),C=require('../host-core/comb-core.js'),O=require('../host-core/orbit-core.js'),SH=require('../host-core/shell-core.js'),BD=require('../host-core/branch-disk-core.js');
let pass=0,fail=0;const ok=(n,c,x)=>{console.log((c?'PASS ':'FAIL ')+n+(x!==undefined&&!c?' '+x:''));c?pass++:fail++;};
const root=path.join(__dirname,'..'),V49='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_9_20261020';
const sha=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
const euclid=(a,b)=>{a=a<0n?-a:a;b=b<0n?-b:b;while(b){[a,b]=[b,a%b];}return a;};
const shell=(n,o)=>C.initial({shellMode:'integer',B:String(n*n),phi3:'0',m:String(2*n+1),t1:'1',t2:'1',...(o||{})});
const stN=(B,phi,m,o)=>C.initial({shellMode:'integer',B:String(B),phi3:String(phi),m:String(m),t1:'1',t2:'1',...(o||{})});
// ============================================================ A. branch primitivity
{ // A1. exact table n = 1..359
  let bad=[],checked=0,primes=0,forms=0,periods=0,primitiveOk=0;
  for(let n=1;n<=359;n++){
    const N=n*n+1,r=BD.primitivity(shell(n));
    if(!r.applies||r.N!==BigInt(N)||r.r!==BigInt(n)||!r.quadratic||r.n!==BigInt(n)){bad.push('n='+n+' head');continue;}
    const br=O.branches(shell(n)),byC=new Map(br.map(b=>[b.c,b]));
    let isPrime=N>=2;for(let d=2;d*d<=N;d++)if(N%d===0){isPrime=false;break;}   // independent trial division (Number; test only)
    if(isPrime)primes++;
    for(let c=2;c<=n;c++){const row=r.rows[c-2],b=byC.get(BigInt(c));checked++;
      const e=euclid(BigInt(N),BigInt(c));
      if(row.c!==BigInt(c)||row.g!==e||row.g!==b.commonFactor||b.clearedRate[0]!==BigInt(N)||b.clearedRate[1]!==BigInt(-c))bad.push('n='+n+' c='+c+' g');
      if(row.primitive[0]!==BigInt(N)/e||row.primitive[1]!==-BigInt(c)/e)bad.push('n='+n+' c='+c+' primitive'); else primitiveOk++;
      const per=b.closurePeriod;if(per&&X.eq(per,X.rat(2n*BigInt(N),e)))periods++;else bad.push('n='+n+' c='+c+' period');
      if(row.repeated!==(e>1n))bad.push('n='+n+' c='+c+' flag');
      if(e===1n&&!/^T\(/.test(row.type))bad.push('n='+n+' c='+c+' type g=1 should be a torus knot');
      if(e===BigInt(c)&&row.type!=='UNKNOT')bad.push('n='+n+' c='+c+' c|N should be UNKNOT');}
    if(r.prime!==isPrime)bad.push('n='+n+' verdict');
    if(!r.formsAgree||r.formAllPrimitive!==isPrime||r.formNoUnknot!==isPrime)bad.push('n='+n+' forms');else forms++;
    if(!isPrime&&n>=2){let p=2;while(N%p)p++;if(!r.least||r.least.c!==BigInt(p)||r.least.g!==BigInt(p))bad.push('n='+n+' least p');}
  }
  ok('A1 exact table n = 1…359 (B = n², φ₃ = 0, m = 2n + 1, gears 1): '+checked+' branches c = 2…n: g_c = card = orbit-core commonFactor = independent Euclid gcd; cleared (N, −c); primitive (N/g, −c/g); closure period 2N/g; type by g',bad.length===0,bad.slice(0,6).join(' | '));
  ok('A1 verdict = independent trial division for all 359 shells ('+primes+' primes n² + 1 in range); both forms (all ×1 / no UNKNOT among c = 2…n) agree on all '+forms+'; least repeated c = least prime factor',bad.filter(x=>/verdict|forms|least/.test(x)).length===0&&forms===359);
  ok('A1 the note’s count: 54 primes n² + 1 for n = 1…359',primes===54,String(primes));
}
{ // A2. fixtures
  const fx=(n)=>BD.primitivity(shell(n));
  const rep=(r)=>r.repeatedRows.map(x=>x.c+'x'+x.g+(x.unknot?'u':'')).join(',');
  const E={1:['prime',''],2:['prime',''],4:['prime',''],6:['prime',''],10:['prime',''],14:['prime',''],16:['prime',''],20:['prime','']};
  const exp=[[1,2,true,''],[2,5,true,''],[3,10,false,'2x2u'],[4,17,true,''],[5,26,false,'2x2u,4x2'],[6,37,true,''],[7,50,false,'2x2u,4x2,5x5u,6x2'],[8,65,false,'5x5u'],[10,101,true,''],[13,170,false,'2x2u,4x2,5x5u,6x2,8x2,10x10u,12x2'],[14,197,true,''],[16,257,true,''],[20,401,true,''],[359,128882,false,'2x2u,4x2,6x2,8x2,10x2,12x2,14x2,16x2,18x2,20x2,22x2,24x2,26x2,28x2,30x2,32x2,34x2,36x2,38x2,40x2,42x2,44x2,46x2,48x2,50x2,52x2,54x2,56x2,58x2,60x2,62x2,64x2,66x2,68x2,70x2,72x2,74x2,76x2,78x2,80x2,82x2,84x2,86x2,88x2,90x2,92x2,94x2,96x2,98x2,100x2,102x2,104x2,106x2,108x2,110x2,112x2,114x2,116x2,118x2,120x2,122x2,124x2,126x2,128x2,130x2,132x2,134x2,136x2,138x2,140x2,142x2,144x2,146x2,148x2,150x2,152x2,154x2,156x2,158x2,160x2,162x2,164x2,166x2,168x2,170x2,172x2,174x2,176x2,178x2,180x2,182x2,184x2,186x2,188x2,190x2,192x2,194x2,196x2,198x2,200x2,202x2,204x2,206x2,208x2,210x2,212x2,214x2,216x2,218x2,220x2,222x2,224x2,226x2,228x2,230x2,232x2,234x2,236x2,238x2,240x2,242x2,244x2,246x2,248x2,250x2,252x2,254x2,256x2,258x2,260x2,262x2,264x2,266x2,268x2,270x2,272x2,274x2,276x2,278x2,280x2,282x2,284x2,286x2,288x2,290x2,292x2,294x2,296x2,298x2,300x2,302x2,304x2,306x2,308x2,310x2,312x2,314x2,316x2,318x2,320x2,322x2,324x2,326x2,328x2,330x2,332x2,334x2,336x2,338x2,340x2,342x2,344x2,346x2,348x2,350x2,352x2,354x2,356x2,358x2']];
  let bad=[];
  for(const [n,N,prime,lst] of exp){const r=fx(n);const got=rep(r);
    if(r.N!==BigInt(N)||r.prime!==prime||(n!==359&&got!==lst))bad.push('n='+n+' N='+r.N+' prime='+r.prime+' rep='+got);}
  { // N = 128882 = 2 * 64441: only even c are repeated (64441 = 359²+1)/2 has no factor <= 359 other than...)
    const r=fx(359),exp2=[];for(let c=2;c<=359;c++){let g=euclid(128882n,BigInt(c));if(g>1n)exp2.push(c+'x'+g+(g===BigInt(c)?'u':''));}
    if(rep(r)!==exp2.join(','))bad.push('n=359 list vs independent gcd');
    if(r.least.c!==2n||r.least.g!==2n)bad.push('n=359 least');}
  ok('A2 fixtures N = 2, 5, 10 (c = 2 ×2), 17, 26 (c = 2, 4 ×2), 37, 50 (c = 2, 4, 5, 6; c = 5 UNKNOT ×5), 65 (c = 5 UNKNOT ×5), 101, 170, 197, 257, 401 and n = 359 (N = 128 882, even, c = 2 ×2; repeated list = independent gcd)',bad.length===0,bad.join(' | '));
}
{ // A3. the refuted criterion: c = ±1 is a primitive unknot for every N
  let bad=[];for(const n of [1,3,5,7,10,13,100,359]){const r=BD.primitivity(shell(n));
    if(!/UNKNOT/.test(r.unit.plus)||!/×1/.test(r.unit.plus)||!/UNKNOT/.test(r.unit.minus)||!/×1/.test(r.unit.minus))bad.push('n='+n+' '+r.unit.plus+' | '+r.unit.minus);
    if(r.zero.g!==r.N)bad.push('n='+n+' c=0 should repeat N times');}
  const r10=BD.primitivity(shell(3)),r26=BD.primitivity(shell(5));
  ok('A3 c = ±1 reads UNKNOT ×1 for every N tested (N = 10 and 26 composite among them), c = 0 repeats N times',bad.length===0&&r10.prime===false&&r26.prime===false&&/c \+1 · raw \(10,−1\) · primitive \(10,−1\) ×1 · UNKNOT/.test(r10.unit.plus),bad.join(' | '));
}
{ // A4. gates
  const nogo=(st,re)=>{const r=BD.primitivity(st);return !r.applies&&re.test(r.reason)&&r.rows.length===0&&r.prime===undefined;};
  const g=[];
  const t=(name,c)=>{if(!c)g.push(name);};
  t('t1=t2=2 at N=10',nogo(stN(9,0,7,{t1:'2',t2:'2'}),/not \(1, 1\)/));
  t('t1=1,t2=2',nogo(stN(9,0,7,{t1:'1',t2:'2'}),/not \(1, 1\)/));
  t('t1=1/2,t2=2/3',nogo(stN(9,0,7,{t1:'1/2',t2:'2/3'}),/not \(1, 1\)/));
  t('m=5 at N=26 lists c=3,4,5',(()=>{const r=BD.primitivity(stN(25,0,5));return !r.applies&&/lacks the branches c = 3, 4, 5/.test(r.reason)&&r.missing.join()==='3,4,5';})());
  t('even m=8 at N=26',nogo(stN(25,0,8),/even/));
  t('even m=2 at N=2 (default-like)',nogo(C.initial({shellMode:'integer',B:'1',phi3:'0',m:'2'}),/even/));
  t('N=0 (phi3 = B+1)',nogo(stN(9,10,7),/N = 0/));
  t('continuous non-integer N',nogo(C.initial({shellMode:'integer',B:'9',nMode:'continuous',phi3:'7/2',m:'7'}),/not an integer/));
  t('N=1 neither',nogo(stN(9,9,7),/neither prime nor composite/));
  t('m too small lists capped',(()=>{const r=BD.primitivity(stN(359*359,0,3));return !r.applies&&r.missing.length===358&&/more, up to 359/.test(r.reason);})());
  ok('A4 gates refuse a verdict with the reason: t₁ = t₂ = 2; t₁ = 1, t₂ = 2; t₁ = 1/2, t₂ = 2/3; m = 5 at N = 26 (missing 3, 4, 5); even m = 8; even m = 2; N = 0; non-integer N; N = 1; m = 3 at n = 359 (missing list capped at '+BD.MISSING_LINES+')',g.length===0,g.join(' | '));
  // N = 24 (N - 1 = 23 not a square): Q1 = any integer N, so the card applies, not highlighted as quadratic
  const r24=BD.primitivity(stN(23,0,9));
  ok('A4 Q1: N = 24 (N − 1 not a square) applies with c = 2…4, not marked quadratic, verdict composite (c = 2 ×2)',r24.applies&&!r24.quadratic&&r24.r===4n&&!r24.prime&&r24.least.c===2n&&r24.least.g===2n);
  const r2=BD.primitivity(C.initial({shellMode:'integer',B:'1',phi3:'0',m:'3',t1:'1',t2:'1'})),r3=BD.primitivity(C.initial({shellMode:'integer',B:'2',phi3:'0',m:'3',t1:'1',t2:'1'})),r4=BD.primitivity(C.initial({shellMode:'integer',B:'3',phi3:'0',m:'5',t1:'1',t2:'1'}));
  ok('A4 N = 2, 3 (empty range, prime) and N = 4 (r = 2, c = 2 ×2, composite)',r2.applies&&r2.prime&&r2.total===0&&r3.applies&&r3.prime&&r3.total===0&&r4.applies&&!r4.prime&&r4.r===2n&&r4.least.g===2n);
  // the gate is needed: counterexamples at N = 10 from the code (note §1)
  const mk=(t1,t2)=>O.branches(stN(9,0,7,{t1,t2})).filter(b=>[1n,2n,3n].includes(b.c)).map(b=>b.commonFactor);
  ok('A4 why the gate: at N = 10, t₁ = t₂ = 2 gives ×2, ×4, ×2 for c = 1, 2, 3 (twice gcd(10, c)); t₁ = 1, t₂ = 2 gives ×2 at c = 1; t₁ = 1/2, t₂ = 2/3 gives ×1 at c = 2 although 2 | 10',mk('2','2').join()==='2,4,2'&&mk('1','2')[0]===2n&&mk('1/2','2/3')[1]===1n,mk('2','2').join()+' | '+mk('1','2')+' | '+mk('1/2','2/3'));
  // n6 = 0: same numbers, formal-label flag
  const a=BD.primitivity(shell(7)),b=BD.primitivity(shell(7,{n6:'0'}));
  ok('A4 n₆ = 0: same rows and verdict, n6zero flag set (formal label); α changes nothing',b.applies&&b.n6zero&&!a.n6zero&&JSON.stringify(a.rows.map(x=>[x.c,x.g,x.type].join()))===JSON.stringify(b.rows.map(x=>[x.c,x.g,x.type].join()))&&a.rows.map(x=>String(x.g)).join()===BD.primitivity(shell(7,{alpha:'3/7'})).rows.map(x=>String(x.g)).join());
}
{ // A5. no Number arithmetic in the exact core
  const src=fs.readFileSync(path.join(root,'host-core','branch-disk-core.js'),'utf8').replace(/\/\/.*$/gm,'');
  const hits=src.match(/\bNumber\s*\(|parseFloat|parseInt|Math\.|\.toFixed|\bNumber\./g)||[];
  ok('A5 host-core/branch-disk-core.js contains no Number(, parseFloat, parseInt, Math. or toFixed (the verdict and every readout path is BigInt / exact rationals)',hits.length===0,hits.join(','));
}
// ============================================================ B. the disk
const G=(re,im)=>({re,im}),gadd=(a,b)=>G(X.add(a.re,b.re),X.add(a.im,b.im)),gsub=(a,b)=>G(X.sub(a.re,b.re),X.sub(a.im,b.im)),gmul=(a,b)=>G(X.sub(X.mul(a.re,b.re),X.mul(a.im,b.im)),X.add(X.mul(a.re,b.im),X.mul(a.im,b.re)));
const gdiv=(a,b)=>{const d=X.add(X.mul(b.re,b.re),X.mul(b.im,b.im));const n=gmul(a,G(b.re,X.sub(X.rat(0n),b.im)));return G(X.div(n.re,d),X.div(n.im,d));};
const gn2=a=>X.add(X.mul(a.re,a.re),X.mul(a.im,a.im)),geq=(a,b)=>X.eq(a.re,b.re)&&X.eq(a.im,b.im);
const Q=(n,d)=>X.rat(BigInt(n),BigInt(d||1)),I=G(Q(0),Q(1));
// independent Cayley map of a half-plane point z = p/q (q != 0) or infinity
const cayley=(z)=>gdiv(gsub(z,I),gadd(z,I));
const cayleyFrac=(p,q)=>q===0n?G(Q(1),Q(0)):cayley(G(X.rat(p,q),Q(0)));
{ // B1. cusp images on the unit circle, closed form = Cayley map
  let bad=0,n=0;
  for(let q=1n;q<=40n;q++)for(let p=-60n;p<=60n;p++){if(euclid(p,q)!==1n)continue;const k=BD.cusp(p,q),z=cayleyFrac(p,q);n++;
    if(!(geq(z,G(X.rat(k.re,k.den),X.rat(k.im,k.den)))&&k.re*k.re+k.im*k.im===k.den*k.den))bad++;}
  const k=BD.cusp(1n,2n),k2=BD.cusp(2n,3n);
  ok('B1 cusp images ζ(p/q) = ((p² − q²) − 2pq·i)/(p² + q²) = (z − i)/(z + i) exactly, on the unit circle (re² + im² = den²), '+n+' reduced p/q with q ≤ 40, |p| ≤ 60; 1/2 ↦ (−3 − 4i)/5, 2/3 ↦ (−5 − 12i)/13',bad===0&&k.text==='(−3 − 4i)/5'&&k2.text==='(−5 − 12i)/13',bad+' bad');
}
{ // B2. Farey-edge geodesics, three routes, on the F_10 cusps in [-1,1] and infinity (129 edges)
  const cus=[];for(let q=1n;q<=10n;q++)for(let p=-q;p<=q;p++)if(euclid(p,q)===1n)cus.push([p,q]);cus.push([1n,0n]);
  let edges=0,diam=0,bad=[];
  for(let i=0;i<cus.length;i++)for(let j=i+1;j<cus.length;j++){const [a,b]=cus[i],[c,d]=cus[j];if((a*d-b*c<0n?-(a*d-b*c):a*d-b*c)!==1n)continue;edges++;
    const e=BD.edge(a,b,c,d),z1=cayleyFrac(a,b),z2=cayleyFrac(c,d);
    if(e.diameter){diam++;
      if(!X.eq(gn2(gadd(z1,z2)),Q(0)))bad.push('diameter not antipodal '+a+'/'+b+' '+c+'/'+d);continue;}
    const C0=G(X.rat(e.cre,e.den),X.rat(e.cim,e.den)),r2=X.rat(1n,e.den*e.den);
    // route 1: |C|² = 1 + r² (orthogonal to the rim) and the circle passes through both cusp images
    if(!X.eq(gn2(C0),X.add(Q(1),r2)))bad.push('orthogonality '+a+'/'+b+' '+c+'/'+d);
    if(!X.eq(gn2(gsub(z1,C0)),r2)||!X.eq(gn2(gsub(z2,C0)),r2))bad.push('through cusps '+a+'/'+b+' '+c+'/'+d);
    // route 2: the centre is the intersection of the tangents at the cusps, 2 z1 z2/(z1 + z2)
    if(!geq(C0,gdiv(gmul(G(Q(2),Q(0)),gmul(z1,z2)),gadd(z1,z2))))bad.push('tangent route '+a+'/'+b+' '+c+'/'+d);
    // route 3: the Cayley image of the half-plane semicircle (endpoints x1 = a/b, x2 = c/d, top x0 + i·rho): its circumcentre
    if(b!==0n&&d!==0n){const x1=X.rat(a,b),x2=X.rat(c,d),x0=X.div(X.add(x1,x2),Q(2)),rho=X.div(X.qabs(X.sub(x1,x2)),Q(2));
      const top=cayley(G(x0,rho)),
        // circumcentre of z1, z2, top by the perpendicular-bisector formula (exact)
        ax=z1.re,ay=z1.im,bx=z2.re,by=z2.im,cx=top.re,cy=top.im,D=X.mul(Q(2),X.add(X.add(X.mul(ax,X.sub(by,cy)),X.mul(bx,X.sub(cy,ay))),X.mul(cx,X.sub(ay,by)))),
        s=(x,y)=>X.add(X.mul(x,x),X.mul(y,y)),ux=X.div(X.add(X.add(X.mul(s(ax,ay),X.sub(by,cy)),X.mul(s(bx,by),X.sub(cy,ay))),X.mul(s(cx,cy),X.sub(ay,by))),D),uy=X.div(X.add(X.add(X.mul(s(ax,ay),X.sub(cx,bx)),X.mul(s(bx,by),X.sub(ax,cx))),X.mul(s(cx,cy),X.sub(bx,ax))),D);
      if(!geq(G(ux,uy),C0))bad.push('semicircle route '+a+'/'+b+' '+c+'/'+d);}
  }
  ok('B2 Farey edges among the F₁₀ cusps in [−1, 1] and ∞: '+edges+' edges ('+diam+' diameter): centre (a − ib)(c − id)/(ac + bd), radius 1/|ac + bd|, |C|² = 1 + r² (orthogonal to the rim), through both cusp images, = tangent intersection 2ζ₁ζ₂/(ζ₁ + ζ₂) = circumcentre of the Cayley image of the half-plane semicircle; the 0—∞ edge is a diameter',edges===129&&diam===1&&bad.length===0,'edges '+edges+' '+bad.slice(0,4).join(' | '));
}
{ // B3. the shell's layer: F(a), contact graph, drawn data are exact
  let bad=[];
  for(const N of [2,5,10,12,17,26,30,50,60,101,120,360,720,5040]){const D=BD.disk(stN(N-1,0,2));
    const prof=D.prof.map(([p,e])=>p**e).reduce((a,b)=>a*b,1n);if(prof!==BigInt(N))bad.push('N='+N+' profile');
    const orders=D.prof.map(([,e])=>Number(e)+1),want=new Set();for(const n of orders)for(let k=1;k<n;k++){const g=Number(euclid(BigInt(k),BigInt(n)));want.add((k/g)+'/'+(n/g));}
    if(D.F.length!==want.size||!D.F.every(([p,q])=>want.has(p+'/'+q)))bad.push('N='+N+' F(a)');
    let E=0;for(let i=0;i<D.F.length;i++)for(let j=i+1;j<D.F.length;j++)if(euclid(D.F[i][0]*D.F[j][1]-D.F[j][0]*D.F[i][1],1n)===1n&&((D.F[i][0]*D.F[j][1]-D.F[j][0]*D.F[i][1])**2n)===1n)E++;
    if(D.edges.length!==E)bad.push('N='+N+' edges '+D.edges.length+' vs '+E);
    if(D.G.isolated!==D.G.deg.filter(x=>x===0).length)bad.push('N='+N+' isolated');}
  const d12=BD.disk(stN(11,0,2));
  ok('B3 F(a) (Lemma II.5g), contact edges |as − cq| = 1 (Def II.5h) and isolated beads for N = 2, 5, 10, 12, 17, 26, 30, 50, 60, 101, 120, 360, 720, 5040 equal an independent enumeration; N = 12 = 2²·3 has orders 3, 2: F = {1/3, 1/2, 2/3}, 2 edges',bad.length===0&&d12.F.map(x=>x.join('/')).join()==='1/3,1/2,2/3'&&d12.edges.length===2,bad.join(' | '));
}
{ // B4. Astra's points, n <= 30, against disk_checks.py run live
  const script='C:/Users/robin/s6_atom/POINCARE_DISK_VIEW_INVESTIGATION_v0_1_20261020/disk_checks.py';
  let out='',pyok=true;try{out=cp.execFileSync('python',['-I',script],{stdio:['ignore','pipe','pipe'],encoding:'utf8',timeout:120000});}catch(e){pyok=false;out=String(e);}
  ok('B4 disk_checks.py ran live (python -I, stdin closed): exit 0, "FAILURES: 0"',pyok&&/FAILURES: 0/.test(out));
  const m4=/C4 n = 1\.\.30: (\d+) pairs[^\n]*largest m = (\d+)/.exec(out);
  let pairs=0,maxm=0n,bad=[],rows=0;
  const py=new Map();for(const L of out.split('\n')){const mm=/n=\s*(\d+) m=\s*(\d+) k=\s*(\d+) \(a,b,c,d\)=\((-?\d+), (-?\d+), (-?\d+), (-?\d+)\)\s+zeta = (-?\d+)(?:\/(\d+))? \+ \((-?\d+)(?:\/(\d+))?\) i/.exec(L);if(mm)py.set(mm[1]+','+mm[2],mm);}
  for(let n=1;n<=30;n++){const N=BigInt(n*n+1),o=BD.orbit(N);if(!o.square||o.n!==BigInt(n)){bad.push('n='+n+' orbit');continue;}
    const divs=SH.divisors(N);if(o.pts.length!==divs.length)bad.push('n='+n+' pts');
    for(const p of o.pts){pairs++;if(p.m>maxm)maxm=p.m;const k=N/p.m;
      // exact formulas
      const z=G(X.rat(p.re,p.den),X.rat(p.im,p.den));
      if(!(p.k===k&&p.re===k-p.m&&p.im===-2n*BigInt(n)&&p.den===k+p.m+2n))bad.push('n='+n+' m='+p.m+' zeta formula');
      if(!X.eq(gn2(z),X.rat(k+p.m-2n,k+p.m+2n)))bad.push('n='+n+' m='+p.m+' |zeta|²');
      if(!X.eq(p.cosh,X.rat(k+p.m,2n)))bad.push('n='+n+' m='+p.m+' cosh');
      // the matrix: SL(2,Z), gamma i = (n + i)/m exactly (independent complex arithmetic), cosh = (a²+b²+c²+d²)/2
      const mt=p.matrix;if(!mt){bad.push('n='+n+' m='+p.m+' no matrix');continue;}
      const [a,b,c,d]=mt,gi=gdiv(gadd(gmul(G(X.rat(a),Q(0)),I),G(X.rat(b),Q(0))),gadd(gmul(G(X.rat(c),Q(0)),I),G(X.rat(d),Q(0))));
      if(a*d-b*c!==1n||!geq(gi,G(X.rat(BigInt(n),p.m),X.rat(1n,p.m))))bad.push('n='+n+' m='+p.m+' gamma i');
      if(!X.eq(X.rat(a*a+b*b+c*c+d*d,2n),p.cosh)||c*c+d*d!==p.m||euclid(c,d)!==1n||a*a+b*b!==k)bad.push('n='+n+' m='+p.m+' norms');
      // Cayley image of (n + i)/m equals zeta
      if(!geq(cayley(G(X.rat(BigInt(n),p.m),X.rat(1n,p.m))),z))bad.push('n='+n+' m='+p.m+' cayley');
      // the point lies on the Farey edge gamma(inf) = a/c, gamma(0) = b/d (exactly, in the disk)
      const e=BD.edge(a,c,b,d);
      if(e.diameter){
        // diameter through zeta: zeta is collinear with the antipodal cusps
        const z1=cayleyFrac(a,c),zz=z;if(!X.eq(X.sub(X.mul(zz.re,z1.im),X.mul(zz.im,z1.re)),Q(0)))bad.push('n='+n+' m='+p.m+' diameter');}
      else{const C0=G(X.rat(e.cre,e.den),X.rat(e.cim,e.den));if(!X.eq(gn2(gsub(z,C0)),X.rat(1n,e.den*e.den)))bad.push('n='+n+' m='+p.m+' on the Farey edge');}
      // against disk_checks.py (printed for n = 1, 2, 3, 7, 13): the same zeta
      const r=py.get(n+','+p.m);if(r){rows++;const f=(a,b)=>X.rat(BigInt(a),BigInt(b||1)),zp=G(f(r[8],r[9]),f(r[10],r[11]));if(!geq(zp,z))bad.push('n='+n+' m='+p.m+' vs python zeta');
        // python's matrix gives the same gamma i
        const [pa,pb,pc,pd]=[r[4],r[5],r[6],r[7]].map(BigInt);const gpy=gdiv(gadd(gmul(G(X.rat(pa),Q(0)),I),G(X.rat(pb),Q(0))),gadd(gmul(G(X.rat(pc),Q(0)),I),G(X.rat(pd),Q(0))));if(!geq(gpy,G(X.rat(BigInt(n),p.m),X.rat(1n,p.m))))bad.push('n='+n+' m='+p.m+' python matrix');}
      // mirror m <-> k: zeta(k, m) = -conj zeta(m, k); n -> -n is conj
      const mate=o.pts.find(q=>q.m===k);if(!mate||!(mate.re===-p.re&&mate.im===p.im&&mate.den===p.den))bad.push('n='+n+' m='+p.m+' mirror m<->k');}
  }
  ok('B4 Astra’s orbit, n = 1…30: '+pairs+' pairs (n, m), largest m '+maxm+' (disk_checks.py: '+(m4?m4[1]+' pairs, largest m '+m4[2]:'?')+'): ζ = (k − m − 2n·i)/(k + m + 2), |ζ|² = (k + m − 2)/(k + m + 2), cosh d = (k + m)/2 = (a² + b² + c² + d²)/2, an SL(2, ℤ) matrix with γi = (n + i)/m (independent complex arithmetic), Cayley image of (n + i)/m = ζ, ζ on the Farey edge a/c — b/d, mirror m ↔ k = ζ ↦ −ζ̄; '+rows+' rows equal the script’s printed ζ',
    pairs===124&&maxm===901n&&m4&&Number(m4[1])===124&&Number(m4[2])===901&&bad.length===0&&rows>=20,bad.slice(0,5).join(' | '));
}
{ // B5. idle cases and independence from the gears
  const a=BD.disk(stN(23,0,2)),b=BD.disk(C.initial({shellMode:'integer',B:'9',nMode:'continuous',phi3:'7/2'})),z=BD.disk(stN(9,10,2));
  ok('B5 N − 1 not a square (N = 24): the layer is drawn, orbit.square = false (labelled idle); non-integer N and N = 0: idle with the reason, no data',!a.idle&&a.orbit.square===false&&b.idle&&/between shells/.test(b.reason)&&z.idle&&/N = 0/.test(z.reason));
  const d1=BD.disk(shell(7)),d2=BD.disk(shell(7,{t1:'3/2',t2:'-5',alpha:'2/3',n6:'0',m:'30'})),dump=d=>JSON.stringify(d,(k,v)=>typeof v==='bigint'?String(v):v);
  ok('B5 the disk reads only the shell: unchanged by t₁, t₂, α, n₆, m',dump(d1)===dump(d2));
  const a1=BD.disk(C.initial({shellMode:'factorial',n1:'1',phi3:'0'}));   // N = 2 (B = 1) and B = 2
  ok('B5 N = 2 on the n! base (n₁ = 1, φ₃ = 0 gives N = 2 = 1² + 1): the orbit has m = 1, 2',a1.orbit.square&&a1.orbit.pts.length===2&&a1.orbit.n===1n);
}
{ // B6. the files that must not change are byte-identical to v0.4.9
  const same=['host-core/comb-core.js','host-core/orbit-core.js','host-core/comb-numeric.js','host-core/stack-core.js','host-core/fraction-stack-core.js','host-core/shell-core.js','host-core/gearbox-core.js','host-core/rhm-core.js','host-core/ca-core.js','exact-lib/exact-lib-0.2.0.js','instruments/comb-hopf/panel-g-robin.js','instruments/comb-hopf/view-fourier.js','instruments/comb-hopf/view-clifford.js','instruments/comb-hopf/view-hopf.js','instruments/comb-hopf/views-common.js'];
  const bad=same.filter(f=>sha(path.join(root,f))!==sha(path.join(V49,f)));
  ok('B6 '+same.length+' source files byte-identical to v0.4.9 (comb-core, orbit-core, comb-numeric, stack-core, shell-core, ca-core, exact-lib, panel-g-robin, the three tab views, views-common …)',bad.length===0,bad.join(','));
}
console.log('\nSUMMARY test-v0410: '+pass+' pass / '+fail+' fail');process.exit(fail?1:0);
