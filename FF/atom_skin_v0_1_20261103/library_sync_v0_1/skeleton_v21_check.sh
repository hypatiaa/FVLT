#!/bin/bash
# Skeleton's read-only readiness check of shared library v21 (FF-2). Writes only under /tmp.
set -u
L=$HOME/rule30_theorem_library
V=$L/v21
echo "host=$(hostname)"
echo "latest=$(ls -d $L/v*/ | sed 's#.*/v\([0-9]*\)/#\1#' | sort -n | tail -1)"
cd "$V" || { echo "NO_V21"; exit 1; }
sha256sum SHA256SUMS LIBRARY_MANIFEST.json lake-manifest.json
echo "entries=$(wc -l < SHA256SUMS)"
echo "v21_check_fail=$(sha256sum -c SHA256SUMS --quiet 2>&1 | wc -l)"
echo "v21_writable=$(find . -writable | wc -l)"
echo "v21_symlinks=$(find . -type l | wc -l)"
for f in FVLTAtomSkinDataV1 FVLTAtomSkinCountsV1 FVLTAtomSkinPenV1 FVLTPillowcaseDataV1 FVLTPillowcaseV1; do
  p=$(find . -name "$f.lean" -not -path './.lake/*' | head -1); echo "src $f $(sha256sum "$p" | cut -d' ' -f1) $p"
done
(cd $L/v20 && echo "v20_check_fail=$(sha256sum -c SHA256SUMS --quiet 2>&1 | wc -l) v20_writable=$(find . -writable | wc -l) v20_sums=$(sha256sum SHA256SUMS | cut -d' ' -f1)")
LEAN=$HOME/.elan/toolchains/leanprover--lean4---v4.35.0/bin/lean
echo "lean=$(sha256sum $LEAN | cut -d' ' -f1)"
LP="$V/.lake/build/lib/lean"
for d in $(ls -d $V/.lake/packages/*/.lake/build/lib/lean | sort); do LP="$LP:$d"; done
T=$(mktemp -d /tmp/skel_v21_XXXX); cp "$1" "$T/"
( cd "$T" && ulimit -v 8388608 && LEAN_PATH="$LP" LEAN_NUM_THREADS=1 taskset -c 0 nice -n 19 timeout 600 $LEAN -j1 -s65536 -M7680 SkeletonAuditFF2.lean ) > "$T/axioms.out" 2>&1
echo "axioms_rc=$? axioms_sha=$(sha256sum $T/axioms.out | cut -d' ' -f1) lines=$(wc -l < $T/axioms.out)"
echo "after_v21_writable=$(find . -writable | wc -l) after_v21_check_fail=$(sha256sum -c SHA256SUMS --quiet 2>&1 | wc -l)"
rm -rf "$T"
