#!/usr/bin/env bash
# Replay in a private work directory containing the six Lean source files.
set -eu
cd "$(dirname "$0")"
lib="${MATHLIB_PACKAGES:-$HOME/rule30_prize_research_2026_10_26/Rule30PrizeKit/.lake/packages}"
measure="${MEASURE_LIB:-$HOME/vision_measure_lean_20261123/build}"
verified="${VERIFIED_LIB:-$HOME/vision_v264_replay_20261123/build}"
export PATH="$HOME/.elan/toolchains/leanprover--lean4---v4.35.0/bin:$PATH"
export LEAN_PATH="$PWD:$measure:$verified"
for dep in "$lib"/*/.lake/build/lib/lean; do export LEAN_PATH="$LEAN_PATH:$dep"; done
lean --version
pin=$(git -C "$lib/mathlib" rev-parse HEAD)
test "$pin" = 56a005855ea17e0b0958f73ec801ae140b0a1679
printf 'Mathlib %s\n' "$pin"
sha256sum "$verified/Verified.olean" "$measure"/CoherentEnergy{Measure,RHBridge}.olean
for mod in DivisorPower GramBound PhaseGram FourthMomentRH FirstRow JordanRows; do
  sha256sum "$mod.lean"
  lean -j2 -DwarningAsError=true -o "$mod.olean" "$mod.lean"
  leanchecker "$mod"
  printf 'PASS compile + kernel replay from imports: %s\n' "$mod"
done

