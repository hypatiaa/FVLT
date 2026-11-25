#!/bin/bash
# usage: run_suite.sh TAG BUILD_DIR  -- runs BUILD_DIR/build/runall.sh once, holding the membrane lock (flock -n), with Playwright on NODE_PATH
TAG=$1; DIR=$2; cd $HOME/membrane_compute/viewer/v0419
export NODE_PATH=$HOME/opt/playwright-1.61.1/node_modules PATH=$HOME/.local/bin:$PATH
date -u +%FT%TZ > $TAG.start
flock -n $HOME/membrane_compute/.lock bash $DIR/build/runall.sh > $TAG.out 2>&1; echo EXIT=$? > $TAG.done; date -u +%FT%TZ >> $TAG.done
