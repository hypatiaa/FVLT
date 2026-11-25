'use strict';
// v0.4.17 (SCHEMA_ADDENDUM_24): transcribes fixtures/elliptic-37a1-fixture.json from the Sage reference text in the brief folder.
// A parser, not a recomputation: it checks the source sha256 first, then reads each line by a fixed pattern and fails on anything it does not recognise.
// No floating point: every value stays a string or a BigInt-checked integer string.
const fs=require('fs'),path=require('path'),crypto=require('crypto');
const SRC='C:/Users/robin/s6_atom/FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029_BRIEF/SAGE_REFERENCE_37a1_20261029.txt';
const PIN='599c68552af2521c0b762298875c922e4c03aef29ae7ad4573af614642ab6a72';
const buf=fs.readFileSync(SRC),h=crypto.createHash('sha256').update(buf).digest('hex');
if(h!==PIN)throw Error('source sha256 mismatch: '+h);
const lines=buf.toString('utf8').split(/\r?\n/);
const find=re=>{const hits=lines.map(l=>re.exec(l)).filter(Boolean);if(hits.length!==1)throw Error('expected one line for '+re+' (got '+hits.length+')');return hits[0];};
const intS=s=>{s=s.trim();if(!/^-?[0-9]+$/.test(s))throw Error('not an integer: '+s);return s;};
const ratS=s=>{s=s.trim();if(!/^-?[0-9]+(\/[0-9]+)?$/.test(s))throw Error('not a rational: '+s);return s;};
const decS=s=>{s=s.trim();if(!/^-?[0-9]+\.[0-9]+$/.test(s))throw Error('not a decimal string: '+s);return s;};
const pairs=s=>[...s.matchAll(/\(([0-9]+), (-?[0-9]+)\)/g)].map(m=>[intS(m[1]),intS(m[2])]);
if(!lines[0].startsWith('# Independent reference for curve 37a1'))throw Error('unexpected header');   // the sha256 pin above already fixes every byte
const fx={schema:'fv-elliptic-fixture/0_1',curve:'37a1',
  source:{file:'FOURIER_VIEWER_PROTOTYPE_v0_4_17_20261029_BRIEF/SAGE_REFERENCE_37a1_20261029.txt',sha256:PIN,header:[lines[0],lines[1],lines[2]].map(l=>l.replace(/^# ?/,''))},
  transcribed_by:'build/transcribe-elliptic-fixture.cjs (parser only)'};
{const m=find(/^ainvs \(a1,a2,a3,a4,a6\) = \(([^)]*)\)/);fx.ainvs=m[1].split(',').map(intS);if(fx.ainvs.length!==5)throw Error('ainvs');}
{const m=find(/^conductor = (\d+) ; discriminant = (-?\d+) ; rank = (\d+)$/);fx.conductor=intS(m[1]);fx.discriminant=intS(m[2]);fx.rank=intS(m[3]);}
{const m=find(/^b-invariants \(b2,b4,b6,b8\) = \(([^)]*)\) ; c4 = (-?\d+) ; c6 = (-?\d+)$/);const b=m[1].split(',').map(intS);fx.b2=b[0];fx.b4=b[1];fx.b6=b[2];fx.b8=b[3];fx.c4=intS(m[2]);fx.c6=intS(m[3]);}
{const m=find(/^short Weierstrass model: y\^2 = x\^3 - (\d+)\*x \+ (\d+), via \(u,r,s,t\) = \(([^)]*)\)$/);fx.short_model={a4:'-'+intS(m[1]),a6:intS(m[2]),urst:m[3].split(',').map(ratS)};}
{const m=find(/^generator \(Sage E\.gens\(\)\[0\]\) P = \((-?\d+), (-?\d+)\)$/);fx.generator={x:intS(m[1]),y:intS(m[2])};}
{const i=lines.findIndex(l=>/^multiples kP, k = 1\.\.10/.test(l));if(i<0)throw Error('multiples');fx.multiples=[];
  for(let k=1;k<=10;k++){const m=/^(\d+) \((-?[0-9/]+), (-?[0-9/]+)\)$/.exec(lines[i+k]);if(!m||m[1]!==String(k))throw Error('multiple line '+k+': '+lines[i+k]);fx.multiples.push({k:m[1],x:ratS(m[2]),y:ratS(m[3])});}}
{const i=lines.findIndex(l=>/^a_p for p < 100/.test(l));fx.ap=pairs(lines[i+1]).map(([p,a])=>({p,ap:a}));if(fx.ap.length!==25)throw Error('ap count '+fx.ap.length);}
{const i=lines.findIndex(l=>/^#E\(F_p\) for good p < 100/.test(l));fx.Np=pairs(lines[i+1]).map(([p,n])=>({p,N:n}));if(fx.Np.length!==24)throw Error('Np count '+fx.Np.length);}
{const i=lines.findIndex(l=>/^E\(F_p\) abelian invariants, 3 <= p < 60, p != 37 \(all cyclic\):$/.test(l));const ms=[...lines[i+1].matchAll(/\((\d+), \(([0-9, ]+)\)\)/g)];
  fx.abelian_invariants={range:'3 <= p < 60, p != 37',source_says:'all cyclic',rows:ms.map(m=>({p:intS(m[1]),invariants:m[2].split(',').map(x=>x.trim()).filter(Boolean).map(intS)}))};if(fx.abelian_invariants.rows.length!==15)throw Error('abelian rows');}
{find(/^2-division polynomial 4x\^3 \+ b2 x\^2 \+ 2 b4 x \+ b6 = 4\*x\^3 - 4\*x \+ 1, real roots e1 > e2 > e3:$/);fx.two_division='4*x^3 - 4*x + 1';
  for(const k of ['e1','e2','e3'])fx[k]=decS(find(new RegExp('^'+k+' = (-?[0-9.]+)$'))[1]);}
fx.w1=decS(find(/^w1   = ([0-9.]+)$/)[1]);
fx.w2_over_i=decS(find(/^w2\/i = ([0-9.]+)$/)[1]);
fx.Omega=decS(find(/^E\.period_lattice\(\)\.omega\(\) \(real period, = 2\*w1 since E\(R\) has two components\) = ([0-9.]+)$/)[1]);
const places=s=>s.split('.')[1].length;
fx.decimal_places={e1:places(fx.e1),e2:places(fx.e2),e3:places(fx.e3),w1:places(fx.w1),w2_over_i:places(fx.w2_over_i),Omega:places(fx.Omega)};
fx.note_Omega='the Omega string in the source has fewer places than the others (see decimal_places); it is compared at its own last place, and Omega = 2*w1 is also checked against w1';
const out=path.join(__dirname,'..','fixtures','elliptic-37a1-fixture.json');
fs.writeFileSync(out,JSON.stringify(fx,null,1)+'\n');
console.log('wrote '+path.relative(path.join(__dirname,'..'),out)+' sha256 '+crypto.createHash('sha256').update(fs.readFileSync(out)).digest('hex'));
console.log('decimal places '+JSON.stringify(fx.decimal_places));
