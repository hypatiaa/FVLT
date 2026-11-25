#!/bin/bash
# mutation test: does test-v0419-fixups read the real panel-elliptic.js? Copy the untouched build, break redLabel in the copy only, run the test: must fail.
cd "$(dirname "$0")"; rm -rf mut09; mkdir mut09; cp -a orig/FOURIER_VIEWER_PROTOTYPE_v0_4_19_20261031 mut09/b
f=mut09/b/instruments/comb-hopf/panel-elliptic.js
sed -i "s/rt.type==='additive'?'additive':rt.type+' multiplicative'/rt.type+' multiplicative'/" $f
grep -c "rt.type+' multiplicative';" $f
$HOME/.local/bin/node mut09/b/host-core/test-v0419-fixups.cjs; c=$?; echo "mutated run exit=$c (want 1)"
$HOME/.local/bin/node orig/FOURIER_VIEWER_PROTOTYPE_v0_4_19_20261031/host-core/test-v0419-fixups.cjs | tail -1
rm -rf mut09
[ $c -eq 1 ]
