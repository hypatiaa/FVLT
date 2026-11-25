'use strict';
// WCAG contrast ratios for every text colour against every background it is used on. Prints a table; exits 1 if any text pair < 4.5.
const lum=h=>{const n=parseInt(h.slice(1),16),c=[n>>16&255,n>>8&255,n&255].map(v=>{v/=255;return v<=0.03928?v/12.92:Math.pow((v+0.055)/1.055,2.4);});return 0.2126*c[0]+0.7152*c[1]+0.0722*c[2];};
const ratio=(a,b)=>{const x=lum(a),y=lum(b),hi=Math.max(x,y),lo=Math.min(x,y);return (hi+0.05)/(lo+0.05);};
const bgs={'bg-deep':'#0c0c18','bg-panel':'#131321','bg-card':'#0e0e1a','bg-inset':'#08080f'};
const fgs={'text-dim':'#9a9ab8','text-mid':'#b4b4cc','text-bright':'#d4d4e8','accent-z1':'#00e5ff','accent-z2':'#ff5e6c','accent-z0 (text)':'#c084fc','accent-warn':'#fbbf24','accent-good':'#10b981','accent-defend':'#ff6b6b','accent-spine':'#f59e0b','poly-text':'#c9a227',
  'tooth -1 #00e5ff':'#00e5ff','tooth +1 #ff5e6c':'#ff5e6c','tooth -2 #10b981':'#10b981','tooth +2 #fbbf24':'#fbbf24','tooth -3 #3b82f6 (text variant)':'#6aa4f8','tooth +3 #f472b6':'#f472b6','tooth -4 #84cc16':'#84cc16','tooth +4 #fb923c':'#fb923c','tooth -5 #2dd4bf':'#2dd4bf','tooth +5 #e879f9':'#e879f9','tooth -6 #a3a3c2':'#a3a3c2','tooth +6 #eab308':'#eab308','button-pressed bg-deep on z1':'#0c0c18'};
let bad=0;const rows=[];
for(const [fn,f] of Object.entries(fgs))for(const [bn,b] of Object.entries(bgs)){
  if(fn.startsWith('button-pressed')){if(bn!=='bg-deep')continue;const r=ratio(f,'#00e5ff');rows.push([fn+' on accent-z1 fill',r]);if(r<4.5)bad++;continue;}
  const r=ratio(f,b);rows.push([fn+' on '+bn,r]);if(r<4.5)bad++;}
const out=rows.map(([n,r])=>(r>=4.5?'PASS ':'FAIL ')+r.toFixed(2).padStart(5)+'  '+n);
console.log(out.join('\n'));console.log('contrast-check: '+rows.filter(x=>x[1]>=4.5).length+' pass, '+bad+' fail');process.exit(bad?1:0);
