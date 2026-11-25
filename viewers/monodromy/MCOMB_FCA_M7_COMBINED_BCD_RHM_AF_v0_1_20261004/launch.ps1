$ErrorActionPreference = 'Stop'
# The Node server chooses an ephemeral port and binds only 127.0.0.1.
& node (Join-Path $PSScriptRoot 'server.cjs')
exit $LASTEXITCODE
