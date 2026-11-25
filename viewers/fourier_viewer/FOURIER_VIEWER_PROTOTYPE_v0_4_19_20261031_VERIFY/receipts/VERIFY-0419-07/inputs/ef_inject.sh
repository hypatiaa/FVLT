#!/bin/bash
# Verifier's injected-log test of build/check-expected-fails-v0419.cjs (unchanged), on the verifier's own full-run logs.
# usage: ef_inject.sh <build folder copy (with build/_logs from the verifier's run)> <work dir>
set -u
B=$(readlink -f "$1"); W=$(readlink -f "$2"); rm -rf "$W"; mkdir -p "$W"
CH="$B/build/check-expected-fails-v0419.cjs"; LIST="$B/build/EXPECTED_FAILS_v0419.txt"; NODE=$HOME/.local/bin/node
mk(){ rm -rf "$W/$1"; cp -a "$B/build/_logs" "$W/$1"; }
run(){ echo "=== case $1 (want exit $2)"; $NODE "$CH" --list "${4:-$LIST}" --logs "$W/$3" --summary "$W/$3/SUMMARY_v0419.txt" > "$W/$1.out" 2>&1; c=$?; grep -E "^(HOST|NOT THE|SUMMARY|FAIL)|^     " "$W/$1.out" | head -12; echo "case $1 exit=$c want=$2 $([ $c -eq $2 ] && echo OK || echo MISMATCH)"; }
# 0: real logs of the verifier's run
mk real; run 0-real 0 real
# 1: one injected FAIL line in a suite that expects none (test-v0419-pens)
mk inj; sed -i '0,/^PASS /s//FAIL VERIFIER-INJECTED /' "$W/inj/test-v0419-pens.run.log"; run 1-injected 1 inj
# 2: one expected FAIL line removed (first FAIL line of test-v0410)
mk rem; awk 'BEGIN{d=0} /^FAIL /&&!d{d=1;next} {print}' "$W/real/test-v0410.run.log" > "$W/rem/test-v0410.run.log"; run 2-removed 1 rem
# 3: a crash replacing a log (browser-check-v0414, which expects 2 FAIL lines), exit line set to the crash code 1
mk crash; printf 'node:internal/process\nTypeError: verifier-injected crash\n    at Object.<anonymous>\n' > "$W/crash/browser-check-v0414.run.log"; run 3-crash 1 crash
# 4: prints all its expected FAIL lines then crashes: test-v0410 (expected exit 1, 3 FAIL lines): keep every line up to the last FAIL, drop the rest (no SUMMARY),
#    append a stack trace; exit stays 1 (a crash exits 1 too), so only the missing SUMMARY can catch it
mk fc; f="$W/fc/test-v0410.run.log"; n=$(grep -n '^FAIL ' "$W/real/test-v0410.run.log" | tail -1 | cut -d: -f1); head -n "$n" "$W/real/test-v0410.run.log" > "$f"; printf 'TypeError: verifier-injected crash after the FAIL lines\n' >> "$f"; run 4-fails-then-crash 1 fc
# 4b: the same for a suite that expects exit 0 and no FAIL lines (test-v0419-pens): first 3 lines kept, then a crash; exit line set to 1
mk fc0; f="$W/fc0/test-v0419-pens.run.log"; head -n 3 "$W/real/test-v0419-pens.run.log" > "$f"; printf 'TypeError: verifier-injected crash\n' >> "$f"; sed -i 's/^test-v0419-pens exit=0/test-v0419-pens exit=1/' "$W/fc0/SUMMARY_v0419.txt"; run 4b-pass-then-crash 1 fc0
# 5: blind spot probe: every expected FAIL line AND the SUMMARY line printed, then a crash (test-v0410, exit stays 1): the checker cannot see it (want 0 = undetected)
mk fs; f="$W/fs/test-v0410.run.log"; cp "$W/real/test-v0410.run.log" "$f"; printf 'TypeError: verifier-injected crash after the SUMMARY line\n' >> "$f"; run 5-summary-then-crash 0 fs
# 6: wrong host: a copy of the list with another host of record -> exit 2
sed 's/^HOST membrane linux$/HOST neo win32/' "$LIST" > "$W/list_otherhost.txt"; run 6-wrong-host 2 real "$W/list_otherhost.txt"
# 7: an exit code changed alone (test-exact exit=0 -> exit=1 in the summary file)
mk ex; sed -i 's/^test-exact exit=0/test-exact exit=1/' "$W/ex/SUMMARY_v0419.txt"; run 7-exit-only 1 ex
