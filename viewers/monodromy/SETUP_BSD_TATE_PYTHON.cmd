@echo off
rem One-time setup for the BSD Tate verifier used by the monodromy viewer (/assess).
rem Creates .bsd-audit-venv here and installs jsonschema 4.26.0 from PyPI. Needs Python 3.9 or newer.
cd /d "%~dp0"
py -3 -m venv .bsd-audit-venv || python -m venv .bsd-audit-venv
.bsd-audit-venv\Scripts\python.exe -m pip install -r requirements-bsd-tate.txt
pause
