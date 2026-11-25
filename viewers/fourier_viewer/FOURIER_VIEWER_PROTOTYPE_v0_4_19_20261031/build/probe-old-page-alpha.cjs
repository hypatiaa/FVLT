'use strict';
// v0.4.9 read-only probe (PORT_NOTE §7): open the OLD instrument page (frozen file, not edited), Clifford lift + Full stack, press alpha -1 / 0 / +1,
// and record state.alpha, the stack lift's point norms, the camera fit and a hash of the Clifford canvas.
const {chromium}=require('C:/Users/robin/s6_atom/node_modules/playwright'),crypto=require('crypto'),path=require('path');
const OLD='file:///C:/Users/robin/s6_atom/cold%20audit%20fourier/MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_20261004/monodromy-31-linked-reduction.html';
const out=process.argv[2];
(async()=>{const b=await chromium.launch();const pg=await (await b.newContext({viewport:{width:1280,height:900},deviceScaleFactor:1})).newPage();const errs=[];pg.on('pageerror',e=>errs.push(String(e)));
  await pg.goto(OLD);await pg.waitForTimeout(4000);
  await pg.click('#btn-view-clifford');await pg.waitForTimeout(800);
  await pg.click('#btn-stack');await pg.waitForTimeout(1500);
  for(const a of ['-1','0','1']){
    await pg.click('button[data-param="alpha"][data-value="'+a+'"]');await pg.waitForTimeout(1500);
    const r=await pg.evaluate(()=>{const pts=buildCliffordActualPoints().filter(p=>p.lane==='stack'&&p.projection_status==='FINITE');const n=pts.map(p=>Math.hypot(...p.stereographic)).sort((x,y)=>x-y);
      const cv=document.getElementById('clifford-canvas');const disp=(state.cliffordLeafMode==='sweep'&&leafSweepAvailable(liftSourceSnapshot(),1))?S3LeafSweepDisplayV1.reprojectPoints(buildCliffordActualPoints(),leafEtaFromStep()).filter(p=>p.lane==='stack'&&p.projection_status==='FINITE').map(p=>Math.hypot(...p.stereographic)).sort((x,y)=>x-y):null;return {leafMode:state.cliffordLeafMode,displayMedian:disp?disp[disp.length>>1]:null,displayMax:disp?disp[disp.length-1]:null,alpha:state.alpha,showStack:state.showStack,mode:state.radialParameterMode,stackPts:pts.length,median:n[n.length>>1],max:n[n.length-1],rho:document.getElementById('clifford-rho-label').textContent,png:cv.toDataURL()};});
    const h=crypto.createHash('sha256').update(r.png).digest('hex').slice(0,16);delete r.png;
    console.log('pressed α '+a+': '+JSON.stringify(r)+' canvas '+h);
    if(out)await (await pg.$('#clifford-canvas')).screenshot({path:path.join(out,'old_clifford_alpha_'+a+'.png')});
  }
  console.log('page errors: '+errs.length+(errs.length?' '+errs.slice(0,3).join(' | '):''));await b.close();})();
