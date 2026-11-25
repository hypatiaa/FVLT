(function(root){
'use strict';
// Panels-tab card g-robin-margin (v0.4.4, SCHEMA_ADDENDUM_12). Panel module rules (view-panels.js header): reads the shared model M, writes nothing.
// A port of the frozen host panel RH_MARGIN_V0_1 (the accepted package MCOMB_FCA_M7_COMBINED_BCD_RH_MARGIN_v0_1_20261001, rhm-ui.js sha256 163098e3...,
// MANIFEST 3f562965...) with its exact core host-core/rhm-core.js, a byte copy of the accepted rhm-core.js (sha256 2a483c04...). The record is the accepted
// rh_atom_margins 0.1.0 for the shell base B of the shared model (never the orbit N). Exact values; certified outward enclosures of e^gamma ln ln B;
// margin = value minus threshold (Delta_R here); a NEGATIVE margin means Robin's inequality holds. Floating point is not used for any shown value.
// v0.4.4 additions on top of the port: the CA index, the holds/fails line, the caution line (Sol).
// Left out of the port and why: the embedded Web Worker with epoch/stale-result machinery and the 250 ms poll (a panel module renders synchronously from M; the
// build is deterministic, cached by its full input key, and measured at a few ms for the shown Bs; TIMING_CLARIFICATION.md: a worker is acceptable below 50 ms,
// the final-package cold main-thread maximum was 40.4 ms, individual measurements, no phone-runtime claim); the micro-button toggle (the Panels card is the toggle);
// McombRhMarginDiagnosticsV1 (test hooks; the browser check reads the DOM instead).
const V=root.FVViews,C=root.McombRhMarginCoreV1,CA=root.FVCa;
if(!V||!C||!CA)throw Error('G. Robin margin card: views, rhm-core or ca-core missing');
const BIT_CHOICES=['2','3','4','5','6','16','64','128','256'],DEFAULT_BITS='128';
const SUP={0:'⁰',1:'¹',2:'²',3:'³',4:'⁴',5:'⁵',6:'⁶',7:'⁷',8:'⁸',9:'⁹'};
const sup=s=>String(s).split('').map(c=>SUP[c]).join('');
const el=(tag,attrs={},text=null)=>{const e=document.createElement(tag);for(const [k,v] of Object.entries(attrs))e.setAttribute(k,v);if(text!==null)e.textContent=text;return e;};
const S={bits:DEFAULT_BITS},CACHE=new Map(),CACHE_MAX=64;
// Identity of an export from this card: the card cannot hash the page that contains it, so it names itself and pins the exact core it embeds.
const SOURCE=Object.freeze({host_build:'comb-hopf v0.4.4 Panels card g-robin-margin (embeds rhm-core.js of MCOMB_FCA_M7_COMBINED_BCD_RH_MARGIN_v0_1_20261001)',host_sha256:'2a483c04d35e6a41eafcfcedd717716e7299f2bd743ed084562b5ab92cd4fe62'});
const DEC_DIGITS={2:4,3:4,4:4,5:4,6:4,16:6,64:20,128:24,256:24},decDigits=b=>DEC_DIGITS[b]||24;
const ASKS={CRITERION_ASKS_VALUE_BELOW_THRESHOLD:'the criterion asks for the value BELOW the threshold',CRITERION_ASKS_VALUE_ABOVE_THRESHOLD:'the criterion asks for the value ABOVE the threshold'};
const SIDE_WORDS={ABOVE:'value above the threshold enclosure (margin > 0)',BELOW:'value below the threshold enclosure (margin < 0)',UNDECIDED_AT_PRECISION:'the margin enclosure contains 0 at this precision'};
const CAUTION=CA.CAUTION;
// inputs from the shared model: shell mode and n1 as the host seam did (integer -> direct; factorial -> factorial_index = n1, B = n1! checked in BigInt)
function inputsOf(M,bits){
  const st=M.st,B=String(M.R.B),mode=st.shellMode==='factorial'?'factorial':'direct';
  return {B,mode,factorial_index:mode==='factorial'?String(st.n1):null,precision_bits:bits};
}
function build(inp){
  const key=[inp.B,inp.mode,inp.factorial_index===null?'-':inp.factorial_index,inp.precision_bits].join('|');
  if(CACHE.has(key))return CACHE.get(key);
  let entry;
  try{const rec=C.buildAtom(inp),text=C.canonicalText(C.withSource(rec,SOURCE));entry={kind:'READY',rec,text};}
  catch(e){entry={kind:'REFUSED',refusal:(e&&e.name==='ContractError'?'RH-domain refusal':'build error')+' ('+(e&&e.message?e.message:String(e))+')'};}
  CACHE.set(key,entry);if(CACHE.size>CACHE_MAX)CACHE.delete(CACHE.keys().next().value);
  return entry;
}
const facText=rec=>(rec.atom.factors.length?rec.atom.factors.map(f=>(f.exponent==='1'?f.prime:f.prime+sup(f.exponent))).join('·'):'1 (empty product)');
function kvList(rows){const dl=el('dl',{class:'rhm-kv'});for(const [k,v,attrs] of rows){dl.append(el('dt',{},k));const dd=el('dd',attrs||{});if(typeof v==='string')dd.textContent=v;else dd.append(v);dl.append(dd);}return dl;}
function ivNode(iv,bits,id){
  const d=decDigits(bits),lo=C.parseRat(iv.lo),hi=C.parseRat(iv.hi),wrap=el('span',{id,'data-lo':iv.lo,'data-hi':iv.hi});
  wrap.append(el('span',{class:'rhm-exact'},'['+C.decimal(lo,d,'floor')+', '+C.decimal(hi,d,'ceil')+']'),' ');
  const det=el('details');det.append(el('summary',{},'exact endpoints'),el('pre',{class:'rhm-exact'},'lo = '+iv.lo+'\nhi = '+iv.hi));wrap.append(det);return wrap;
}
function valueNode(v,bits,id){const d=decDigits(bits),x=C.parseRat(v),s=el('span',{id,class:'rhm-exact','data-value':v});s.textContent=v+'  (≈ '+C.decimal(x,d,'floor')+'…)';return s;}
function criterionBox(key,blk,rec,host){
  const bits=rec.precision_bits,box=el('div',{class:'rhm-box',id:'rhm-'+key}),id='rhm-'+key;
  box.append(el('h4',{},key==='c1'?'C1 · G. Robin (1984) criterion · σ(B)/B':'C2 · Nicolas (1983) criterion · B/φ(B)'),el('div',{class:'rhm-dim',id:id+'-statement'},blk.criterion_statement));
  const rows=[['value',valueNode(blk.value,bits,id+'-value')]];
  if(blk.applicability==='DOMAIN_UNAVAILABLE'){
    rows.push(['threshold',el('span',{id:id+'-threshold',class:'rhm-dim','data-absent':'true'},'absent (ln ln B is undefined at B = 1)')]);
    rows.push(['margin Δ_R (value minus threshold)',el('span',{id:id+'-margin',class:'rhm-dim','data-absent':'true'},'absent')]);
    rows.push(['side',el('span',{id:id+'-side',class:'rhm-verdict rhm-dim','data-absent':'true'},'no side at B = 1')]);
  }else{
    rows.push(['threshold e^γ ln ln B (numerical)',ivNode(blk.threshold,bits,id+'-threshold')]);
    rows.push(['margin Δ_R (value minus threshold, numerical)',ivNode(blk.margin,bits,id+'-margin')]);
    const scoped=blk.applicability==='IN_RANGE'?'':' · numerical value only',sd=el('span',{id:id+'-side',class:'rhm-verdict','data-side':blk.side});
    sd.append(el('span',{class:'rhm-badge '+(blk.side==='UNDECIDED_AT_PRECISION'?'rhm-warn':'')},blk.side),' '+SIDE_WORDS[blk.side]+scoped);rows.push(['side',sd]);
  }
  rows.push(['what it asks',el('span',{id:id+'-direction',class:'rhm-verdict','data-direction':blk.criterion_direction},ASKS[blk.criterion_direction]+' ('+blk.criterion_direction+')')]);
  rows.push(['applicability',el('span',{id:id+'-applicability',class:'rhm-verdict','data-applicability':blk.applicability},blk.applicability+': '+blk.applicability_note)]);
  if(key==='c1'){const vd=blk.side==='BELOW'?'holds (\u0394_R < 0)':blk.side==='ABOVE'?'fails (\u0394_R \u2265 0)':blk.side==='UNDECIDED_AT_PRECISION'?'undecided at this precision':'not defined at B = 1';
    rows.push(['Robin inequality \u03c3(B)/B < e^\u03b3 ln ln B at this B',el('span',{id:'rhm-ca-verdict','data-side':blk.side||''},blk.side?vd+' \u00b7 read with the applicability line: the criterion quantifies N > 5040 only':vd)]);}
  if(key==='c1'&&blk.boundary_note)rows.push(['boundary note',el('span',{id:id+'-boundary'},blk.boundary_note)]);
  if(key==='c2'){rows.push(['primorial_k',el('span',{id:id+'-k'},blk.primorial_k===null?'null (B is not a primorial N_k)':blk.primorial_k)]);if(blk.convention_note)rows.push(['k = 1 note',el('span',{id:id+'-k1'},blk.convention_note)]);}
  box.append(kvList(rows));return box;
}
function factorsBox(rec){
  const box=el('div',{class:'rhm-box rhm-wide',id:'rhm-factors'});box.append(el('h4',{},'Per-prime factors (display only, exact; not exported)'));
  let ps=C.F(1n),pe=C.F(1n);
  if(rec.atom.factors.length){
    const t=el('table',{id:'rhm-factor-table'}),hr=el('tr');
    ['p','a','σ(pᵃ)/pᵃ = (pᵃ⁺¹ − 1)/(pᵃ(p − 1))','Euler factor p/(p − 1)'].forEach(h=>hr.append(el('th',{},h)));t.append(hr);
    for(const f of rec.atom.factors){const p=BigInt(f.prime),a=BigInt(f.exponent),s=C.F(p**(a+1n)-1n,p**a*(p-1n)),e=C.F(p,p-1n);ps=C.mul(ps,s);pe=C.mul(pe,e);
      const tr=el('tr',{'data-p':f.prime,'data-a':f.exponent,'data-sigma':C.enc_rat(s),'data-euler':C.enc_rat(e)});
      tr.append(el('td',{},f.prime),el('td',{},f.exponent),el('td',{class:'rhm-exact'},C.enc_rat(s)),el('td',{class:'rhm-exact'},C.enc_rat(e)));t.append(tr);}
    box.append(el('div',{class:'rhm-scroll'}));box.lastChild.append(t);
  }else box.append(el('div',{class:'rhm-dim',id:'rhm-factor-table'},'no primes (B = 1): both products are the empty product 1'));
  const okS=C.enc_rat(ps)===rec.c1.value,okE=C.enc_rat(pe)===rec.c2.value;
  box.append(el('div',{id:'rhm-factor-check',class:okS&&okE?'rhm-good':'rhm-bad','data-sigma-product':C.enc_rat(ps),'data-euler-product':C.enc_rat(pe),'data-equal':String(okS&&okE)},
    'check: ∏ σ(pᵃ)/pᵃ = '+C.enc_rat(ps)+' '+(okS?'equals':'DIFFERS FROM')+' c1.value = '+rec.c1.value+'; ∏ p/(p − 1) = '+C.enc_rat(pe)+' '+(okE?'equals':'DIFFERS FROM')+' c2.value = '+rec.c2.value+' (exact rationals).'));
  return box;
}
function constantsBox(rec){
  const box=el('div',{class:'rhm-box rhm-wide',id:'rhm-constants'}),c=rec.constants,bits=rec.precision_bits;box.append(el('h4',{},'Constants and enclosure parameters (numerical, certified outward enclosures)'));
  if(c.availability!=='AVAILABLE'){box.append(el('div',{class:'rhm-dim',id:'rhm-const-availability','data-availability':c.availability},c.availability+': ln ln B is undefined at B = 1; no enclosures are carried.'));return box;}
  box.append(kvList([['availability',el('span',{id:'rhm-const-availability','data-availability':c.availability},c.availability)],
    ['γ (Euler–Mascheroni constant γ)',ivNode(c.gamma,bits,'rhm-const-gamma')],['e^γ',ivNode(c.exp_gamma,bits,'rhm-const-exp-gamma')],['ln B',ivNode(c.ln_B,bits,'rhm-const-ln-b')],['ln ln B',ivNode(c.ln_ln_B,bits,'rhm-const-ln-ln-b')],
    ['Euler–Maclaurin n, m',el('span',{class:'rhm-exact',id:'rhm-const-em'},'n = '+c.em_n+', m = '+c.em_m)],['remainder bound',el('span',{class:'rhm-exact',id:'rhm-const-em-r'},c.em_remainder_bound)],
    ['working bits',el('span',{class:'rhm-exact',id:'rhm-const-wb'},c.working_bits+' (precision_bits '+bits+' + 64 guard bits)')],['method',el('span',{class:'rhm-dim'},rec.enclosure_method.method_id)]]));
  return box;
}
function render(body,M){
  const det=body.closest('details'),open=!det||det.open;
  body.textContent='';
  const root_=el('div',{class:'rhm'});body.append(root_);
  const inp0=inputsOf(M,S.bits);
  root_.append(el('h3',{class:'rhm-h3'},'G. Robin (1984) and Nicolas (1983) margins of the host shell base B'));
  root_.append(el('p',{class:'note rhm-dim'},'The accepted record rh-criteria-readout 0.1.0 (kind rh_atom_margins) for the shell base B of the host (never the orbit N): σ(B)/B against the certified enclosure of e^γ ln ln B (G. Robin 1984), B/φ(B) against the same threshold (Nicolas 1983). Exact values; margin Δ_R = value minus threshold; negative means Robin’s inequality holds. Reads the host only; never writes it.'));
  if(!open){root_.append(el('p',{class:'note dim'},'Open the card to compute the record for B = '+inp0.B+'.'));
    if(det&&!det._rhmBound){det._rhmBound=true;det.addEventListener('toggle',()=>{if(det.open)render(body,M);});}return;}
  if(det&&!det._rhmBound){det._rhmBound=true;det.addEventListener('toggle',()=>{if(det.open)render(body,M);});}
  const row=el('div',{class:'rhm-row'}),lab=el('label',{},'precision_bits '),sel=el('select',{id:'rhm-bits',title:'output grid 2^-precision_bits'});
  for(const b of BIT_CHOICES){const o=el('option',{value:b},b===DEFAULT_BITS?b+' (default)':b);if(b===S.bits)o.selected=true;sel.append(o);}lab.append(sel);
  const exp=el('button',{id:'rhm-export',type:'button',title:'Download the record as its canonical JSON bytes, bound to the current atom and precision'},'export record (canonical JSON)'),msg=el('span',{id:'rhm-export-msg',class:'rhm-dim'});
  row.append(lab,exp,msg);root_.append(row);
  const inp=inputsOf(M,S.bits),entry=build(inp),status=el('div',{id:'rhm-status',role:'status','aria-live':'polite',class:'rhm-row'});root_.append(status);
  sel.addEventListener('change',()=>{S.bits=sel.value;render(body,M);});
  sel.addEventListener('keydown',e=>e.stopPropagation());
  if(entry.kind==='REFUSED'){
    status.className='rhm-row rhm-bad';status.textContent=entry.refusal+' for B = '+inp.B+'. The record’s domain is 1 ≤ B ≤ 2^256 − 1 with primes ≤ 10^6, exponents ≤ 64, at most 16 primes. Nothing is shown for this atom; export is blocked.';exp.disabled=true;
    root_.append(el('p',{class:'note warn',id:'rhm-caution-refused'},CAUTION));return;}
  const rec=entry.rec;
  status.className='rhm-row rhm-good';status.textContent='record for B = '+inp.B+' ('+inp.mode+(inp.factorial_index?', '+inp.factorial_index+'!':'')+') at precision_bits '+inp.precision_bits+': built by the BigInt port of the accepted reference.';
  const scope=el('div',{class:'rhm-box'});scope.append(el('div',{class:'rhm-exact',id:'rhm-scope'},C.SCOPE),el('div',{class:'rhm-exact',id:'rhm-rh-status'},'rh_status: '+C.RH_STATUS),el('div',{class:'rhm-exact',id:'rhm-ca-caution','data-role':'ca-caution'},CAUTION));root_.append(scope);
  const grid=el('div',{class:'rhm-grid'});root_.append(grid);
  const atom=el('div',{class:'rhm-box rhm-wide',id:'rhm-atom'});const caI=CA.CA_PRESETS.findIndex(b=>b===BigInt(inp.B)),caTxt=caI>=0?'CA #'+(caI+1)+' of the '+CA.CA_PRESETS.length+' presets':'not one of the '+CA.CA_PRESETS.length+' CA presets';
  atom.append(el('h4',{},'Atom'),el('div',{class:'rhm-exact',id:'rhm-atom-line'},'B = '+(inp.mode==='factorial'?inp.factorial_index+'! = ':'')+rec.atom.B+' = '+facText(rec)+' · mode '+(M.ca?'CA (record mode '+rec.atom.mode+', host integer base from the CA presets)':rec.atom.mode+(inp.mode==='direct'?' (host integer shell M)':' (host factorial shell n₁!)'))+' · factorial_index '+(inp.factorial_index===null?'null':inp.factorial_index)+' · precision_bits '+inp.precision_bits),el('div',{class:'rhm-exact',id:'rhm-ca-index'},'CA track: '+caTxt));
  grid.append(atom,criterionBox('c1',rec.c1,rec),criterionBox('c2',rec.c2,rec),factorsBox(rec),constantsBox(rec));
  const bytes=el('details',{id:'rhm-bytes'});bytes.append(el('summary',{},'canonical bytes of the current export (source = this card’s identity)'),el('pre',{id:'rhm-bytes-text',class:'rhm-exact'},entry.text));root_.append(bytes);
  root_.append(el('div',{class:'rhm-dim',id:'rhm-credits'},'Idea: saphir. Criteria mapping: Opus. Specification, corrections and audits: Astra. Handoff: fable (Claude). Panel: RH margin builder (Claude). Record schema 0.1.0, unchanged.'),el('div',{class:'rhm-dim',id:'rhm-credits-port'},'Port into the Fourier viewer v0.4.4: builder (Claude).'));
  exp.addEventListener('click',()=>{const u=URL.createObjectURL(new Blob([entry.text],{type:'application/json'})),a=el('a',{href:u,download:'rh-atom-margins-B'+inp.B+'-'+inp.mode+'-bits'+inp.precision_bits+'.json'});
    document.body.append(a);a.click();a.remove();setTimeout(()=>URL.revokeObjectURL(u),1000);msg.textContent='exported rh-atom-margins-B'+inp.B+'-'+inp.mode+'-bits'+inp.precision_bits+'.json';});
}
const ABOUT='register: mixed (exact σ(B)/B, B/φ(B) and factorization; numerical certified enclosures of e^γ ln ln B) · state coupling: reads B · rebuilt in v0.4.4 as a port of the frozen host panel RH_MARGIN_V0_1 (L23123–23877) from the accepted package MCOMB_FCA_M7_COMBINED_BCD_RH_MARGIN_v0_1_20261001 (rhm-core.js 2a483c04…, MANIFEST 3f562965…, record rh_atom_margins 0.1.0); worker and poll not ported (see source header)';
root.FVRobinCard={render,build,inputsOf,ABOUT,SOURCE,CACHE};
})(typeof globalThis!=='undefined'?globalThis:this);
