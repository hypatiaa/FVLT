param([string]$PenAttempt = '')
$ErrorActionPreference = 'Stop'
$batch = $PSScriptRoot
$project = Split-Path $batch
$out = Join-Path $batch 'partial_proofs_v0_5'
if (Test-Path $out) { throw 'Additive packet already exists' }
$countsReplay = Get-Content (Join-Path $batch 'ReplayFVLTAtomSkinCountsV1Batch06Counts04.json') -Raw | ConvertFrom-Json
$countsCompile = Get-Content (Join-Path $batch 'CompileFVLTAtomSkinCountsV1Batch06Counts04.json') -Raw | ConvertFrom-Json
$strict = Get-Content (Join-Path $batch 'ReplayFVLTAtomSkinCountsV1Batch06Counts04.log') -Tail 1 | ConvertFrom-Json
if (!$countsReplay.accepted_result -or !$countsCompile.accepted_result -or $strict.verdict -ne 'PASS') { throw 'Missing Counts04 verification' }
if ($PenAttempt) {
  $penReplay = Get-Content (Join-Path $batch "ReplayFVLTAtomSkinPenV1Batch06$PenAttempt.json") -Raw | ConvertFrom-Json
  $penCompile = Get-Content (Join-Path $batch "CompileFVLTAtomSkinPenV1Batch06$PenAttempt.json") -Raw | ConvertFrom-Json
  $penStrict = Get-Content (Join-Path $batch "ReplayFVLTAtomSkinPenV1Batch06$PenAttempt.log") -Tail 1 | ConvertFrom-Json
  if (!$penReplay.accepted_result -or !$penCompile.accepted_result -or $penStrict.verdict -ne 'PASS') { throw 'Missing new pen verification' }
}
$deadline = Get-Content (Join-Path $batch 'DEADLINE_BATCH06.json') -Raw | ConvertFrom-Json
$runs = @(Get-ChildItem $batch -Filter '*.json' | ForEach-Object {
  $j = Get-Content $_.FullName -Raw | ConvertFrom-Json
  if ($j.PSObject.Properties.Name -contains 'started_unix') { $j }
})
$last = ($runs | ForEach-Object { $_.started_unix + $_.seconds } | Measure-Object -Maximum).Maximum
if ($last -gt $deadline.deadline_unix) { throw 'Deadline exceeded' }
[ordered]@{schema='ff2-batch-close/1';batch='Batch06';origin_unix=$deadline.origin_unix;deadline_unix=$deadline.deadline_unix;last_child_end_unix=$last;closed_unix=[DateTimeOffset]::UtcNow.ToUnixTimeSeconds();mathematical_calls_closed=$true;no_reset_or_extension=$true} | ConvertTo-Json | Set-Content (Join-Path $batch 'BATCH06_CLOSE_v0_1.json') -Encoding utf8
New-Item -ItemType Directory $out,(Join-Path $out 'src'),(Join-Path $out 'evidence') | Out-Null
$previous = Join-Path $project 'batch05/partial_proofs_v0_4'
Copy-Item $previous (Join-Path $out 'predecessor_packet') -Recurse
Get-ChildItem $batch -File | Where-Object { $_.Extension -in '.json','.log','.ps1','.txt','.md' } | Copy-Item -Destination (Join-Path $out 'evidence')
Copy-Item (Join-Path $batch 'attempts') (Join-Path $out 'evidence/attempts') -Recurse
Copy-Item (Join-Path $previous 'src/*') (Join-Path $out 'src')
Copy-Item (Join-Path $batch 'attempts/Counts04/src/FVLTAtomSkinCountsV1.lean') (Join-Path $out 'src')
if ($PenAttempt) { Copy-Item (Join-Path $batch "attempts/$PenAttempt/src/FVLTAtomSkinPenV1.lean") (Join-Path $out 'src') }
$targets = Get-Content (Join-Path $previous 'NEW_THEOREMS_v0_4.json') -Raw | ConvertFrom-Json
$newNames = @('incident_pair_distinct','incident_pair_exhaustive','incident_square_count','incident_coefficients_opposite','total_boundary_zero','link_cycle')
if ($PenAttempt) { $newNames += 'pen_oriented_square' }
foreach ($t in $targets.targets) {
  if (($t.name -split '\.')[-1] -in $newNames) { $t.status = 'PRODUCER_COMPILE_AXIOMS_STRICT_REPLAY_PASS_PENDING_INDEPENDENT_REVIEW' }
}
$targets.producer_cleared = 20 + $newNames.Count
$targets.open = 28 - $targets.producer_cleared
$targets | ConvertTo-Json -Depth 20 | Set-Content (Join-Path $out 'NEW_THEOREMS_v0_5.json') -Encoding utf8
$support = @(Get-ChildItem (Join-Path $out 'src') -Filter '*.lean' | ForEach-Object {
  $file = $_.Name
  [regex]::Matches((Get-Content $_.FullName -Raw),'(?m)^private\s+(def|theorem)\s+(\w+)') | ForEach-Object { [ordered]@{file=$file;kind=$_.Groups[1].Value;name=$_.Groups[2].Value;standing='Private support only'} }
})
$support | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $out 'SUPPORT_DECLARATIONS_v0_5.json') -Encoding utf8
$openNames = ($targets.targets | Where-Object status -eq 'OPEN_NOT_CLAIMED' | ForEach-Object { '- ' + $_.name }) -join "`n"
$axiomText = Get-Content (Join-Path $batch 'AxiomsFVLTAtomSkinCountsV1Batch06Counts04.log') -Raw
$axiomText = ($axiomText.TrimEnd() -split "`r?`n" | ForEach-Object { '    ' + $_ }) -join "`n"
$penParagraph = 'The retained pen module has four checked public targets and 61 checked declarations, under its prior exact source and object. Pen orientation remains open. Later unverified attempts in evidence have no proof standing.'
if ($PenAttempt) {
  $penParagraph = "The pen module now proves all five frozen targets, including pen_oriented_square. For each state and fixed sign, its incoming and outgoing directed edges belong to one square and agree with that square boundary multiplied by the same sign. This identifies orientation, beyond the earlier four-corner and period-four laws. The pen source has $($penStrict.targetConstants) strictly replayed declarations. The raw five-name axiom report was read in full and contains only propext, Classical.choice and Quot.sound."
}
$count = $targets.producer_cleared
$remaining = $targets.open
$sourceHash = (Get-FileHash (Join-Path $out 'src/FVLTAtomSkinCountsV1.lean')).Hash.ToLower()
$replayHash = (Get-FileHash (Join-Path $batch 'ReplayFVLTAtomSkinCountsV1Batch06Counts04.json')).Hash.ToLower()
$report = @"
# FF-2 Batch06: square incidence, links and boundary cancellation

