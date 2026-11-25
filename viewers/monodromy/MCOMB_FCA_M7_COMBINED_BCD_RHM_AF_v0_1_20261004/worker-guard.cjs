'use strict';
const fs=require('node:fs'),path=require('node:path');
function guard(){
 const root=process.env.BSD_V1_SCRATCH_ROOT,marker=root&&path.join(root,'.bsd-v1-scratch.json');
 if(!root||!fs.existsSync(marker))throw Error('Use verify.cjs: workers only run in a scratch copy');
 const q=JSON.parse(fs.readFileSync(marker)),resolved=path.resolve(root);
 if(path.resolve(__dirname)!==path.join(resolved,path.basename(__dirname))||path.resolve(q.sourcePackage)===path.resolve(__dirname))throw Error('Invalid scratch source/stage boundary');
 return resolved;
}
function outputPath(name){
 const root=guard();if(!/^[a-zA-Z0-9][a-zA-Z0-9._-]*$/.test(name)||name==='.'||name==='..')throw Error('Output must be a plain filename');
 const dir=path.join(root,'run-output','v1');
 if(fs.realpathSync(dir)!==dir)throw Error('Output directory must not redirect outside scratch');
 const out=path.join(dir,name);if(fs.existsSync(out)&&fs.lstatSync(out).isSymbolicLink())throw Error('Output file must not be a link');
 return out;
}
module.exports={guard,outputPath};
