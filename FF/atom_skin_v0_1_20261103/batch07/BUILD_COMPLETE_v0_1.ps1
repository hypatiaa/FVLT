$ErrorActionPreference = 'Stop'
$batch = $PSScriptRoot
$project = Split-Path $batch
$out = Join-Path $batch 'producer_complete_v0_1'
if (Test-Path $out) { throw 'Complete packet already exists; preserve it' }
$compile = Get-Content (Join-Path $batch 'CompileFVLTPillowcaseV1Batch07Pillow02.json') -Raw | ConvertFrom-Json
$replay = Get-Content (Join-Path $batch 'ReplayFVLTPillowcaseV1Batch07Pillow02.json') -Raw | ConvertFrom-Json
$axioms = Get-Content (Join-Path $batch 'AxiomsFVLTPillowcaseV1Batch07Pillow02.json') -Raw | ConvertFrom-Json
$strict = Get-Content (Join-Path $batch 'ReplayFVLTPillowcaseV1Batch07Pillow02.log') -Tail 1 | ConvertFrom-Json
if (!$compile.accepted_result -or !$replay.accepted_result -or !$axioms.accepted_result -or $strict.verdict -ne 'PASS') { throw 'Missing final verification' }
$deadline = Get-Content (Join-Path $batch 'DEADLINE_BATCH07.json') -Raw | ConvertFrom-Json
$runs = @(Get-ChildItem $batch -Filter '*.json' | ForEach-Object {
  $j = Get-Content $_.FullName -Raw | ConvertFrom-Json
  if ($j.PSObject.Properties.Name -contains 'started_unix') { $j }
})
$last = ($runs | ForEach-Object { $_.started_unix + $_.seconds } | Measure-Object -Maximum).Maximum
if ($last -gt $deadline.deadline_unix) { throw 'Batch deadline exceeded' }
[ordered]@{schema='ff2-batch-close/1';batch='Batch07';origin_unix=$deadline.origin_unix;deadline_unix=$deadline.deadline_unix;last_child_end_unix=$last;closed_unix=[DateTimeOffset]::UtcNow.ToUnixTimeSeconds();mathematical_calls_closed=$true;no_reset_or_extension=$true} | ConvertTo-Json | Set-Content (Join-Path $batch 'BATCH07_CLOSE_v0_1.json') -Encoding utf8
New-Item -ItemType Directory $out,(Join-Path $out 'src'),(Join-Path $out 'evidence') | Out-Null
$previous = Join-Path $project 'batch06/partial_proofs_v0_5'
Copy-Item $previous (Join-Path $out 'predecessor_packet') -Recurse
Get-ChildItem $batch -File | Where-Object { $_.Extension -in '.json','.log','.ps1','.txt','.md' } | Copy-Item -Destination (Join-Path $out 'evidence')
Copy-Item (Join-Path $batch 'attempts') (Join-Path $out 'evidence/attempts') -Recurse
Copy-Item (Join-Path $previous 'src/*') (Join-Path $out 'src')
Copy-Item (Join-Path $batch 'attempts/Pillow02/src/FVLTPillowcaseV1.lean') (Join-Path $out 'src')
$targets = Get-Content (Join-Path $previous 'NEW_THEOREMS_v0_5.json') -Raw | ConvertFrom-Json
foreach ($t in $targets.targets) {
  if ($t.name -eq 'FVLT.PillowcaseV1.key_classifies') { $t.status = 'PRODUCER_COMPILE_AXIOMS_STRICT_REPLAY_PASS_PENDING_INDEPENDENT_REVIEW' }
  if ($t.status -ne 'PRODUCER_COMPILE_AXIOMS_STRICT_REPLAY_PASS_PENDING_INDEPENDENT_REVIEW') { throw "Uncleared target $($t.name)" }
}
$targets.producer_cleared = 28
$targets.open = 0
$targets | ConvertTo-Json -Depth 20 | Set-Content (Join-Path $out 'NEW_THEOREMS_v0_6.json') -Encoding utf8
$pins = @(Get-ChildItem (Join-Path $out 'src') -Filter '*.lean' | ForEach-Object {
  $s = Get-Content $_.FullName -Raw
  if ($s -match '\b(sorry|admit|axiom|native_decide|implemented_by|unsafe|extern)\b') { throw "Forbidden token $($_.Name)" }
  [ordered]@{file=$_.Name;sha256=(Get-FileHash $_.FullName).Hash.ToLower();bytes=$_.Length;public_theorems=[regex]::Matches($s,'(?m)^theorem\s+').Count;private_support=[regex]::Matches($s,'(?m)^private\s+(def|theorem)\s+').Count}
})
$pins | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $out 'CURRENT_SOURCE_PINS_v0_1.json') -Encoding utf8
$support = @(Get-ChildItem (Join-Path $out 'src') -Filter '*.lean' | ForEach-Object {
  $file = $_.Name
  [regex]::Matches((Get-Content $_.FullName -Raw),'(?m)^private\s+(def|theorem)\s+(\w+)') | ForEach-Object { [ordered]@{file=$file;kind=$_.Groups[1].Value;name=$_.Groups[2].Value;standing='Private support only'} }
})
$support | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $out 'SUPPORT_DECLARATIONS_v0_6.json') -Encoding utf8
$axiomText = (Get-Content (Join-Path $batch 'AxiomsFVLTPillowcaseV1Batch07Pillow02.log') | ForEach-Object { '    ' + $_ }) -join "`n"
$sourceHash = (Get-FileHash (Join-Path $out 'src/FVLTPillowcaseV1.lean')).Hash.ToLower()
$receiptHash = (Get-FileHash (Join-Path $batch 'ReplayFVLTPillowcaseV1Batch07Pillow02.json')).Hash.ToLower()
$proofCount = 100 + 87 + $strict.targetConstants
$allCount = 108 + $proofCount
$report = @"
# FF-2 producer-complete handoff

