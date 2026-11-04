$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot
$manifest = Join-Path $root 'PACKET_MANIFEST_v0_1.json'
if (Test-Path $manifest) { throw 'Preserve the existing packet; use an additive successor' }
$artifacts = @(Get-ChildItem $root -Recurse -File | Where-Object { $_.Name -notin @('PACKET_MANIFEST_v0_1.json','SHA256SUMS.txt') })
$sumLines = @($artifacts | Sort-Object FullName | ForEach-Object { (Get-FileHash $_.FullName).Hash.ToLower() + ' *' + [IO.Path]::GetRelativePath($root,$_.FullName).Replace('\','/') })
$sumLines | Set-Content (Join-Path $root 'SHA256SUMS.txt') -Encoding utf8
$files = @(Get-ChildItem $root -Recurse -File | Where-Object Name -ne 'PACKET_MANIFEST_v0_1.json' | Sort-Object FullName | ForEach-Object {
  [ordered]@{path=[IO.Path]::GetRelativePath($root,$_.FullName).Replace('\','/');sha256=(Get-FileHash $_.FullName).Hash.ToLower();bytes=$_.Length}
})
[ordered]@{schema='ff3-freeze-review-packet/1';date='2026-11-04';standing='PROPOSED_AWAITING_INPUT_SIGNATURE_TEMPLATE_RUNNER_ACCEPTANCE';theorem_targets=37;explicit_data_declarations=19;lean_invoked=$false;proof_drafted=$false;runner_executed=$false;mathematical_result=$false;library_version=21;inherited_project_sources=6;files=$files} | ConvertTo-Json -Depth 15 | Set-Content $manifest -Encoding utf8
foreach ($f in $files) {
  $p = Join-Path $root $f.path
  if ((Get-FileHash $p).Hash.ToLower() -ne $f.sha256 -or (Get-Item $p).Length -ne $f.bytes) { throw "Pin mismatch $($f.path)" }
}
"Manifest covers $($files.Count) files; all hashes and sizes reverified"
'PACKET_MANIFEST_v0_1.json','FF3_DEFINITIONS_PROPOSED_v0_1.lean.txt','FF3_HEADERS_PROPOSED_v0_1.lean.txt','INPUT_FREEZE_v0_1.json','JOB_TEMPLATE_v0_1.json','RUN_FF3_v0_1.py','REVIEW_REQUEST_v0_1.md' | ForEach-Object { "$_ $((Get-FileHash (Join-Path $root $_)).Hash.ToLower())" }