**$count of 28 frozen targets have passed producer compilation, named axiom checks and strict kernel replay. $remaining remain open.** Independent rebuild/replay and meaning review remain pending. This is not the final FF-2 outcome. FF-3 builds remain held.

## What the new counts proofs establish

For every omega with the explicit hypothesis 3 <= omega, each edge has exactly two distinct incident squares in the selected cyclic square structure. They are the squares labelled by the edge direction and its predecessor. The boundary coefficient is nonzero exactly for those two squares. One coefficient is epsilon at the edge's lower vertex; the other is its negative. Summing all square boundaries therefore gives zero as an exact finitely supported integer chain.

The link at every vertex is exactly the cycle on the labelled directions: i and j are linked precisely when j is next(i) or i is next(j). For the forward direction, a square's four corners keep every coordinate outside its two axes unchanged, so a toggle between corners must use one of those axes. The converse constructs the square explicitly. These are uniform theorems, with no bounded enumeration.

This completes all 16 frozen counts-module targets. It proves local combinatorial incidence, cycle links, and an algebraic orientation certificate. It does not construct a Lean topological realization, classify a surface, or identify the numerical genus invariant with a topological genus. The selected squares use cyclic neighbouring directions; they are not all two-dimensional faces of a higher-dimensional cube.

$penParagraph

The fixed-sign pen laws make no claim about arbitrary sign streams or Rule 30 dynamics. The full pillowcase key classification remains a separate obligation.

## Exact evidence

Counts source SHA-256: $sourceHash