**All 28 frozen FF-2 targets now pass producer compilation, named axiom checks and strict all-constant kernel replay. No target proof remains open.** Independent rebuild/replay and meaning review remain pending. The final FF-2 outcome is NOT RECORDED, and FF-3 builds remain HELD.

## The last theorem

For all positive natural a and b and all integer points v and w, Lean proves:

    key a b v = key a b w ↔ pillowRel a b v w

Both key and pillowRel are the actual frozen definitions. The key equality is equivalent to a permitted translation or half-turn, with integer witnesses; it is not merely a sufficient collision test or a finite example check. The relation negates both coordinates together in the half-turn branch.

The proof reduces an integer point modulo 2a and 2b, carries it through the actual net normalization, and decodes its key to a canonical point in 0 <= x < 2a, 0 <= y <= b, with x <= a on the horizontal boundary. Each input is related to its decoded point. Related canonical points are equal: translation is ruled out by the residue bounds, and a half-turn between normalized points forces both onto a common horizontal boundary, where the remaining x bounds force equality. The proof also establishes the key roundtrip on decoded points. These facts give both directions of the frozen iff.

Zero residues, a = 1 or b = 1, horizontal boundary identifications, and the permitted half-turn centre (0,0) are included in the universal statement. All hypotheses are explicit binders. The seven public pillowcase theorem headers are unchanged from the accepted freeze; all 30 support definitions/theorems in the pillowcase source are private.

This is a mathematical contract for the viewer's classifier. It does not by itself verify an HTML or JavaScript implementation against that contract.

## What the complete FF-2 collection covers

The counts module proves its 16 frozen targets: exact vertex, edge and selected-square counts; Euler and numerical genus identities; cube edges and connectivity; two-square incidence and opposite coefficients; the cycle link at each vertex; and cancellation of the total integer boundary chain.

