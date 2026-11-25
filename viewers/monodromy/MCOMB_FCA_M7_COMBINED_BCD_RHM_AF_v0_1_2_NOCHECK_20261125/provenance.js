/* Display-only names for distinct hash namespaces. No authority is granted here. */
(function(root,factory){if(typeof module==='object')module.exports=factory();else root.BSDV1Provenance=factory();})(globalThis,function(){'use strict';
 function identities(q,a){const v=q.view,legacy=JSON.parse(q.input.curveBytes).curve,c=a.certificate;return [
  ['Legacy short-plot model fingerprint (BSD curve-record schema)',legacy.modelId],
  ['Legacy source-record context ID',legacy.contextId],
  ['Exact input model ID (Tate model schema)',v.inputModel.modelId],
  [c?'T4 certificate final-model ID':'Assessed T4 model ID (global minimality unavailable)',c?.modelId||v.model.modelId],
  ['T4 record context ID',q.t4.record.contextId],
  ['T4 certificate context ID',c?.contextId||'none — partial result'],
  ['Linked six-panel view context ID',v.contextId],
  ['T4 normalization ID',v.binding.normalizationId],['T4 marking ID',v.binding.markingId],
  ['T4 packet SHA-256',v.binding.packetHash],['T4 certificate ID',a.certificateId||'none — partial result']
 ];}
 function verifiers(a,pins){const v=a.certificate?.verifier||pins.t4Verifier,rows=[
  ['T4 global reduction replay',v.sha256],['T3 small-prime replay',v.smallPrime.sha256],['T3 small-prime Tate engine',v.smallPrime.tateSha256],
  ['T2 tame replay',v.tame.sha256],['T2 tame Tate engine',v.tame.tateSha256],['Finite-field engine',v.tame.finiteFieldSha256],
  ['T1 transport replay',v.transportSha256],['Exact model arithmetic',v.arithmeticSha256]
 ];for(const [n,h]of Object.entries(pins.publicGate))rows.push(['Public gate / '+n,h]);for(const [n,h]of Object.entries(pins.localBridge))rows.push(['Local bridge / '+n,h]);return rows;}
 const text=rows=>rows.map(([label,value])=>label+':\n'+value).join('\n');
 const explanation='These identifiers name different records and hash schemas. Equal coefficients need not give equal hashes across schemas. The exact input-to-plot and input-to-final maps bind the presentations; the signed response binds the T4 certificate to this linked context.';
 function product(p){const [n,d='1']=p.product.split('/');return `Partial good-prime Euler product through ${p.cutoff}: ∏ Lₚ(1) = ∏ p/#E(Fₚ) = ${p.product} (≈ ${Number(n)/Number(d)}). Only good primes p ≤ ${p.cutoff} are included. Bad Euler factors are listed separately. This is a finite product; no limit or analytic-rank conclusion is claimed.`;}
 return Object.freeze({identities,verifiers,text,explanation,product});
});
