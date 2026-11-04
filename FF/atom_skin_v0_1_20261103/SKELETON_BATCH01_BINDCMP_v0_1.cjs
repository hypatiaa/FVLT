const fs=require('fs');const [a,b]=process.argv.slice(2).map(p=>JSON.parse(fs.readFileSync(p)));
const keys=new Set([...Object.keys(a),...Object.keys(b)]);
for(const k of keys) if(JSON.stringify(a[k])!==JSON.stringify(b[k])) console.log('DIFF',k,JSON.stringify(a[k]),'->',JSON.stringify(b[k]));