The pen module proves all five frozen targets: adjacent direction, a common oriented square for incoming/outgoing edges, exact four-step return with no earlier full-state return, and equality of the four visited vertices with one square's corners. The same sign is fixed through an iteration; arbitrary sign streams and Rule 30 forcing are separate questions.

The pillowcase module proves all seven frozen targets: the group relation, the full key classifier, nonidentity half-turns, fixing-point and corner characterizations, distinct corner classes, and absence of fixed points for nonzero translations.

No topological realization or surface-classification theorem has been added, and the numerical genus is not identified in Lean with a topological genus. No kernel claim is adopted or upgraded by this producer result. This work is the FF-2 instrument-tier collection, not a statement that every FVLT kernel item or a Rule 30 prize problem has been proved.

## Final key-module evidence

Source SHA-256: $sourceHash

Compiled object: $($compile.olean_sha256)

Strict replay receipt: $receiptHash

Raw strict replay log: $($replay.log_sha256)

All $($strict.targetConstants) introduced pillowcase declarations, including private helpers and generated declarations, replayed: verdict PASS, kernelReplayCompleted true, no failures, no unsafe or partial constants. The compile took $($compile.seconds) seconds and strict replay $($replay.seconds) seconds. Cached imported dependencies were reused; this is not a cold build or a replay of those dependencies.

The raw seven-name axiom report was read in full:

$axiomText

The latest proof modules have 100 + 87 + $($strict.targetConstants) = $proofCount separately checked declarations. The prior two data modules have 53 + 55 = 108 separately checked declarations. No fresh integrated $allCount-declaration rebuild/replay is claimed. The independent handoff asks for a clean build of all five sources and strict replay of all introduced constants.

## Freeze and bounded execution

The original signature manifest is 22650c5b0304d82bfd7d89a1bcfcb20884f6c11d104729aaf8187e678efd02c5; the 28-header freeze is b4484f6e148291dd20512e58ce4ec81b4bdf08527f4bd66b3e304cbb2654785a. Skin data remains accepted successor a1ea047d under decision d6a666bd. Pillowcase data retains its original frozen namespace and checked object, not the skin successor definitions.

Pillow01 failed in two private normalization helpers: one net-coordinate bound remained folded, and a Nat remainder rewrite was attempted after casting it to Int. Pillow02 changed only those proof steps. Both source versions, raw logs and receipts are preserved; no dependent check ran on the failed attempt. No public header, data definition, imported project module or hypothesis changed.

All mathematical calls ran on nucleus over Tailscale using pinned library v20, Lean 4.35.0, unchanged runner 6a73ec37 and checker 9c6f2ac1, one CPU, 8 GiB address space, at most 240 seconds per child and explicit toolchain PATH. All 392 library entries and source/review pins passed after every completed call. Exact job posting preceded each launch: Pillow01 #1502/ledger1505, Pillow02 #1503/ledger1506; final axiom/replay jobs have their own exact prospective receipt in the bus record.

Batch07 origin $($deadline.origin_unix), deadline $($deadline.deadline_unix), last child end $last. Capacity refreshes did not reset or extend it. BATCH07_CLOSE_v0_1.json closes mathematical execution under this clock. No G1 work, Neo mathematical computation, kernel/viewer/library write, hosted check, publication, commit or release occurred.

## Outstanding acceptance work

The producer proof list is complete. What remains is the independent clean rebuild, named axiom reporting, strict replay and semantic/fidelity review under the accepted gates, followed by the manager's recorded FF-2 outcome. FF-3 builds remain held until that outcome. See AUDIT_HANDOFF_v0_1.md and the complete closed manifest.

The entire predecessor packet is retained byte for byte. Robin Miller assembled the framework from classical components; no novelty claim is made.
"@
$report | Set-Content (Join-Path $out 'RESULT_FF2_PRODUCER_COMPLETE_v0_1.md') -Encoding utf8
$handoff = @"
# FF-2 independent audit handoff

