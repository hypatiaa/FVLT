/* Duplicate-key rejection before JSON.parse, including exact strings. */
function strictJSON(text,max=32000000){
 if(typeof text!=='string'||new TextEncoder().encode(text).length>max)throw Error('JSON byte cap');let i=0,nodes=0;
 const ws=()=>{while(/[\t\n\r ]/.test(text[i]||'!'))i++;};
 function string(){const start=i++;while(i<text.length){if(text[i]==='\\'){i+=2;continue;}if(text[i++]==='"')return JSON.parse(text.slice(start,i));}throw Error('Unterminated string');}
 function value(depth){ws();if(depth>80||++nodes>2000000)throw Error('JSON work cap');if(text[i]==='"'){string();return;}if(text[i]==='{'){i++;ws();const seen=new Set();if(text[i]==='}'){i++;return;}while(true){ws();if(text[i]!=='"')throw Error('Object key required');const k=string();if(seen.has(k))throw Error('Duplicate JSON key: '+k);seen.add(k);ws();if(text[i++]!==':')throw Error('Expected colon');value(depth+1);ws();const c=text[i++];if(c==='}')return;if(c!==',')throw Error('Expected object separator');}}if(text[i]==='['){i++;ws();if(text[i]===']'){i++;return;}while(true){value(depth+1);ws();const c=text[i++];if(c===']')return;if(c!==',')throw Error('Expected array separator');}}const m=/^(?:true|false|null|-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?)/.exec(text.slice(i));if(!m)throw Error('Invalid JSON value');i+=m[0].length;}
 value(0);ws();if(i!==text.length)throw Error('Trailing JSON');return JSON.parse(text);
}
if(typeof module==='object')module.exports=strictJSON;
