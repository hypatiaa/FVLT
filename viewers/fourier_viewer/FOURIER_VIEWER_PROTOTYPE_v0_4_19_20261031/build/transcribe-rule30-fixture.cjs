'use strict';
// v0.4.16: transcribes the pinned rule30 outputs (READ ONLY; nothing in rule30_prize_research_2026_10_26/ is run, copied or written) into fixtures/rule30-ladder-fixture.json.
// The source sha256 values are checked against the brief's pins before anything is written.
const fs=require('fs'),path=require('path'),crypto=require('crypto');
const SRC='C:/Users/robin/s6_atom/rule30_prize_research_2026_10_26/';
const PINS={'opus_two_adic_n2_densities_v0_1_20261028.output.txt':'72d0bd143c106c37ff3b1e8a46aa44d7605a8c17a88bee0990b0ce886fc7efcf',
  'opus_two_adic_n2_lemma_check_v0_1_20261028.output.txt':'fa24e8067419383eb0184b4868468a3d6b1c5072ac20e8cd1e75ef887585defd',
  'opus_two_adic_n2_v0_1_20261028.sha256':'677bfe28bae82f6fed3b4716a2fceacd521e2c8c281b5063d1f0fe173e8035a8'};
const sha=b=>crypto.createHash('sha256').update(b).digest('hex'),txt={};
for(const [f,h] of Object.entries(PINS)){const b=fs.readFileSync(SRC+f);if(sha(b)!==h)throw Error('sha256 mismatch: '+f);txt[f]=b.toString('utf8');}
const man=txt['opus_two_adic_n2_v0_1_20261028.sha256'];
for(const f of Object.keys(PINS).slice(0,2))if(!man.includes(PINS[f]+' *'+f))throw Error('manifest does not list '+f);
const rules={};let cur=null;
for(const line of txt['opus_two_adic_n2_densities_v0_1_20261028.output.txt'].split(/\r?\n/)){
  let m=/^== rule (\d+): cycle of 1 mod 2\^35 has length (\d+)$/.exec(line);
  if(m){cur=rules[m[1]]={rule:+m[1],per35:+m[2],rows:[]};continue;}
  m=/^j=\s*(\d+) per=\s*(\d+) ones=\s*(\d+) density=\s*(\S+) ~(\S+) excess\(ones-zeros\)=\s*(-?\d+)$/.exec(line);
  if(m){cur.rows.push({j:+m[1],per_j_plus_1:+m[2],ones:+m[3],density:m[4],density_decimal_printed:m[5],excess:+m[6]});continue;}
  if(line.trim())throw Error('unparsed line: '+line);}
for(const line of txt['opus_two_adic_n2_lemma_check_v0_1_20261028.output.txt'].split(/\r?\n/)){if(!line.trim())continue;
  const m=/^rule (\d+): per mod 2\^35 = (\d+); doublings at j = \[([\d, ]*)\] \((\d+) of 34\); lemma \(antiperiodic, density 1\/2\) on all doubling rows: (True|False); stall rows (\d+), of which density exactly 1\/2: (\d+); mean \|ones-zeros\|\/per on stall rows = ([\d.]+), max = ([\d.]+)$/.exec(line);
  if(!m)throw Error('unparsed lemma line: '+line);const r=rules[m[1]];if(+m[2]!==r.per35)throw Error('per35 disagrees');
  Object.assign(r,{doublings:m[3].split(',').map(s=>+s.trim()),doubling_count:+m[4],lemma_all_doubling_rows:m[5]==='True',stall_rows:+m[6],stall_rows_density_half:+m[7],stall_mean_abs_excess_over_per_printed:m[8],stall_max_abs_excess_over_per_printed:m[9]});}
for(const r of Object.values(rules))if(r.rows.length!==35)throw Error('rule '+r.rule+': '+r.rows.length+' rows');
const out={schema:'fv-rule30-ladder-fixture/0.1',made:'2026-10-28 by build/transcribe-rule30-fixture.cjs (v0.4.16 builder, Claude Opus 5.5); a transcription, nothing recomputed',
  convention:'line j of the densities output: per = per_{j+1} (cycle of 1 mod 2^(j+1)); ones = #{t < per_{j+1} : A(j,t) = 1}; doublings = { j in 1..34 : per_{j+1} = 2 per_j }',
  sources:Object.entries(PINS).map(([f,h])=>({file:'rule30_prize_research_2026_10_26/'+f,sha256:h})),rules};
const dst=path.join(__dirname,'..','fixtures','rule30-ladder-fixture.json');fs.writeFileSync(dst,JSON.stringify(out,null,1)+'\n');
console.log('wrote '+dst+' sha256 '+sha(fs.readFileSync(dst)));
