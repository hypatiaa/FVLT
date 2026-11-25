const GP=requireModule('/pt1/pt1-group.cjs'),RP=requireModule('/pt1/pt1-replay.cjs');
globalThis.BSDPT1=Object.freeze({
 modelId:ainvs=>GP.T.model(ainvs).modelId,
 replay:RP.replay,
 linked(bytes,q){const p=strictJSON(bytes,GP.CAPS.bytes);GP.same(p.parent.bytes,q.t4.parent.bytes,'PT1 parent differs from current exact transport');const parent=strictJSON(p.parent.bytes,1000000),expected=RP.binding(parent,q.sourceHash,q.view.contextId);return RP.replay(bytes,expected);},
 operation(ainvs,kind,p,q,n){const e=GP.engine(ainvs);if(kind==='MEMBERSHIP'){e.on(p);return {status:'EXACT_MEMBERSHIP',point:p};}let point;if(kind==='NEGATE')point=e.neg(p);else if(kind==='ADD')point=e.plus(p,q);else if(kind==='DOUBLE')point=e.plus(p,p);else if(kind==='MULTIPLY')point=e.times(p,n);else throw Error('Unknown operation');return {status:'EXACT_ARITHMETIC_RESULT',point,scope:'NO_TORSION_OR_RANK_INFERENCE'};}
});
