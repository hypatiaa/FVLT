#!/bin/bash
# Skeleton's independent FF-2 rebuild on nucleus. Fresh empty build/, v20 library only,
# template limits: 1 CPU, nice 19, 8 GiB address space, -j1 -s65536 -M7680, 240 s per call.
set -u
ROOT=$HOME/skeleton_audit/ff2_final_20261104
LIB=$HOME/rule30_theorem_library/v20
LEAN=$HOME/.elan/toolchains/leanprover--lean4---v4.35.0/bin/lean
export PATH=$HOME/.elan/toolchains/leanprover--lean4---v4.35.0/bin:/usr/local/bin:/usr/bin:/bin
cd "$ROOT"
LP="$ROOT/build:$LIB/.lake/build/lib/lean"
for d in $(ls -d $LIB/.lake/packages/*/.lake/build/lib/lean | sort); do LP="$LP:$d"; done
export LEAN_PATH="$LP" LEAN_NUM_THREADS=1 MALLOC_ARENA_MAX=2
FLAGS="-j1 -s65536 -M7680 -D Elab.async=false"
run() { # name, then command
  local name=$1; shift
  local t0=$(date +%s.%N)
  ( ulimit -v 8388608; exec taskset -c 0 nice -n 19 timeout -s KILL 240 "$@" ) > "$ROOT/logs/$name.log" 2>&1
  local rc=$?
  echo "$name rc=$rc start=$t0 end=$(date +%s.%N) log_sha256=$(sha256sum "$ROOT/logs/$name.log" | cut -d' ' -f1)" | tee -a "$ROOT/logs/SUMMARY.txt"
  return $rc
}
mkdir -p logs
echo "LEAN_PATH=$LEAN_PATH" > logs/ENV.txt
sha256sum "$LEAN" src/*.lean IndependentFVLTReplay435.lean SkeletonAuditFF2.lean > logs/INPUTS.sha256
(cd "$LIB" && sha256sum -c SHA256SUMS --quiet) > logs/LIB_BEFORE.txt 2>&1; echo "lib_before_failures=$(wc -l < logs/LIB_BEFORE.txt)" | tee -a "$ROOT/logs/SUMMARY.txt"
for m in FVLTAtomSkinDataV1 FVLTAtomSkinCountsV1 FVLTAtomSkinPenV1 FVLTPillowcaseDataV1 FVLTPillowcaseV1; do
  (cd src && run "$m.compile" $LEAN $FLAGS -o "$ROOT/build/$m.olean" "$m.lean") || { echo "STOP at $m compile" | tee -a "$ROOT/logs/SUMMARY.txt"; exit 1; }
done
for m in FVLTAtomSkinDataV1 FVLTAtomSkinCountsV1 FVLTAtomSkinPenV1 FVLTPillowcaseDataV1 FVLTPillowcaseV1; do
  run "$m.replay" $LEAN $FLAGS --run IndependentFVLTReplay435.lean "$m"
done
run "axioms" $LEAN $FLAGS SkeletonAuditFF2.lean
sha256sum build/*.olean > logs/OBJECTS.sha256
(cd "$LIB" && sha256sum -c SHA256SUMS --quiet) > logs/LIB_AFTER.txt 2>&1; echo "lib_after_failures=$(wc -l < logs/LIB_AFTER.txt)" | tee -a "$ROOT/logs/SUMMARY.txt"
sha256sum src/*.lean > logs/SRC_AFTER.sha256