Standing: producer complete, 28/28 targets; NOT independent acceptance or the final FF-2 outcome. FF-3 builds remain held.

The closed manifest covers the five current Lean sources in src, all 28 target standings, private-support inventory, current source pins, this batch's evidence, and the complete byte-preserved predecessor packet. Verify every listed hash and size before execution. The original signature manifest and header freeze are named in the result report. Preserve each source's exact historical version and the accepted skin-data repair.

For a fresh independent execution, bind a separate nucleus workspace over Tailscale with current capacity/reservation, pinned toolchain/library/checker and fresh bounded jobs under the accepted review gates. Verify the current library before proceeding; the producer evidence is v20. A changed latest library or toolchain requires binding review rather than silently relabelling old results.

Build from the five pinned source files into a fresh object directory, without producer object files. Dependency order: FVLTAtomSkinDataV1, FVLTAtomSkinCountsV1, FVLTAtomSkinPenV1, FVLTPillowcaseDataV1, FVLTPillowcaseV1. Counts and Pen import only the skin data project module; Pillowcase imports only its original data project module. Other imports are targeted Mathlib/core modules. Exclude G1 from the recursive project import closure.

Perform fresh compilation, read raw named axiom reports for all 28 targets, and run the unchanged strict checker on every introduced constant in all five modules, including data, private helpers and generated declarations. Keep these checks distinct. Accepted named axioms are only propext, Classical.choice and Quot.sound. Existing cached Mathlib imports do not constitute a cold build or dependency replay. Do not alter producer evidence to repair audit harness issues; record additive fixes separately.

Compare all public declarations against the frozen definitions and 28 headers, checking that every hypothesis is an explicit binder and that all extra support is private. Review meaning independently: selected squares are cyclic-neighbour axes; boundary coefficients use the fixed orientation convention; genus is numerical; fixed-sign full-state pen return is not arbitrary-sign or Rule 30 periodicity; key classification is for the actual net/key and simultaneous-coordinate half-turn relation, with boundary and zero-residue cases included. The frozen Lean definitions do not themselves certify a viewer implementation or an unproved topological realization.

Record independent execution and semantic review separately, then issue the scoped FF-2 outcome. Producer-complete status alone does not open FF-3 execution, alter the locked FVLT kernel, publish a library, or authorize a hosted submission. No additional mathematical statement is proposed by this handoff.
"@
$handoff | Set-Content (Join-Path $out 'AUDIT_HANDOFF_v0_1.md') -Encoding utf8
$files = @(Get-ChildItem $out -File -Recurse | ForEach-Object { [ordered]@{path=[IO.Path]::GetRelativePath($out,$_.FullName).Replace('\','/');sha256=(Get-FileHash $_.FullName).Hash.ToLower();bytes=$_.Length} })
[ordered]@{schema='ff2-producer-complete-manifest/1';standing='PRODUCER_COMPLETE_PENDING_INDEPENDENT_REBUILD_REPLAY_AND_MEANING_REVIEW';producer_cleared=28;open=0;ff2_final_outcome='NOT_RECORDED';ff3_builds='HELD';files=$files} | ConvertTo-Json -Depth 20 | Set-Content (Join-Path $out 'FF2_PRODUCER_COMPLETE_MANIFEST_v0_1.json') -Encoding utf8
foreach ($f in $files) { if ((Get-FileHash (Join-Path $out $f.path)).Hash.ToLower() -ne $f.sha256) { throw "Pin mismatch $($f.path)" } }
"Verified $($files.Count) packet pins"
'RESULT_FF2_PRODUCER_COMPLETE_v0_1.md','FF2_PRODUCER_COMPLETE_MANIFEST_v0_1.json','NEW_THEOREMS_v0_6.json','AUDIT_HANDOFF_v0_1.md' | ForEach-Object { "$_ $((Get-FileHash (Join-Path $out $_)).Hash.ToLower())" }
