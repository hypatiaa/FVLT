#!/bin/bash
# verifier: runs the v0.4.19 runall.sh once on the verifier's own path-mapped copy, holding the membrane lock with flock -n (browser runs not capped)
cd $HOME/membrane_compute/viewer/verify_0419
export NODE_PATH=$HOME/opt/playwright-1.61.1/node_modules PATH=$HOME/.local/bin:$PATH
date -u +%FT%TZ > full.start
flock -n $HOME/membrane_compute/.lock bash -lc "export NODE_PATH=$NODE_PATH PATH=$PATH; bash root/FOURIER_VIEWER_PROTOTYPE_v0_4_19_20261031/build/runall.sh" > full.out 2>&1; echo EXIT=$? > full.done; date -u +%FT%TZ >> full.done
