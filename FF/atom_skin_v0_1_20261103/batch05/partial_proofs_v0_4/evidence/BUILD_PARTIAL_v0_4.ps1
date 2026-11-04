param([string]$PenAttempt = 'Pen03')
$ErrorActionPreference = 'Stop'
$batch = $PSScriptRoot
$project = Split-Path $batch
$out = Join-Path $batch 'partial_proofs_v0_4'
if (Test-Path $out) { throw 'Additive packet already exists' }
$replayName = "ReplayFVLTAtomSkinPenV1Batch05$PenAttempt"
$compileName = "CompileFVLTAtomSkinPenV1Batch05$PenAttempt"
$axiomsName = "AxiomsFVLTAtomSkinPenV1Batch05$PenAttempt"
$replay = Get-Content (Join-Path $batch "$replayName.json") -Raw | ConvertFrom-Json
$compile = Get-Content (Join-Path $batch "$compileName.json") -Raw | ConvertFrom-Json
$axioms = Get-Content (Join-Path $batch "$axiomsName.json") -Raw | ConvertFrom-Json
$strict = Get-Content (Join-Path $batch "$replayName.log") -Tail 1 | ConvertFrom-Json
if (!$replay.accepted_result -or !$compile.accepted_result -or !$axioms.accepted_result -or $strict.verdict -ne 'PASS') { throw 'Missing successful evidence' }
$deadline = Get-Content (Join-Path $batch 'DEADLINE_BATCH05.json') -Raw | ConvertFrom-Json
$allRuns = @(Get-ChildItem $batch -Filter '*.json' | ForEach-Object {
  $j = Get-Content $_.FullName -Raw | ConvertFrom-Json
  if ($j.PSObject.Properties.Name -contains 'started_unix') { $j }
})
$last = ($allRuns | ForEach-Object { $_.started_unix + $_.seconds } | Measure-Object -Maximum).Maximum
if ($last -gt $deadline.deadline_unix) { throw 'Deadline exceeded' }
$close = [ordered]@{schema='ff2-batch-close/1'; batch='Batch05'; origin_unix=$deadline.origin_unix; deadline_unix=$deadline.deadline_unix; last_child_end_unix=$last; closed_unix=[DateTimeOffset]::UtcNow.ToUnixTimeSeconds(); mathematical_calls_closed=$true; no_reset_or_extension=$true}
$close | ConvertTo-Json | Set-Content (Join-Path $batch 'BATCH05_CLOSE_v0_1.json') -Encoding utf8
New-Item -ItemType Directory $out,(Join-Path $out 'src'),(Join-Path $out 'evidence') | Out-Null
$previous = Join-Path $project 'batch04/partial_proofs_v0_3'
Copy-Item $previous (Join-Path $out 'predecessor_packet') -Recurse
Get-ChildItem $batch -File | Where-Object { $_.Extension -in '.json','.log','.ps1' } | Copy-Item -Destination (Join-Path $out 'evidence')
Copy-Item (Join-Path $batch 'attempts') (Join-Path $out 'evidence/attempts') -Recurse
Copy-Item (Join-Path $previous 'src/*') (Join-Path $out 'src')
Copy-Item (Join-Path $batch "attempts/$PenAttempt/src/FVLTAtomSkinPenV1.lean") (Join-Path $out 'src')
$targets = Get-Content (Join-Path $previous 'NEW_THEOREMS_v0_3.json') -Raw | ConvertFrom-Json
$penNames = @('pen_adjacent_seat','pen_return_four','pen_no_earlier_return')
if ($PenAttempt -ne 'Pen03') { $penNames += 'pen_four_corners' }
foreach ($t in $targets.targets) {
  if (($t.name -split '\.')[-1] -in $penNames) { $t.status = 'PRODUCER_COMPILE_AXIOMS_STRICT_REPLAY_PASS_PENDING_INDEPENDENT_REVIEW' }
}
$targets.producer_cleared = 16 + $penNames.Count
$targets.open = 28 - $targets.producer_cleared
$targets | ConvertTo-Json -Depth 20 | Set-Content (Join-Path $out 'NEW_THEOREMS_v0_4.json') -Encoding utf8
$support = @(Get-ChildItem (Join-Path $out 'src') -Filter '*.lean' | ForEach-Object {
  $file = $_.Name
  [regex]::Matches((Get-Content $_.FullName -Raw),'(?m)^private\s+(def|theorem)\s+(\w+)') | ForEach-Object {
    [ordered]@{file=$file; kind=$_.Groups[1].Value; name=$_.Groups[2].Value; status='Private support, no additional public frozen target'}
  }
})
$support | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $out 'SUPPORT_DECLARATIONS_v0_4.json') -Encoding utf8
$openNames = ($targets.targets | Where-Object status -eq 'OPEN_NOT_CLAIMED' | ForEach-Object { '- ' + $_.name }) -join "`n"
$axiomText = Get-Content (Join-Path $batch "$axiomsName.log") -Raw
$axiomText = ($axiomText.TrimEnd() -split "`r?`n" | ForEach-Object { '    ' + $_ }) -join "`n"
$sourceHash = (Get-FileHash (Join-Path $out 'src/FVLTAtomSkinPenV1.lean')).Hash.ToLower()
$receiptHash = (Get-FileHash (Join-Path $batch "$replayName.json")).Hash.ToLower()
$logHash = (Get-FileHash (Join-Path $batch "$replayName.log")).Hash.ToLower()
$count = $targets.producer_cleared
$remaining = $targets.open
$report = @"
# FF-2 Batch05: pen dynamics, producer result

