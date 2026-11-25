(function(root){
'use strict';
// fv-exact 0.1.0: BigInt rationals, exact parsing, canonical JSON, strict JSON parser, SHA-256. No floats.
const VERSION='fv-exact/0.1.0';
const babs=n=>n<0n?-n:n;
function gcd(a,b){a=babs(a);b=babs(b);while(b){const t=a%b;a=b;b=t;}return a;}
function rat(n,d=1n){n=BigInt(n);d=BigInt(d);if(d===0n)throw Error('A fraction cannot have a zero denominator.');const g=gcd(n,d)||1n,s=d<0n?-1n:1n;return {n:n/g*s,d:d/g*s};}
const add=(a,b)=>rat(a.n*b.d+b.n*a.d,a.d*b.d),sub=(a,b)=>rat(a.n*b.d-b.n*a.d,a.d*b.d),mul=(a,b)=>rat(a.n*b.n,a.d*b.d);
const div=(a,b)=>{if(b.n===0n)throw Error('Division by zero.');return rat(a.n*b.d,a.d*b.n);};
const neg=a=>({n:-a.n,d:a.d}),qabs=a=>({n:babs(a.n),d:a.d});
const cmp=(a,b)=>{const x=a.n*b.d-b.n*a.d;return x<0n?-1:x>0n?1:0;};
const eq=(a,b)=>a.n===b.n&&a.d===b.d,isInt=a=>a.d===1n;
const floorDiv=(n,d)=>n>=0n?n/d:-((-n+d-1n)/d);       // d>0
const floor=q=>floorDiv(q.n,q.d),ceil=q=>-floorDiv(-q.n,q.d);   // BigInt results
const text=q=>q.d===1n?String(q.n):q.n+'/'+q.d;
function parse(t){
  const v=String(t).trim().replace(/−/g,'-'),p=v.split('/');
  if(p.length===2){if(!/^[+-]?\d+$/.test(p[0])||!/^[+-]?\d+$/.test(p[1]))throw Error('Use integers on either side of /.');return rat(BigInt(p[0]),BigInt(p[1]));}
  if(p.length>2)throw Error('Use a signed decimal or fraction: '+v);
  const m=/^([+-]?)(\d*)(?:\.(\d*))?$/.exec(v);
  if(!m||(!m[2]&&!m[3]))throw Error('Use a signed decimal or fraction: '+v);
  const dg=m[3]||'';return rat(BigInt((m[2]||'0')+dg)*(m[1]==='-'?-1n:1n),10n**BigInt(dg.length));
}
function parseInteger(t){const q=parse(t);if(q.d!==1n)throw Error('An integer is required: '+t);return q.n;}
function parseProduct(t){return String(t).split('*').reduce((a,b)=>mul(a,parse(b)),rat(1n));}
// ---- canonical serializer (sorted keys, compact, ASCII). Numbers are refused: exact values are strings.
function asciiString(s){let o='"';for(let i=0;i<s.length;i++){const c=s.charCodeAt(i);
  if(c===34)o+='\\"';else if(c===92)o+='\\\\';else if(c<32||c>126)o+='\\u'+c.toString(16).padStart(4,'0');else o+=s[i];}return o+'"';}
function canonical(v){
  if(v===null)return 'null';
  switch(typeof v){
    case 'boolean':return v?'true':'false';
    case 'bigint':return asciiString(String(v));
    case 'string':return asciiString(v);
    case 'number':throw Error('canonical: JS numbers are refused; write exact values as strings.');
    case 'object':
      if(Array.isArray(v))return '['+v.map(canonical).join(',')+']';
      return '{'+Object.keys(v).sort().map(k=>{if(v[k]===undefined)throw Error('canonical: undefined at '+k);return asciiString(k)+':'+canonical(v[k]);}).join(',')+'}';
    default:throw Error('canonical: unsupported type '+typeof v);
  }
}
const canonicalFile=v=>canonical(v)+'\n';
// ---- strict JSON parser: rejects duplicate keys, floats, exponents, trailing garbage. Integers become BigInt.
function parseStrict(src){
  let i=0;const ws=()=>{while(i<src.length&&' \t\n\r'.includes(src[i]))i++;};
  const fail=m=>{throw Error('JSON: '+m+' at '+i);};
  function str(){i++;let o='';for(;;){if(i>=src.length)fail('unterminated string');const c=src[i++];
    if(c==='"')return o;
    if(c==='\\'){const e=src[i++];
      if(e==='u'){const h=src.slice(i,i+4);if(!/^[0-9a-fA-F]{4}$/.test(h))fail('bad escape');o+=String.fromCharCode(parseInt(h,16));i+=4;}
      else if('"\\/'.includes(e))o+=e;else if(e==='b')o+='\b';else if(e==='f')o+='\f';else if(e==='n')o+='\n';else if(e==='r')o+='\r';else if(e==='t')o+='\t';else fail('bad escape');}
    else if(c.charCodeAt(0)<32)fail('control character');else o+=c;}}
  function val(){ws();const c=src[i];
    if(c==='{'){i++;const o={};ws();if(src[i]==='}'){i++;return o;}
      for(;;){ws();if(src[i]!=='"')fail('key expected');const k=str();if(Object.prototype.hasOwnProperty.call(o,k))fail('duplicate key '+k);ws();if(src[i++]!==':')fail(': expected');o[k]=val();ws();
        const d=src[i++];if(d==='}')return o;if(d!==',')fail(', or } expected');}}
    if(c==='['){i++;const a=[];ws();if(src[i]===']'){i++;return a;}
      for(;;){a.push(val());ws();const d=src[i++];if(d===']')return a;if(d!==',')fail(', or ] expected');}}
    if(c==='"')return str();
    if(src.startsWith('true',i)){i+=4;return true;}if(src.startsWith('false',i)){i+=5;return false;}if(src.startsWith('null',i)){i+=4;return null;}
    const m=/^-?(0|[1-9]\d*)(?![\d.eE])/.exec(src.slice(i,i+400));if(!m)fail('unsupported value (floats and exponents are refused)');i+=m[0].length;return BigInt(m[0]);}
  const v=val();ws();if(i<src.length)fail('trailing characters');return v;
}
// ---- SHA-256 on bytes
function utf8(s){const o=[];for(const ch of s){const c=ch.codePointAt(0);
  if(c<128)o.push(c);else if(c<2048)o.push(192|c>>6,128|c&63);else if(c<65536)o.push(224|c>>12,128|c>>6&63,128|c&63);else o.push(240|c>>18,128|c>>12&63,128|c>>6&63,128|c&63);}return Uint8Array.from(o);}
const K=new Uint32Array([0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2]);
function sha256(bytes){
  const l=bytes.length,n=((l+9+63)>>6)<<6,b=new Uint8Array(n);b.set(bytes);b[l]=128;
  const dv=new DataView(b.buffer);dv.setUint32(n-8,Math.floor(l/0x20000000));dv.setUint32(n-4,(l<<3)>>>0);
  const H=new Uint32Array([0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19]),w=new Uint32Array(64);
  const R=(x,k)=>(x>>>k|x<<(32-k))>>>0;
  for(let o=0;o<n;o+=64){
    for(let t=0;t<16;t++)w[t]=dv.getUint32(o+4*t);
    for(let t=16;t<64;t++){const a=w[t-15],c=w[t-2];w[t]=(w[t-16]+(R(a,7)^R(a,18)^a>>>3)+w[t-7]+(R(c,17)^R(c,19)^c>>>10))>>>0;}
    let [a,bb,c,d,e,f,g,h]=H;
    for(let t=0;t<64;t++){
      const t1=(h+(R(e,6)^R(e,11)^R(e,25))+((e&f)^(~e&g))+K[t]+w[t])>>>0,t2=((R(a,2)^R(a,13)^R(a,22))+((a&bb)^(a&c)^(bb&c)))>>>0;
      h=g;g=f;f=e;e=(d+t1)>>>0;d=c;c=bb;bb=a;a=(t1+t2)>>>0;}
    [a,bb,c,d,e,f,g,h].forEach((v,j)=>{H[j]=(H[j]+v)>>>0;});
  }
  return Array.from(H,x=>x.toString(16).padStart(8,'0')).join('');
}
const sha256Text=s=>sha256(utf8(s));
const api={VERSION,gcd,rat,add,sub,mul,div,neg,qabs,cmp,eq,isInt,floor,ceil,floorDiv,text,parse,parseInteger,parseProduct,canonical,canonicalFile,parseStrict,utf8,sha256,sha256Text};
if(typeof module!=='undefined'&&module.exports)module.exports=api;else root.FVExact=api;
})(typeof globalThis!=='undefined'?globalThis:this);
