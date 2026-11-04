$ErrorActionPreference = 'Stop'
$packet = $PSScriptRoot
$project = Split-Path $packet
function Hash([string]$p) { (Get-FileHash -LiteralPath $p).Hash.ToLower() }
Copy-Item (Join-Path $project 'EXECUTION_GO_RELAY_20261104.md') (Join-Path $packet 'inputs/EXECUTION_GO_RELAY_20261104.md')
$headers = Get-Content (Join-Path $packet 'FF3_HEADERS_PROPOSED_v0_1.lean.txt')
$module = $null
$targets = @()
foreach ($line in $headers) {
  if ($line -match '^-- (FVLTRosetteFord\w+):') { $module = $Matches[1] }
  if ($line -match '^theorem\s+(\w+)') {
    if (!$module) { throw 'Header without module mapping' }
    $name = $Matches[1]
    $targets += [ordered]@{name="FVLT.PhasorFordV1.$name";module=$module;standing='PROPOSED_NO_PROOF';source='FF3 WORK_ORDER_v0_2 plus accepted signature precisions';kernel_status_effect='none'}
  }
}
if ($targets.Count -ne 37 -or ($targets.name | Sort-Object -Unique).Count -ne 37) { throw 'Target inventory mismatch' }
$dataNames = @()
foreach ($line in Get-Content (Join-Path $packet 'FF3_DEFINITIONS_PROPOSED_v0_1.lean.txt')) {
  if ($line -match '^(?:(?:noncomputable\s+)?def|structure|inductive)\s+(\w+)') { $dataNames += "FVLT.PhasorFordV1.$($Matches[1])" }
}
[ordered]@{schema='ff3-target-index/1';status='PROPOSED';data_module='FVLTRosetteFordDataV1';data_axiom_targets=$dataNames;target_count=37;targets=$targets} | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $packet 'TARGET_INDEX_v0_1.json') -Encoding utf8
$libraryPins = [ordered]@{
  SHA256SUMS='648ac325c5df362b0a034dab3ee1e0bd495982d33f0ead433293168ba6c269cc'
  'LIBRARY_MANIFEST.json'='799b3baa0b61f227d626c36016ebda8180645abf92127f331fdd23a2d2779a81'
  'lake-manifest.json'='1f0e0c1c0a06e2a9ecc117aed82f7a8ee62b418235e10686d3bda2d6986ea527'
  'lakefile.toml'='5c9941e381b3821cabc50e28a7446a373ecec77f6fc5780543b8d2205de8f66f'
  'lean-toolchain'='ca5f1f601d34c49079e38d7e7041eb0f2a9c227fbc1df0f404820069a052330c'
}
$observed = [ordered]@{}
foreach ($name in $libraryPins.Keys) {
  $observed[$name] = Hash (Join-Path $packet "inputs/library_metadata/$name")
  if ($observed[$name] -ne $libraryPins[$name]) { throw "Metadata mismatch $name" }
}
$oldKernel = Get-Content (Join-Path $packet 'inputs/REFERENCE_KERNEL_v3_3_1.md') -Raw
$newKernel = Get-Content (Join-Path $packet 'inputs/CURRENT_KERNEL_v3_4_0.md') -Raw
$oldPart = [regex]::Match($oldKernel,'(?ms)^## II\.5 .*?(?=^## II\.6 )').Value
$newPart = [regex]::Match($newKernel,'(?ms)^## II\.5 .*?(?=^## II\.6 )').Value
if (!$oldPart -or $oldPart -cne $newPart) { throw 'Kernel II.5 comparison mismatch' }
$sourceClosure = Get-Content (Join-Path $packet 'INPUT_LIBRARY_SOURCE_CLOSURE_v0_1.json') -Raw | ConvertFrom-Json
foreach ($r in $sourceClosure.project_imports) {
  if ((Hash (Join-Path $packet "inputs/library_sources/$($r.module).lean")) -ne $r.sha256) { throw 'Inherited source mismatch' }
}
$input = [ordered]@{
  schema='ff3-input-freeze/1';date='2026-11-04';status='PROPOSED_AWAITING_REVIEW'
  observation_started_unix=1793774099;host='nucleus';transport='Tailscale [ts-redacted1]'
  observation_window='Read-only observations began at1793774099 and continued during packet preparation on2026-11-04; not an execution capacity receipt'
  library='/home/saphir/rule30_theorem_library/v21';latest_observed_version=21
  library_expected=$libraryPins;library_observed=$observed;checksum_entries=397;checksum_failures=0;writable_paths=0
  expected_basis='Explicit current v21 records and SHA256SUMS; changed library snapshot is returned for this review, not silently rebound'
  toolchain='leanprover/lean4:v4.35.0';lean_executable='/home/saphir/.elan/toolchains/leanprover--lean4---v4.35.0/bin/lean'
  lean_expected_sha256='bf8d54e4714cc4b03d3f6bb34c83b7202b87e49c8bfcbff6895c085bb90ceb38'
  lean_observed_sha256='bf8d54e4714cc4b03d3f6bb34c83b7202b87e49c8bfcbff6895c085bb90ceb38'
  mathlib_expected_rev='56a005855ea17e0b0958f73ec801ae140b0a1679';mathlib_observed_rev='56a005855ea17e0b0958f73ec801ae140b0a1679'
  checker_sha256=(Hash (Join-Path $packet 'IndependentFVLTReplay435.lean'))
  inherited_project_source_count=$sourceClosure.project_imports.Count;inherited_source_observation='All six local audited sources matched nucleus v21 sha256sum observations'
  historical_kernel_sha256=(Hash (Join-Path $packet 'inputs/REFERENCE_KERNEL_v3_3_1.md'))
  current_kernel_sha256=(Hash (Join-Path $packet 'inputs/CURRENT_KERNEL_v3_4_0.md'))
  kernel_II5_text_identical=$true;kernel_II5_characters=$oldPart.Length
  reference_lemma6a='UNAUDITED reference only; not an import or assumption'
  inspected_api_sources=@(
    [ordered]@{path='Mathlib/Analysis/SpecialFunctions/Trigonometric/Basic.lean';sha256='55b385f7abb43dd591acc7d548d1de8c3dba6111f79d60814d47b000d8f3bce7'}
    [ordered]@{path='Mathlib/Analysis/Complex/Exponential.lean';sha256='35d9f9e6abaf24d09a25cb1eeefbfc4180c3fe18de4d47362704c2f9f6601146'}
    [ordered]@{path='Mathlib/Data/Rat/Lemmas.lean';sha256='4f51b10ea64768413aadccceda80f0a2a7c339d4b01588e67a4b6f16a85bcd84'}
  )
  execution_capacity='UNBOUND: fresh capacity, reservation and batch deadline required after review'
  no_lean_or_numerical_proof_execution=$true;g1_excluded=$true;dependency_replay_claimed=$false
}
$input | ConvertTo-Json -Depth 15 | Set-Content (Join-Path $packet 'INPUT_FREEZE_v0_1.json') -Encoding utf8
$template = [ordered]@{
  schema='ff3-job-template/1';status='PROPOSED_AWAITING_INPUT_SIGNATURE_TEMPLATE_RUNNER_REVIEW';phase='FF3_DISCRETE'
  host='nucleus';transport='Tailscale [ts-redacted1]';root='/home/saphir/fvlt_formalization_20261104/ff3_v02'
  library=$input.library;library_expected=$libraryPins;toolchain=$input.toolchain;mathlib_rev=$input.mathlib_observed_rev
  lean_executable_sha256=$input.lean_observed_sha256
  runner='RUN_FF3_v0_1.py';runner_sha256=(Hash (Join-Path $packet 'RUN_FF3_v0_1.py'))
  checker='IndependentFVLTReplay435.lean';checker_sha256=$input.checker_sha256
  definitions_file='FF3_DEFINITIONS_PROPOSED_v0_1.lean.txt';definitions_sha256=(Hash (Join-Path $packet 'FF3_DEFINITIONS_PROPOSED_v0_1.lean.txt'))
  headers_file='FF3_HEADERS_PROPOSED_v0_1.lean.txt';headers_sha256=(Hash (Join-Path $packet 'FF3_HEADERS_PROPOSED_v0_1.lean.txt'))
  target_index_file='TARGET_INDEX_v0_1.json';target_index_sha256=(Hash (Join-Path $packet 'TARGET_INDEX_v0_1.json'))
  module_order=@('FVLTRosetteFordDataV1','FVLTRosetteFordPhaseV1','FVLTRosetteFordArithmeticV1','FVLTRosetteFordSweepV1','FVLTRosetteFordEndpointsV1')
  modes=@('compile','axioms','replay');cpu_jobs=1;address_space_bytes=8589934592;lean_memory_mb=7680;lean_stack_kb=65536
  process_limit=256;output_file_limit_bytes=67108864;child_wall_cap_seconds=240;batch_wall_cap_seconds=1800
  deadline_origin='Before proof writing/staging; new fresh clock per development batch, never extended/reset inside a batch'
  fresh_capacity='Pinned nucleus observation with age between0and600seconds at actual launch; separate current host reservation/owner reference'
  binding_required_fields=@('signature_freeze_sha256','host_reservation_reference','fresh_capacity_receipt_file','fresh_capacity_receipt_sha256')
  proposed_binding_policy='Only status plus four binding fields may differ after explicit review acceptance; acceptance-on-exact-posting is REQUESTED, not assumed'
  concrete_job_required_fields=@('phase','module','mode','run_id','template_sha256','attempt_folder','source_sha256','dependency_olean_sha256','prerequisite_receipt_sha256','signature_comparison_receipt_file','signature_comparison_receipt_sha256','deadline_file')
  mode_specific_fields=[ordered]@{replay=@('own_compile_receipt_file');axioms=@('own_compile_receipt_file','axiom_report_source','axiom_report_source_sha256','axiom_targets')}
  comparison_required_fields=@('verdict','source_sha256','freeze_sha256','g1_import_closure_excluded','all_present_public_headers_match','data_definitions_exact','axiom_report_targets')
  imported_local_sources='Every imported new source must also be staged and pinned in source_sha256; inherited project sources are checked against readonly v21'
  compile_repair='Stop item and dependents on failure; preserve attempt; same-signature private proof repairs only under reviewed policy and fresh exact posted job'
  axioms='Actual raw named reports parsed by runner and delivered verbatim; only propext/Classical.choice/Quot.sound'
  strict_replay='All introduced constants, including data/helpers/generated; positive target count; PASS/complete/zero failures/unsafe/partial'
  excluded=@('G1','Neo mathematical computation','Wolfram restart','oriented continuous arcs','dynamical correspondence','unlabelled-phasor inverse','factoring advantage','register identification','viewer edits','kernel adoption','library writes/publication','commits','hosted submission')
}
$template | ConvertTo-Json -Depth 15 | Set-Content (Join-Path $packet 'JOB_TEMPLATE_v0_1.json') -Encoding utf8
[ordered]@{
  schema='ff3-review-acceptance-EXAMPLE/1';status='EXAMPLE_ONLY_NOT_AUTHORIZATION'
  input_signature_acceptance=$null;template_acceptance=$null;runner_sha256=$template.runner_sha256
  bound_template_file=$null;bound_template_sha256=$null;accepted_job_sha256=@();reviewed_files=[ordered]@{}
} | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $packet 'REVIEW_ACCEPTANCE_EXAMPLE_v0_1.json') -Encoding utf8
[ordered]@{
  status='EXAMPLE_NOT_AN_EXECUTABLE_JOB';phase='FF3_DISCRETE';module='FVLTRosetteFordDataV1';mode='compile';run_id='ExampleOnlyDataCompile'
  template_sha256=$null;attempt_folder='attempts/EXAMPLE_NOT_STAGED';source_sha256=[ordered]@{};dependency_olean_sha256=[ordered]@{};prerequisite_receipt_sha256=[ordered]@{}
  signature_comparison_receipt_file=$null;signature_comparison_receipt_sha256=$null;deadline_file=$null
} | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $packet 'CONCRETE_JOB_EXAMPLE_v0_1.json') -Encoding utf8
"Prepared $($targets.Count) theorem headers and $($dataNames.Count) explicit data declarations; no Lean execution"
