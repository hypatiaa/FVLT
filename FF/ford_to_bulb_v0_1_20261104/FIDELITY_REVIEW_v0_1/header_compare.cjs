// Compare public theorem headers in delivered sources against frozen headers (text, whitespace-normalized).
const fs=require('fs'),path=require('path');
const base=path.resolve(__dirname,'..');
const norm=s=>s.replace(/\r/g,'').replace(/\s+/g,' ').trim();
function frozen(){
  const t=fs.readFileSync(path.join(base,'freeze_packet_v0_1/FF4_HEADERS_PROPOSED_v0_1.lean.txt'),'utf8').replace(/\r/g,'');
  const out={};const re=/^theorem (\S+)([\s\S]*?)(?=\n\n|\n--|\nend )/gm;let m;
  while((m=re.exec(t)))out[m[1]]=norm('theorem '+m[1]+m[2]);return out;}
function delivered(f){
  const t=fs.readFileSync(path.join(base,'final_source_packet_v0_1/sources',f),'utf8').replace(/\r/g,'');
  const out={};const re=/^theorem (\S+)([\s\S]*?) := by/gm;let m;
  while((m=re.exec(t)))out[m[1]]=norm('theorem '+m[1]+m[2]);
  const priv=(t.match(/^private theorem \S+/gm)||[]).length;
  const otherPublic=(t.match(/^(def|lemma|abbrev|instance|noncomputable def|@\[|attribute|axiom|variable)/gm)||[]);
  return {out,priv,otherPublic};}
const F=frozen();
if(process.argv[2]==="mutate"){F.rank_step=F.rank_step.replace("% d.q","% d.p");} // negative control
const C=delivered('FVLTFordBulbCombinatoricsV1.lean'),P=delivered('FVLTFordBulbParameterV1.lean');
const D={...C.out,...P.out};
let ok=0,bad=[];
for(const k of Object.keys(F)){ if(D[k]===F[k])ok++; else bad.push({k,frozen:F[k],delivered:D[k]}); }
const extra=Object.keys(D).filter(k=>!(k in F));
console.log(JSON.stringify({frozen_count:Object.keys(F).length,delivered_public:Object.keys(D).length,
 combinatorics_public:Object.keys(C.out).length,parameter_public:Object.keys(P.out).length,
 match:ok,mismatch:bad,extra_public:extra,private_helpers_combinatorics:C.priv,private_helpers_parameter:P.priv,
 other_public_decl_kinds:[...C.otherPublic,...P.otherPublic]},null,1));
