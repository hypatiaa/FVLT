'use strict';
let job=null,state=null,binding=null,controls=null;
self.onmessage=async e=>{const m=e.data;try{
 if(m.action==='replay'){const out=await McombStructurePacketV1.replay(m.bytes);self.postMessage({job:m.job,packet:out.packet});return;}
 if(m.action==='start'){job=m.job;binding=m.binding;controls=m.controls;const v=await McombStructurePacketV1.resolve(binding,controls);state=McombStructureV1.createSearch(v.graph);const n=Number(m.replaySteps||'0');McombStructureV1.advance(state,n,Number.MAX_SAFE_INTEGER);if(state.steps!==n)throw Error('Resume work mismatch');}
 else if(m.action!=='resume'||m.job!==job||!state)throw Error('Stale or missing search');
 const result=McombStructureV1.advance(state,m.steps??2000,200),packet=await McombStructurePacketV1.construct(binding,controls,result.processedSteps);self.postMessage({job:m.job,packet});
 }catch(e){self.postMessage({job:m.job,error:e.message});}};
