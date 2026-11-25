/* Monodromy.30.1 display correction. Arithmetic, source pins and export formats remain inherited. */
(()=>{
 'use strict';
 const root=document.getElementById('bsd-prime-product');
 const note=root.querySelector(':scope > small');
 note.textContent='Exact finite factors for primes admissible on the displayed model. Model-level exclusions are not the curve-level bad-prime list or conductor support. A nonminimal model can exclude primes where the curve has good reduction; the short-model test excludes 2. Minimal-model and Tate results are not computed here. The finite trend does not establish rank, convergence or Sha.';
 function relabel(){
  const el=document.getElementById('fp-excluded');
  const text=el.textContent.replace(/^Excluded: /,'Model-level exclusions (not curve-level bad primes): ').replaceAll('Bad reduction for this model; Tate algorithm not implemented','Singular displayed-model reduction; curve-level status undetermined');
  if(el.textContent!==text)el.textContent=text;
 }
 new MutationObserver(relabel).observe(document.getElementById('fp-excluded'),{childList:true,characterData:true,subtree:true});
 relabel();
})();
