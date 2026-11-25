/* Display placement from collapse_core_v0_9_5.js divisorPosition; no incidence changes. */
(function(root){
  function divisorPosition(exps, fac) {
    const m = fac.length;
    let x = 0, y = 0, z = 0;
    for (let i = 0; i < m; i += 1) {
      const n = fac[i].a + 1;
      const r = 1 / n;
      const e = exps[i];
      const phi = m > 1 ? (2 * Math.PI * i) / m : 0;
      const ang = (2 * Math.PI * e) / n + phi;
      x += r * (Math.cos(ang) - Math.cos(phi));
      y += r * (Math.sin(ang) - Math.sin(phi));
      z += e;
    }
    return [x, y, z];
  }
  if(typeof module==='object'&&module.exports)module.exports=divisorPosition;
  else root.FcaCrystalPosition=divisorPosition;
})(typeof window==='object'?window:globalThis);
