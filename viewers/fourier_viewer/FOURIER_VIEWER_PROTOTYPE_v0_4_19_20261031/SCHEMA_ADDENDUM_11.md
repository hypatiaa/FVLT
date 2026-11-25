# SCHEMA ADDENDUM 11: comb-hopf v0.4.3 (2026-10-19)

**Status:** builder's record for v0.4.3, an additive successor of v0.4.2 in its own folder. Not reviewed yet.

**Credits:**
- saphir: the observation (rotating the Clifford and Hopf objects looks blurry) and the decision ("keep that, but for the wireframe view, I am not sure if we are going to need it. But if we ever get to rendering surfaces, we might");
- Claude Sonnet 5.5: v0.4.3.

**Amends:** nothing in the schema. Display only.

## 1. Change

While the camera moves (drag, pinch, wheel; `layer.moving`) or a preview is drawn (`layer.preview`), the canvas layer was drawn at 0.5 of the pixel size. Now the factor is chosen by kind of drawing, in `views-common.js`:

- `MOVING_RES = {wireframe: 1, surface: 0.5}`.
- `layerBegin(cv, W, H, kind)` and `layerFit(cv, kind)` take the kind (default `'wireframe'`) and use the same function `resFactor(kind, moving)`, so they agree.
- Every current view (strokes, points, grids, orbits, trails, the Hopf background disc) is `wireframe`: full resolution while moving. The `surface` factor 0.5 is reserved for a future filled-surface layer, which must pass `'surface'` to both calls. No current view does.

## 2. Unchanged

Address, state, exact, Lift and pair schemas; build pins schema `fv-comb-hopf-build/0.1` (only `viewer` reads `comb-hopf v0.4.3`); every exact readout and export; the reduced drawing sample while moving (`lod`/`preview` thinning in view-clifford.js and view-hopf.js); the camera maths.
