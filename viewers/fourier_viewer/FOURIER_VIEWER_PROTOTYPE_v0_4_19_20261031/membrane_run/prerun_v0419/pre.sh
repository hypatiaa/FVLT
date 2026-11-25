#!/bin/bash
# usage: pre.sh TAG suite-file... : development pre-run of single suites of the v0.4.19 mirror copy (lock held), logs in v0419/TAG/
TAG=$1; shift; V=$HOME/membrane_compute/viewer; M=$V/mirror/FOURIER_VIEWER_PROTOTYPE_v0_4_19_20261031; O=$V/v0419/$TAG; mkdir -p $O
export NODE_PATH=$HOME/opt/playwright-1.61.1/node_modules PATH=$HOME/.local/bin:$PATH
cd $M; date -u +%FT%TZ > $O/start
for f in "$@"; do n=$(basename $f .cjs); node $f > $O/$n.run.log 2>&1; echo "$n exit=$? $(grep -E "SUMMARY|passed|pass" $O/$n.run.log | tail -1)" >> $O/SUMMARY.txt; done
date -u +%FT%TZ > $O/done