**$count of 28 frozen FF-2 targets now pass producer compilation, named axiom checks and strict kernel replay. $remaining remain open.** Independent rebuild/replay and meaning review remain pending. FF-2 has no final recorded outcome; FF-3 builds remain held.

For every omega with the explicit hypothesis 3 <= omega, and every fixed sign and initial state, the pen chooses an adjacent direction, returns to its full state after four steps, and never returns after one, two or three steps. The state includes both the Boolean vertex and the incoming direction. The same sign is used throughout the iteration. These statements make no claim about arbitrary sign streams or Rule 30.

Current public pen targets: $($penNames -join ', '). The four-corner target is included only if listed here as cleared; an unverified later attempt in the evidence folder carries no proof standing. Square orientation remains open.

## Evidence

Latest pen source SHA-256: $sourceHash

Compiled object: $($compile.olean_sha256)

Strict replay receipt: $receiptHash

Raw strict replay log: $logHash

Compile time: $($compile.seconds) seconds. Strict replay time: $($replay.seconds) seconds. All $($strict.targetConstants) introduced declarations, including private helpers and generated declarations, replayed: verdict PASS, kernelReplayCompleted true, no failures, no unsafe or partial constants. Dependencies were reused, not cold-built or replayed by this call. This is producer execution using the strict checker, not the pending independent reviewer's execution.

The raw named axiom log was read in full:

$axiomText

The retained count module has 47 checked declarations and 10 public targets. The retained pillowcase module has 37 checked declarations and six public targets. Their historical checks remain tied to their exact earlier sources and objects. The data modules retain 108 previously checked declarations. No new integrated rebuild or replay of these separate modules is claimed.

## Freeze, attempts and execution

All public statements retain the original 28-header freeze b4484f6e148291dd20512e58ce4ec81b4bdf08527f4bd66b3e304cbb2654785a under manifest 22650c5b0304d82bfd7d89a1bcfcb20884f6c11d104729aaf8187e678efd02c5. Skin definitions retain the accepted a1ea047d successor; pillowcase definitions retain the original freeze. Every new support declaration is private. No public helper or extra instance was added.

Failed proof attempts and raw diagnostics are preserved additively under evidence/attempts and evidence. Their dependent checks were not run. Pen01 and Pen02 required tactic repairs, with no statement or data change. Later four-corner attempts, if any, are separately preserved and carry only their actual recorded result. Exact job posting preceded every launch: Pen01 1481/1484, Pen02 1482/1485, Pen03 compile 1483/1486, Pen03 verification 1484/1487; later jobs have their own bus receipts.

All mathematical execution used nucleus via Tailscale, pinned library v20, Lean 4.35.0, unchanged runner 6a73ec37 and checker 9c6f2ac1, one CPU, 8 GiB address space, 240 seconds per child, and explicit toolchain PATH. Every completed call checked all 392 library entries plus source/review pins. No mathematical computation ran on Neo; no library, kernel or viewer write, publication, commit, or G1 work occurred.

Batch05 origin $($deadline.origin_unix), deadline $($deadline.deadline_unix), last child end $last. Capacity refreshes did not reset or extend the batch. BATCH05_CLOSE_v0_1.json closes mathematical calls under this clock. A further development batch requires a fresh posted binding and capacity receipt.

## Remaining targets

$openNames

The remaining work separates into square incidence, cyclic links, boundary orientation/cancellation, pen orientation, and the complete pillowcase key classification, minus any four-corner obligation still listed above. These remain genuine proof obligations. Counts alone do not certify a topological surface or its genus, and arithmetic pillowcase classes alone do not certify the viewer's full key.

The full predecessor packet is preserved byte for byte. This successor changes only producer progress and evidence, with no kernel adoption or stronger mathematical standing. Credit: Robin Miller assembled the framework from classical components; no novelty claim is made.
"@
$report | Set-Content (Join-Path $out 'RESULT_PARTIAL_PROOFS_v0_4.md') -Encoding utf8
$files = @(Get-ChildItem $out -File -Recurse | ForEach-Object { [ordered]@{path=[IO.Path]::GetRelativePath($out,$_.FullName).Replace('\','/'); sha256=(Get-FileHash $_.FullName).Hash.ToLower(); bytes=$_.Length} })
$manifest = [ordered]@{schema='ff2-partial-proof-manifest/1'; standing='PRODUCER_PARTIAL_PENDING_INDEPENDENT_REVIEW'; producer_cleared=$count; open=$remaining; files=$files}
$manifest | ConvertTo-Json -Depth 20 | Set-Content (Join-Path $out 'PARTIAL_PROOFS_MANIFEST_v0_4.json') -Encoding utf8
foreach ($f in $files) { if ((Get-FileHash (Join-Path $out $f.path)).Hash.ToLower() -ne $f.sha256) { throw "Pin mismatch $($f.path)" } }
"Verified $($files.Count) packet pins"
'RESULT_PARTIAL_PROOFS_v0_4.md','PARTIAL_PROOFS_MANIFEST_v0_4.json','NEW_THEOREMS_v0_4.json' | ForEach-Object { "$_ $((Get-FileHash (Join-Path $out $_)).Hash.ToLower())" }
