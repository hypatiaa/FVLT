@echo off
rem Starts the merged viewer v0.1.2 NOCHECK (2026-11-25): no startup integrity chain; the viewer pin check is kept.
rem Unsealed; local use allowed 2026-10-07. Close this window or press Ctrl-C to stop it.
cd /d "%~dp0MCOMB_FCA_M7_COMBINED_BCD_RHM_AF_v0_1_2_NOCHECK_20261125"
node server.cjs
pause
