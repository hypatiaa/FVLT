#!/bin/bash
# re-run the builder's new node suites on the untouched copy; one log each; overall exit = number of failing suites
cd "$(dirname "$0")/orig/FOURIER_VIEWER_PROTOTYPE_v0_4_19_20261031"
O=../../out06; mkdir -p $O; bad=0
for s in host-core/test-v0419-goldbach-order.cjs host-core/test-v0419-fixups.cjs host-core/test-v0419-pens.cjs build/no-float-v0419.cjs; do
  n=$(basename $s .cjs); $HOME/.local/bin/node $s > $O/$n.log 2>&1; c=$?; echo "$n exit=$c $(grep -E 'SUMMARY' $O/$n.log | tail -1)"; [ $c -ne 0 ] && bad=$((bad+1))
done
exit $bad
