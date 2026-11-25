#!/bin/bash
# sequential full suite for v0.4.19 (the v0.4.18 suite unchanged, plus the v0.4.19 suites; one invocation, no parallel runs)
# v0.4.18 additions: test-pen-streams, test-pen-fields, test-pen-curvature, test-pen-sphere, test-v0418-fixups, no-float-v0418,
# browser-check-v0418, browser-check-legacy-panels-v0418, and check-expected-fails-v0418 (reads the logs of this same run).
# v0.4.19 additions (SCHEMA_ADDENDUM_26), appended: test-v0419-goldbach-order, test-v0419-fixups, test-v0419-pens, no-float-v0419,
# browser-check-d1-v0419, browser-check-v0419, and last check-expected-fails-v0419 (reads the logs and the exit lines of this same run;
# host of record: membrane). The summary file is now SUMMARY_v0419.txt.
cd "$(dirname "$0")/.."
L=build/_logs; mkdir -p $L; : > $L/SUMMARY_v0419.txt
run(){ n=$1; shift; node "$@" > $L/$n.run.log 2>&1; c=$?; echo "$n exit=$c $(grep -E 'SUMMARY|passed|pass' $L/$n.run.log | tail -1)" >> $L/SUMMARY_v0419.txt; }
run test-exact exact-lib/test-exact.cjs
run test-core host-core/test-core.cjs
run contrast-check build/contrast-check.cjs
run test-mirror host-core/test-mirror.cjs
run test-v041 host-core/test-v041.cjs
run test-v042 host-core/test-v042.cjs
run test-v044 build/test-v044.cjs
run test-v047 build/test-v047.cjs
run test-v049 build/test-v049.cjs
run test-v0410 build/test-v0410.cjs
run test-v0411 build/test-v0411.cjs
run test-v0412 build/test-v0412.cjs
run test-v0413 build/test-v0413.cjs
run test-v0414 build/test-v0414.cjs
run test-rule30-ladder host-core/test-rule30-ladder.cjs
run test-elliptic-exact host-core/test-elliptic-exact.cjs
run test-elliptic-period host-core/test-elliptic-period.cjs
run no-float-elliptic build/no-float-elliptic.cjs
run test-pen-streams host-core/test-pen-streams.cjs
run test-pen-fields host-core/test-pen-fields.cjs
run test-pen-curvature host-core/test-pen-curvature.cjs
run test-pen-sphere host-core/test-pen-sphere.cjs
run test-v0418-fixups host-core/test-v0418-fixups.cjs
run no-float-v0418 build/no-float-v0418.cjs
for b in mirror v041 v042 v043 v044 v045 v046 v047 v048 v049 v0410 v0411 v0412 v0413 v0414 v0416 v0417 v0418; do run browser-check-$b build/browser-check-$b.cjs; done
run browser-check-legacy-panels-v0418 build/browser-check-legacy-panels-v0418.cjs
run browser-check build/browser-check.cjs
run check-expected-fails-v0418 build/check-expected-fails-v0418.cjs
# ---- v0.4.19
run test-v0419-goldbach-order host-core/test-v0419-goldbach-order.cjs
run test-v0419-fixups host-core/test-v0419-fixups.cjs
run test-v0419-pens host-core/test-v0419-pens.cjs
run no-float-v0419 build/no-float-v0419.cjs
run browser-check-d1-v0419 build/browser-check-d1-v0419.cjs
run browser-check-v0419 build/browser-check-v0419.cjs
run check-expected-fails-v0419 build/check-expected-fails-v0419.cjs
echo ALLDONE >> $L/SUMMARY_v0419.txt
