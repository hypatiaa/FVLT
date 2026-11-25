'use strict';
// Fixed command, no path arguments, no file writes. The frozen public gate owns validation.
if(process.argv.length!==2)throw Error('No arguments accepted');
const chunks=[];let size=0;process.stdin.on('data',chunk=>{size+=chunk.length;if(size>32000000){console.error('Packet exceeds 32 MB');process.exit(1);}chunks.push(chunk);});
process.stdin.on('end',()=>{try{const bytes=new TextDecoder('utf-8',{fatal:true}).decode(Buffer.concat(chunks));const result=require('../BSD_TATE_T4_v0_1_20260923/assess.cjs').assess(bytes);process.stdout.write(JSON.stringify(result));}catch(e){console.error(e.message);process.exitCode=1;}});
