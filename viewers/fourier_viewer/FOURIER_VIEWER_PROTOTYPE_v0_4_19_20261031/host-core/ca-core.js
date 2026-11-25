(function(root){
'use strict';
// fv-ca-core 0.1.0 (v0.4.4, SCHEMA_ADDENDUM_12): the colossally abundant (CA) preset track and its Robin readout. EXACT register for sigma(B)/B;
// NUMERICAL register (certified outward enclosure, 64 bits) for e^gamma ln ln B. Display only; nothing here touches the state.
// The enclosure and the record come from host-core/rhm-core.js, a byte copy of the accepted G. Robin margin panel's rhm-core.js
// (sha256 2a483c04d35e6a41eafcfcedd717716e7299f2bd743ed084562b5ab92cd4fe62, MCOMB_FCA_M7_COMBINED_BCD_RH_MARGIN_v0_1_20261001, record rh_atom_margins 0.1.0).
const RH=typeof module!=='undefined'&&module.exports?require('./rhm-core.js'):root.McombRhMarginCoreV1;
const CA_PRESETS=Object.freeze([2n,6n,12n,60n,120n,360n,2520n,5040n,55440n,720720n]);
const BITS='64',DIGITS=6;
const CAUTION='Caution: this shows Robin’s inequality at these particular numbers only. It says nothing about the general case or about RH.';
const cache=new Map();
// record: the accepted builder's rh_atom_margins for B (direct mode); the c1 block carries value, threshold, margin, side.
function robinReadout(B){
  B=BigInt(B);const key=B.toString();if(cache.has(key))return cache.get(key);
  const rec=RH.buildAtom({B:key,mode:'direct',factorial_index:null,precision_bits:BITS}),c=rec.c1;
  const val=RH.parseRat(c.value),th=[RH.parseRat(c.threshold.lo),RH.parseRat(c.threshold.hi)],mg=[RH.parseRat(c.margin.lo),RH.parseRat(c.margin.hi)];
  const holds=c.side==='BELOW',fails=c.side==='ABOVE';
  const r=Object.freeze({B:key,sigmaOverB:c.value,value:val,thresholdIv:c.threshold,marginIv:c.margin,side:c.side,holds,fails,undecided:!holds&&!fails,
    thresholdText:'['+RH.decimal(th[0],DIGITS,'floor')+', '+RH.decimal(th[1],DIGITS,'ceil')+']',
    marginText:'['+RH.decimal(mg[0],DIGITS,'floor')+', '+RH.decimal(mg[1],DIGITS,'ceil')+']',
    verdict:holds?'holds':fails?'fails':'undecided at this precision',precisionBits:BITS,digits:DIGITS,caution:CAUTION});
  cache.set(key,r);return r;
}
const api={CA_PRESETS,CAUTION,BITS,DIGITS,robinReadout,isPreset:B=>CA_PRESETS.includes(BigInt(B))};
if(typeof module!=='undefined'&&module.exports)module.exports=api;else root.FVCa=api;
})(typeof globalThis!=='undefined'?globalThis:this);
