/* Read the host's committed exact registers; never read a rounded divisor row. */
(()=>{'use strict';
 function capture(){
  const h=liftSourceSnapshot(),B=h.shellBase,p=h.phi3;if(!Number.isSafeInteger(B)||!Number.isFinite(p)||!Number.isFinite(h.n6))throw Error('Unsupported host shell state');
  const position=Number.isSafeInteger(p)?{kind:'INTEGER_SHELL',phi3:String(p),N:String(BigInt(B)+1n-BigInt(p))}:{kind:'BETWEEN_SHELLS',phi3Display:String(p),NDisplay:String(B+1-p)};
  const out={schema:'M4_HOST_SHELL_CONTEXT_V1',shell:{mode:h.shellMode,base:String(B),factorialIndex:h.shellMode==='factorial'?String(h.n1):null},position,s:state.isAnimatingS?null:h.sExact,t1:h.t1Exact,t2:h.t2Exact,m:String(h.m),amplitudeSign:Math.sign(h.n6)};
  McombShellWalkV1.context(out);return out;
 }
 // Changing to a smaller base deliberately retains s. The inherited paired-
 // modulus candidate admits |s| <= B+1 only. Refuse that optional display
 // outside its domain, without changing its arithmetic or explicit API calls.
 const pairedOriginal=analyzePairedModulus,cardOriginal=updateSpectralGearboxCard;
 const pairedOutside=()=>Number.isFinite(state.s)&&Math.abs(state.s)>selectedShellBase()+1;
 analyzePairedModulus=function(...args){if(args.length===0&&pairedOutside())return null;return pairedOriginal(...args);};
 updateSpectralGearboxCard=function(...args){const r=cardOriginal(...args);if(pairedOutside()){
  const B=selectedShellBase(),put=(id,text)=>{const n=document.getElementById(id);if(n)n.textContent=text;};
  put('paired-moduli',String(B+1-state.phi3)+' / '+String(B-1+state.phi3));put('paired-guard','UNAVAILABLE · outside paired-modulus spin range');put('paired-degeneracy','NOT_EVALUATED');
  put('paired-label','Paired-modulus candidate requires |s| ≤ B+1. The retained exact spin and shell-walk atom remain available.');
 }return r;};
 window.McombShellWalkHostV1=Object.freeze({capture,pairedOutside});
})();
