'use strict';
const fs=require('node:fs'),path=require('node:path');
module.exports=function guard(){
 const root=process.env.BSD_AUDIT_SCRATCH_ROOT;
 if(!root||path.resolve(root)!==path.dirname(__dirname)||!fs.existsSync(path.join(root,'.bsd-audit-scratch.json')))throw Error('Workers run only in a staged scratch copy. Use node verify.cjs.');
 const receipt=JSON.parse(fs.readFileSync(path.join(root,'.bsd-audit-scratch.json'),'utf8'));
 if(receipt.kind!=='BSD_AUDIT_SCRATCH_V1'||path.resolve(receipt.sourcePackage)===path.resolve(__dirname))throw Error('Invalid scratch identity');
};
