#!/bin/bash
# Skeleton's read-only readiness check of library v23 (FF-3). Writes only under /tmp. Arg 1: SkeletonAuditFF3.lean
set -u
L=$HOME/rule30_theorem_library; V=$L/v23
echo "host=$(hostname) latest=$(ls -d $L/v*/ | sed 's#.*/v\([0-9]*\)/#\1#' | sort -n | tail -1)"
cd "$V" || exit 1
sha256sum SHA256SUMS LIBRARY_MANIFEST.json lake-manifest.json | cut -c1-16
echo "entries=$(wc -l < SHA256SUMS) check_fail=$(sha256sum -c SHA256SUMS --quiet 2>&1 | wc -l) writable=$(find . -writable | wc -l)"
T=$(mktemp -d /tmp/skel_v23_XXXX)
norm() { sed 's/ \*/  /' "$1" | awk '{h=$1; $1=""; sub(/^ +/,""); print $0"\t"h}' | sort; }
norm $L/v22/SHA256SUMS > $T/a; norm $V/SHA256SUMS > $T/b
echo "removed_or_changed: $(comm -23 $T/a $T/b | cut -f1 | tr '\n' ' ')"
echo "added_or_changed:   $(comm -13 $T/a $T/b | cut -f1 | tr '\n' ' ')"
for f in FVLTRosetteFordDataV1 FVLTRosetteFordPhaseV1 FVLTRosetteFordArithmeticV1 FVLTRosetteFordSweepV1 FVLTRosetteFordEndpointsV1; do
  echo "src $f $(sha256sum theorems/$f.lean | cut -c1-16)"; done
(cd $L/v22 && echo "v22 check_fail=$(sha256sum -c SHA256SUMS --quiet 2>&1 | wc -l) writable=$(find . -writable | wc -l)")
LEAN=$HOME/.elan/toolchains/leanprover--lean4---v4.35.0/bin/lean
LP="$V/.lake/build/lib/lean"; for d in $(ls -d $V/.lake/packages/*/.lake/build/lib/lean | sort); do LP="$LP:$d"; done
cp "$1" $T/
( cd $T && ulimit -v 8388608 && LEAN_PATH="$LP" LEAN_NUM_THREADS=1 taskset -c 0 nice -n 19 timeout 600 $LEAN -j1 -s65536 -M7680 SkeletonAuditFF3.lean ) > $T/ax.out 2>&1
echo "axioms_rc=$? lines=$(wc -l < $T/ax.out) sha=$(sha256sum $T/ax.out | cut -c1-16)"
echo "after: writable=$(find . -writable | wc -l) check_fail=$(sha256sum -c SHA256SUMS --quiet 2>&1 | wc -l)"
rm -rf $T
