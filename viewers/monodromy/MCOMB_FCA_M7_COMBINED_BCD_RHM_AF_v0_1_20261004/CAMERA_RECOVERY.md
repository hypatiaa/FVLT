# V1 v0.8 / Monodromy.31.7 camera recovery repair

The sealed v0.7 interaction build is preserved. An additional live probe found that BLOCKED then LIVE recovery on the same kernel SVG reused the zoomed viewBox as its new reset rectangle. Reproduction is saved beside the packages in BSD_LINKED_VIEW_V1_v0_7_RESET_PROBE_20260923.json. This is a display-camera defect, with no arithmetic promotion or source mutation.

The one-line repair retains the last known original rectangle when the SVG still carries this camera's own viewBox. A new author-provided rectangle still replaces it, including on resize. The added browser regression zooms the kernel, starts spin animation to force BLOCKED, restores an exact live source and asserts Reset view returns to [0,0,760,260]. The previous 27 interaction checks remain required. This candidate must pass fresh scratch suites before and after sealing.
