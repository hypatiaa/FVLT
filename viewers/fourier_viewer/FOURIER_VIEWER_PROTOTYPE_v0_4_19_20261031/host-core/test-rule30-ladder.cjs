'use strict';
// v0.4.16 (SCHEMA_ADDENDUM_23) core test for host-core/rule30-ladder-core.js: the fixture transcribed from the pinned rule30 output, F1, lift_iff,
// the antiperiodicity lemma on doubling rows, k(q, S_j) and the lifted curve. The reference orbit below is this test's own BigInt iteration (not the core's step).
const fs=require('fs'),path=require('path'),crypto=require('crypto');
const L=require('./rule30-ladder-core.js');
let pass=0,fail=0;
function t(name,fn){let ok=false,msg='';try{const r=fn();ok=r===true;if(!ok&&r!==false)msg=' '+r;}catch(e){msg=' threw: '+e.message;}console.log((ok?'PASS ':'FAIL ')+name+msg);ok?pass++:fail++;}
const FIX=path.join(__dirname,'..','fixtures','rule30-ladder-fixture.json'),fx=JSON.parse(fs.readFileSync(FIX,'utf8'));
const gcd=(a,b)=>{while(b){[a,b]=[b,a%b];}return a;},red=(n,d)=>{const g=gcd(n,d);return n/g+'/'+d/g;};
// own reference orbit: x(t) mod 2^35, iterated until it returns to 1
const M35=(1n<<35n)-1n;
const F={30:x=>x^((x<<1n)|(x<<2n)),90:x=>x^(x<<2n),150:x=>x^(x<<1n)^(x<<2n)};
const REF={};for(const r of [30,90,150]){const xs=[];let x=1n;do{xs.push(x);x=F[r](x)&M35;}while(x!==1n&&xs.length<100000);REF[r]=xs;}
const bit=(x,j)=>Number((x>>BigInt(j))&1n);
t('fixture source hashes recorded (densities 72d0bd14…, lemma fa24e806…, manifest 677bfe28…)',()=>fx.sources.map(s=>s.sha256.slice(0,8)).join()==='72d0bd14,fa24e806,677bfe28');
{const SRC='C:/Users/robin/s6_atom/rule30_prize_research_2026_10_26/';let seen=0,okh=true;
 for(const s of fx.sources){const f=SRC+path.basename(s.file);if(fs.existsSync(f)){seen++;if(crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex')!==s.sha256)okh=false;}}
 t('pinned sources still match their sha256 (read only; '+seen+' of 3 present)',()=>okh&&seen===3);}
for(const r of L.RULES){const R=fx.rules[r],T=L.table(r);
  t('rule '+r+': per_35 = '+R.per35+' (fixture) = core '+T.P+' = reference '+REF[r].length,()=>T.P===R.per35&&REF[r].length===R.per35);
  t('rule '+r+': core orbit = reference orbit mod 2^35 (all '+T.P+' states)',()=>T.xs.every((x,i)=>x===REF[r][i]));
  t('rule '+r+': per_{j+1} for every j = 0 … 34 matches the fixture',()=>{for(const w of R.rows)if(L.perN(r,w.j+1)!==w.per_j_plus_1)return 'j = '+w.j+': '+L.perN(r,w.j+1)+' vs '+w.per_j_plus_1;return true;});
  t('rule '+r+': ones over per_{j+1} for every j matches the fixture (and density, excess)',()=>{for(const w of R.rows){const o=L.ones(r,w.j,w.per_j_plus_1);
      if(o!==w.ones)return 'j = '+w.j+': '+o+' vs '+w.ones;if(red(o,w.per_j_plus_1)!==(w.density.includes('/')?w.density:w.density+'/1'))return 'density j = '+w.j;if(2*o-w.per_j_plus_1!==w.excess)return 'excess j = '+w.j;}return true;});
  t('rule '+r+': doubling set (j in 1 … 34) = fixture ['+R.doublings.join(', ')+']',()=>{const d=L.doublingSet(r).filter(j=>j>=1);return d.join()===R.doublings.join()&&d.length===R.doubling_count||d.join();});
  t('rule '+r+': j = 0 is a stall (per_0 = per_1 = 1, S_0 = 0, ψ_0 ≡ 0)',()=>L.perN(r,0)===1&&L.perN(r,1)===1&&L.S(r,0)===0&&T.psi[0].every(v=>v===0));
  t('rule '+r+': stall rows '+R.stall_rows+', of which density exactly 1/2: '+R.stall_rows_density_half,()=>{const st=R.rows.filter(w=>w.j>=1&&!R.doublings.includes(w.j));
    return st.length===R.stall_rows&&st.filter(w=>2*L.ones(r,w.j,w.per_j_plus_1)===w.per_j_plus_1).length===R.stall_rows_density_half;});
  t('rule '+r+': stall-row mean / max |ones − zeros|/per as printed ('+R.stall_mean_abs_excess_over_per_printed+', '+R.stall_max_abs_excess_over_per_printed+'; exact rational, rounded half-up to 4 places for the comparison only)',()=>{
    let n=0n,d=1n,mx=[0n,1n];const st=R.rows.filter(w=>w.j>=1&&!R.doublings.includes(w.j));
    for(const w of st){const e=BigInt(Math.abs(2*L.ones(r,w.j,w.per_j_plus_1)-w.per_j_plus_1)),p=BigInt(w.per_j_plus_1);n=n*p+e*d;d=d*p;if(e*mx[1]>mx[0]*p)mx=[e,p];}
    d*=BigInt(st.length);const r4=(a,b)=>{const v=(a*20000n+b)/(2n*b);return (v/10000n)+'.'+String(v%10000n).padStart(4,'0');};
    return r4(n,d)===R.stall_mean_abs_excess_over_per_printed&&r4(mx[0],mx[1])===R.stall_max_abs_excess_over_per_printed||r4(n,d)+' '+r4(mx[0],mx[1]);});
  t('rule '+r+': F1 A(j,t) = (A(j,0) + N_j(t)) mod 2 for all t < per_35, j ≤ 34 (A from the reference orbit)',()=>{
    for(let j=0;j<=34;j++){const a0=j===0?1:0;if(bit(REF[r][0],j)!==a0)return 'A(j,0) at j = '+j;
      for(let tt=0;tt<T.P;tt++){const a=bit(REF[r][tt],j);if(a!==L.A(r,j,tt))return 'A core j='+j+' t='+tt;if(a!==(a0+L.N(r,j,tt))%2)return 'F1 j='+j+' t='+tt;}}return true;});
  t('rule '+r+': N_j(t) by direct count of ψ_j(s) = 1 over s < t (ψ from the reference orbit) for t ≤ 2·per_35',()=>{
    const ps=(j,s)=>{const x=REF[r][s%T.P],a=j>=1?bit(x,j-1):0,b=j>=2?bit(x,j-2):0;return r===30?(a|b):r===90?b:(a^b);};
    for(let j=0;j<=34;j++){let c=0;for(let tt=0;tt<=2*T.P;tt++){if(c!==L.N(r,j,tt))return 'j='+j+' t='+tt;if(tt<2*T.P){if(ps(j,tt)!==L.psi(r,j,tt))return 'psi j='+j;c+=ps(j,tt);}}}return true;});
  t('rule '+r+': lift_iff per_{j+1} = 2·per_j ⇔ S_j odd (else per_{j+1} = per_j), every j ≤ 34',()=>{for(let j=0;j<=34;j++){const d=L.perN(r,j+1)===2*L.perN(r,j),s=L.perN(r,j+1)===L.perN(r,j);if(d!==(L.S(r,j)%2===1)||(d===s))return 'j='+j;}return true;});
  t('rule '+r+': S_j is the same from every starting point on the base cycle (all windows of length per_j, j ≤ 34)',()=>{for(let j=0;j<=34;j++){const p=L.perN(r,j);for(let a=0;a<p;a++)if(L.N(r,j,a+p)-L.N(r,j,a)!==L.S(r,j))return 'j='+j+' a='+a;}return true;});
  t('rule '+r+': antiperiodicity lemma on doubling rows: A(j, t + per_j) = 1 − A(j, t) for t < per_j, hence ones = per_{j+1}/2',()=>{
    for(const j of L.doublingSet(r)){const p=L.perN(r,j);for(let tt=0;tt<p;tt++)if(L.A(r,j,tt+p)!==1-L.A(r,j,tt))return 'j='+j+' t='+tt;if(2*L.ones(r,j,2*p)!==2*p)return 'density j='+j;}return fx.rules[r].lemma_all_doubling_rows===true;});
  t('rule '+r+': lifted curve closes after k = q/gcd(q,S_j) turns, and not earlier, for every j ≤ 34 and q ∈ {1,2,4,8}',()=>{
    for(let j=0;j<=34;j++)for(const q of L.QS){const c=L.curve(r,j,q),Sj=L.S(r,j),k=c.k,last=c.points[c.points.length-1];
      if(k!==q/gcd(q,Sj))return 'k j='+j+' q='+q;if(last.base[0]!==k||last.base[1]!==1||last.fibre[1]!==1||last.fibre[0]*q!==k*Sj)return 'end j='+j+' q='+q;
      for(let kk=1;kk<k;kk++)if((kk*Sj)%q===0)return 'earlier return kk='+kk+' j='+j+' q='+q;
      if(c.points.length!==c.steps+1)return 'count';}return true;});
  t('rule '+r+': lifted curve is monotone: base strictly increasing, fibre never decreasing, fibre step = 1/(q·sub) on events only (sub = 3, j ≤ 12)',()=>{
    for(let j=0;j<=12;j++)for(const q of L.QS){const c=L.curve(r,j,q,{sub:3});
      for(let i=1;i<c.points.length;i++){const a=c.points[i-1],b=c.points[i];
        if(!(b.base[0]*a.base[1]>a.base[0]*b.base[1]))return 'base j='+j;const df=[b.fibre[0]*a.fibre[1]-a.fibre[0]*b.fibre[1],a.fibre[1]*b.fibre[1]];
        if(df[0]<0)return 'fibre back j='+j;const want=a.event?1:0;if(df[0]*q*3!==want*df[1])return 'fibre step j='+j+' i='+i;}}return true;});
}
// the browser-check cases, exact
{const c=L.card(30,3,2);t('card rule 30, j = 3, q = 2: per_3 = 2, S_3 odd, closes after 2 turns, monodromy nontrivial (doubling)',()=>c.per===2&&c.S%2===1&&c.k===2&&c.monodromy==='monodromy nontrivial'&&c.doubling||JSON.stringify(c));}
{const c=L.card(30,5,2);t('card rule 30, j = 5, q = 2: S_5 even, closes after 1 turn, trivial (stall)',()=>c.S%2===0&&c.k===1&&c.monodromy==='trivial (stall)'&&!c.doubling||JSON.stringify(c));}
{const c=L.card(90,3,2);t('card rule 90, j = 3: density 0 and S_3 = 0 (pure base circle), both labelled',()=>c.S===0&&c.density[0]===0&&c.degenerate.some(d=>d.kind==='dens0')&&c.degenerate.some(d=>d.kind==='S0')||JSON.stringify(c));}
{const c=L.card(30,0,4);t('card j = 0: per_0 = 1, S_0 = 0, k = 1 at every q, labelled j0',()=>c.per===1&&c.S===0&&L.QS.every(q=>L.card(30,0,q).k===1)&&c.degenerate.some(d=>d.kind==='j0'));}
t('card q = 1: "fibre constant (q = 1)" and k = 1 for every rule and j',()=>L.RULES.every(r=>{for(let j=0;j<=34;j++){const c=L.card(r,j,1);if(c.k!==1||!c.degenerate.some(d=>d.label==='fibre constant (q = 1)'))return false;}return true;}));
t('card label text: "row 3, rule 30, q = 4: S_3 = 1, closes after 4 turns"',()=>L.card(30,3,4).label==='row 3, rule 30, q = 4: S_3 = 1, closes after 4 turns'||L.card(30,3,4).label);
t('dial refusals: rule 110, j = 35, q = 3 throw',()=>{let n=0;for(const f of [()=>L.card(110,3,2),()=>L.card(30,35,2),()=>L.card(30,3,3)])try{f();}catch(e){n++;}return n===3;});
t('the core has no float token and no DOM access (lexical check of the source, comments stripped)',()=>{const s=fs.readFileSync(path.join(__dirname,'rule30-ladder-core.js'),'utf8').replace(/\/\/.*$/gm,'');return !/Math\.(sin|cos|sqrt|PI|log|pow)|parseFloat|toFixed|\d\.\d|document|window/.test(s);});
console.log('SUMMARY test-rule30-ladder: '+pass+' passed, '+fail+' failed');
process.exitCode=fail?1:0;
