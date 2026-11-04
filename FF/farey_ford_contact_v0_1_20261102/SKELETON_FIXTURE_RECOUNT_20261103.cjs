// Independent recount of the FF-1 A7 fixtures (skeleton freeze review). Exact integers only.
const gcd=(a,b)=>b?gcd(b,a%b):Math.abs(a);
function phases(al){ const S=new Map();
  for(const a of al){ for(let q=2;q<=a+1;q++) if((a+1)%q===0) for(let c=1;c<q;c++) if(gcd(c,q)===1) S.set(c+"/"+q,[c,q]); }
  return [...S.values()].sort((x,y)=>x[0]*y[1]-y[0]*x[1]); }
function run(al){ const P=phases(al), n=P.length, adj=P.map(()=>[]); let E=0;
  for(let i=0;i<n;i++) for(let j=i+1;j<n;j++){ const d=P[i][0]*P[j][1]-P[j][0]*P[i][1]; if(Math.abs(d)===1){ adj[i].push(j); adj[j].push(i); E++; } }
  const comp=new Array(n).fill(-1); let C=0;
  for(let i=0;i<n;i++) if(comp[i]<0){ const st=[i]; comp[i]=C; while(st.length){ const u=st.pop(); for(const v of adj[u]) if(comp[v]<0){ comp[v]=C; st.push(v);} } C++; }
  const iso=P.filter((_,i)=>adj[i].length===0).map(p=>p.join("/"));
  const parts=[...Array(C).keys()].map(c=>P.filter((_,i)=>comp[i]===c).map(p=>p.join("/")));
  console.log(JSON.stringify(al), "V="+n, "E="+E, "components="+C, "isolated="+iso.join(","), "parts="+JSON.stringify(parts));
}
for(const al of [[4,2,1],[4,3,2,1],[9,2],[8,3]]) run(al);