Counts compiled object: $($countsCompile.olean_sha256)

Strict counts replay receipt: $replayHash

Strict raw counts replay log: $($countsReplay.log_sha256)

All $($strict.targetConstants) introduced counts declarations, including private helpers and generated declarations, replayed: PASS, kernelReplayCompleted true, failures empty, unsafe and partial constants zero. The fresh compile took $($countsCompile.seconds) seconds and strict replay $($countsReplay.seconds) seconds. Imported dependencies were reused, not cold-built or replayed by this checker. These are producer runs; independent reviewer execution remains pending.

The raw sixteen-name counts axiom report was read in full:

$axiomText

The retained pillowcase module has six checked public targets and 37 checked declarations. The two data modules retain their 108 separately checked declarations. Historical module versions are not added again to the latest totals. No fresh integrated rebuild/replay of these separate modules is claimed.

## Freeze and execution record

All public target headers match the original b4484f6e freeze under manifest 22650c5b. Skin data retains accepted successor a1ea047d under decision d6a666bd; pillowcase data retains its original namespace. All new support declarations are private; no extra public helper or instance was added. Full hashes and the exact closed file set are in the manifest and retained authority packet.

Counts01 failed on a variable eliminated by substitution, a renamed erase lemma, and a missing contradiction for distinct inserted vertices. Counts02 repaired only private proof bodies. Counts03 added the already-frozen total-boundary target; Counts04 added the already-frozen link-cycle target. Failed sources, raw logs and receipts remain preserved. The stale inherited status_scope text in COMPARE_COUNTS01 was disclosed before launch and corrected in successor comparisons; the actual header list and frozen mathematics were unaffected.

All mathematical calls used nucleus over Tailscale, pinned v20 and Lean 4.35.0, unchanged runner 6a73ec37 and checker 9c6f2ac1, one CPU, 8 GiB address space, at most 240 seconds per child, and explicit toolchain PATH. All 392 library entries and source/review pins passed after each completed call. Exact posting preceded each launch: Counts01 1491/1494, Counts02 1492/1495, Counts03 1493/1496, Counts04 1494/1497, Counts04 verification 1495/1498. Any later pen jobs have their own exact receipts in the bus record and evidence.

Batch06 origin $($deadline.origin_unix), deadline $($deadline.deadline_unix), last child end $last. Capacity refreshes never reset or extended the clock. BATCH06_CLOSE_v0_1.json closes mathematical calls for this batch. A subsequent batch needs a fresh posted binding and capacity receipt. No G1 work, Neo mathematical computation, kernel or viewer write, library publication/sync, commit, or release occurred.

## Remaining targets

$openNames

The predecessor packet remains byte-identical. NEW_THEOREMS_v0_5.json records every target's standing. Producer verification does not adopt a new kernel claim or finish the independent audit. Robin Miller assembled the framework from classical components; no novelty claim is made.
"@
$report | Set-Content (Join-Path $out 'RESULT_PARTIAL_PROOFS_v0_5.md') -Encoding utf8
$files = @(Get-ChildItem $out -File -Recurse | ForEach-Object { [ordered]@{path=[IO.Path]::GetRelativePath($out,$_.FullName).Replace('\','/');sha256=(Get-FileHash $_.FullName).Hash.ToLower();bytes=$_.Length} })
[ordered]@{schema='ff2-partial-proof-manifest/1';standing='PRODUCER_PARTIAL_PENDING_INDEPENDENT_REVIEW';producer_cleared=$count;open=$remaining;files=$files} | ConvertTo-Json -Depth 20 | Set-Content (Join-Path $out 'PARTIAL_PROOFS_MANIFEST_v0_5.json') -Encoding utf8
foreach ($f in $files) { if ((Get-FileHash (Join-Path $out $f.path)).Hash.ToLower() -ne $f.sha256) { throw "Pin mismatch $($f.path)" } }
"Verified $($files.Count) packet pins"
'RESULT_PARTIAL_PROOFS_v0_5.md','PARTIAL_PROOFS_MANIFEST_v0_5.json','NEW_THEOREMS_v0_5.json' | ForEach-Object { "$_ $((Get-FileHash (Join-Path $out $_)).Hash.ToLower())" }
