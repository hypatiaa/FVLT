#!/bin/bash
# usage: job.sh JOB_ID WORKDIR PREREG_TEXT -- cmd args...   (runs through run_capped_v2.sh, 4096 MiB, 1800 s; node and sage by name on PATH)
JOB=$1; WD=$2; TXT=$3; shift 3; [ "$1" = "--" ] && shift
cd "$WD" || exit 2
P=prereg_$JOB.txt; printf "%s\n" "$TXT" > $P
export PATH=$HOME/.local/bin:$PATH
$HOME/membrane_compute/run_capped_v2.sh $JOB $P 4096 1800 -- "$@"; RC=$?
echo "RUNNER_EXIT=$RC"; D=$HOME/membrane_compute/jobs/$JOB; [ -f $D/stdout.txt ] && tail -40 $D/stdout.txt; [ -s $D/stderr.txt ] && { echo STDERR:; tail -10 $D/stderr.txt; }
exit $RC
