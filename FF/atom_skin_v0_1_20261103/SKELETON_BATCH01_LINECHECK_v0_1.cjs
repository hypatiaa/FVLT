const fs=require('fs');const def=fs.readFileSync(process.argv[2],'utf8').split('\n');const src=fs.readFileSync(process.argv[3],'utf8').split('\n');
// find maximal contiguous runs of src lines in def; report src lines not in any run
let i=0;const runs=[];while(i<src.length){let best=null;for(let j=0;j<def.length;j++){let k=0;while(i+k<src.length&&j+k<def.length&&src[i+k]===def[j+k])k++;if(k>0&&(!best||k>best[1]))best=[j,k];}
 if(best){runs.push(`src ${i+1}-${i+best[1]} = def ${best[0]+1}-${best[0]+best[1]}`);i+=best[1];}else{runs.push(`src ${i+1} NOT IN DEFS: ${JSON.stringify(src[i])}`);i++;}}
console.log(runs.join('\n'));
