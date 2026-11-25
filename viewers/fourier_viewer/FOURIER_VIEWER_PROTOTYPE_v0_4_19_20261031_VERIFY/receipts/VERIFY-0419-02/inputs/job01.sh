#!/bin/bash
cd "$(dirname "$0")"
mkdir -p out01
$HOME/.local/bin/node verify_0419.cjs orig/FOURIER_VIEWER_PROTOTYPE_v0_4_19_20261031 orig/FOURIER_VIEWER_PROTOTYPE_v0_4_18_20261031 out01
