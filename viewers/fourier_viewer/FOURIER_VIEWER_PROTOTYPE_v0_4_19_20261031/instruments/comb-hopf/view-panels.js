(function(root){
'use strict';
// Panels tab (addendum 4): the host's lower panels, each a module { id, title, group, register, coupling, source, render(el,model), actions }.
// v0.1: every card is a labelled placeholder; no panel mathematics is ported. A panel reads the shared model M and changes shared state
// only through M.commit.spin(raw) (typed entry, R21) or M.commit.dial(patch) (dial change); it never writes another module's state (R9).
// Excluded: the Alpoge rank-4 card (separate future viewer). Rank-4 monodromy: separate future viewer (saphir, 2026-10-13).
const V=root.FVViews,H='frozen source: host ';
V.panelModules=[];
V.registerPanel=function(p){V.panelModules.push(p);};
const G={A:'A. Comb and contacts',B:'B. Shell and divisor arithmetic',C:'C. Mcomb atom, Cayley and divisor concepts',D:'D. Elliptic and BSD',E:'E. Surface pens (exact)'};   // v0.4.18: the D heading as decided (placement stays in this viewer); group E, the surface pens
[
 ['A','orbit-point-index','Orbit point index','Nearby generated orbit addresses with exact θ₁/π and β/π.','exact','writes s (±Δs) and the foliation β','OrbitPointIndexV26 L11360+'],
 ['A','contact-sweep','◎ Contact sweep','Exact real-axis contacts of the lower tooth over shells 2…Q+1 (schema fourier_contact_sweep_snapshot 0.2.0).','exact','writes s, t₁, t₂ (Seek, Apply canonical)','CONTACT_SWEEP_V0_1_1 L19032–19929'],
 ['A','tooth-contacts','⋔ Tooth contacts','Contacts for the selected teeth c (k = N + c).','exact','writes s (Place, Seek)','COMBINED_BCD_V0_1_TOOTH_CONTACT L21926–23122'],
 ['B','basel-cone','∑ Basel cone','Z_B(β) over the divisors of B, divisor lattice and the π(x) staircase.','mixed','reads B only','BASEL_LINK_V0_1_2 L19930–20625'],
 ['B','reciprocal-record','Reciprocal record','Prime-labelled factors of the selected divisor (schema 0.1.0, canonical JSON).','exact','reads the selected divisor','COMBINED_BCD_V0_1_RECIPROCAL L20626–21088'],
 ['B','pi-b-shell','π(B) shell prime count','Prime count readout on the shell (schema shell_prime_count_readout).','exact','reads B, t₁, t₂, n₆','COMBINED_BCD_V0_1_SHELL_PRIME_COUNT L21089–21925'],
 ['B','g-robin-margin','G. Robin margin','σ(B)/B against the certified enclosure of e^γ ln ln B, plus the Nicolas test (schema rh_atom_margins 0.1.0).','mixed','reads B','RH_MARGIN_V0_1 L23123–23877'],
 ['C','cayley-m3','Cayley graph & kernel · M3','Exact Cayley record of the host state (export mcomb-cayley-m3-capture.json).','exact','reads the host state','MCOMB_CAYLEY_V1 L17215–17409'],
 ['C','m4-atom','Atom explorer · exact divisor addresses (M4)','Exact divisor addresses of the atom. Divisor-atom tab candidate together with the M7 card.','exact','reads the host state','L18557–18732; summary at L18559'],
 ['C','m5-structure','M5 structure','Structure setting (export mcomb-m5-structure-setting.json).','exact','reads the host state','L18732+'],
 ['C','m6-walk','M6 shell walk','Shell walk setting (export mcomb-m6-walk-setting.json).','exact','reads the host state','L18813+'],
 ['C','m7-divisor-atom','Divisor concepts · FCA and order-aware walks · M7 (the divisor atom)','Divisor lattice as exponent tuples; FCA contexts (ordinal, Birkhoff, nominal, strand); Hasse views; fixed-coordinate faces. Candidate for its own tab.','exact','reads the host state','McombFCAV1 to L18951; divisorPosition L18955–18971; schema MCOMB_FCA_CONTEXT_V1'],
 ['D','mcomb-elliptic-bsd','Mcomb → elliptic curve → BSD','Link from the comb to an elliptic curve and BSD evidence.','mixed','reads the host state','MCOMB_ELLIPTIC_LINK_V1 L16721–16930'],
 ['D','carrier-addition','Carrier addition','Carrier addition on the curve.','mixed','reads the host state','MCOMB_CARRIER_ADDITION_V1 L17023–17193'],
 ['D','exact-curve-bsd','Exact curve · BSD evidence (children: prime counts, PT1, U1, P1, Spectral)','Exact curve record and linked BSD evidence views.','mixed','reads the host state','BSD_CURVE_RECORD_V1 L16444–16673; BSD_LINKED_VIEW_V1 L17411–18908'],
 ['D','clifford-elliptic-bridge','Clifford elliptic bridge','Elliptic bridge to the Clifford leaf.','mixed','writes the Clifford leaf','ELLIPTIC_BRIDGE_V27 L16100–16406'],
 ['D','arithmetic-fourier','Arithmetic–Fourier','Arithmetic coefficients against the exact curve model; its atom n is its own input.','mixed','reads the exact curve model','ARITHMETIC_FOURIER_V0_1 L23878–25361']
].forEach(([group,id,title,description,register,coupling,src])=>V.registerPanel({id,title,group,description,register,coupling,source:H+src,actions:[],
  about:'register: '+register+' · state coupling: '+coupling+' · not yet rebuilt — '+H+src,
  render(el,model){el.innerHTML='<p class="note">'+V.esc(description)+'</p><p class="note warn">not yet rebuilt</p>'+V.aboutBlock('panel:'+id,'register: '+register+' · state coupling: '+coupling+' · '+H+src);}}));
// v0.4.4: the one rebuilt card, g-robin-margin (panel-g-robin.js, a port of the accepted RH margin panel); every other card stays a placeholder
{const p=V.panelModules.find(x=>x.id==='g-robin-margin'),R=root.FVRobinCard;
 if(p&&R){p.description='The accepted rh_atom_margins 0.1.0 record for B: σ(B)/B against the certified enclosure of e^γ ln ln B (G. Robin), the Nicolas test B/φ(B), exact factors, constants; holds/fails and the colossally abundant track index.';p.source=H+'RH_MARGIN_V0_1 L23123–23877; accepted package MCOMB_FCA_M7_COMBINED_BCD_RH_MARGIN_v0_1_20261001 (rhm-core.js 2a483c04…)';p.about=R.ABOUT;p.render=(el,model)=>R.render(el,model);}}
const KEY='fv-comb-hopf-panels-open';
function loadOpen(){try{return JSON.parse(localStorage.getItem(KEY)||'{}')||{};}catch(e){return {};}}
function saveOpen(o){try{localStorage.setItem(KEY,JSON.stringify(o));}catch(e){}}
V.register({
  id:'panels',label:'Panels',kind:'html',defaults:{pn:'1'},
  toolbar(){return [{id:'collapse',label:'Collapse panels',menu:'strip'},{id:'open',label:'Open panels',menu:'strip'}];},
  act(id){if(id==='collapse'||id==='open'){const o={};if(id==='open')for(const p of V.panelModules)if(p.collapsed)o[p.id]=true;saveOpen(o);return {vs:{pn:id==='open'?'1':'0'}};}return {};},   // v0.4.10: cards with collapsed:true start closed; "Open panels" opens them too
  gesture(){return {};},
  renderHtml(el,M,vs){
    const saved=loadOpen();let html='';
    for(const g of Object.keys(G)){
      html+='<div class="panel-label" style="margin-top:10px">'+V.esc(G[g])+'</div>';
      for(const p of V.panelModules.filter(x=>x.group===g)){
        const open=p.id in saved?saved[p.id]:(p.collapsed?false:vs.pn==='1');
        html+='<details class="pmod" data-panel="'+p.id+'"'+(open?' open':'')+'><summary>'+V.esc(p.title)+'</summary><div data-body="'+p.id+'"></div></details>';}}
    el.innerHTML=html;
    for(const p of V.panelModules){const body=el.querySelector('[data-body="'+p.id+'"]');if(body)p.render(body,M);}
    el.querySelectorAll('details.pmod').forEach(d=>d.addEventListener('toggle',()=>{const o=loadOpen();o[d.dataset.panel]=d.open;saveOpen(o);}));
  }
});
})(typeof globalThis!=='undefined'?globalThis:this);
