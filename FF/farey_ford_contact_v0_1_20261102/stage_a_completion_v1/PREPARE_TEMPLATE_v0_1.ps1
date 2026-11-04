$ErrorActionPreference='Stop'
$b=$PSScriptRoot
$p=Split-Path $b
$f=[IO.File]::ReadAllText("$p/SIGNATURE_FREEZE_DRAFT_v0_1.md").Replace("`r`n","`n")
$all=[regex]::Matches($f,'(?ms)^theorem (\w+)\b.*?(?=\n(?:theorem |```)|\z)')
$done=@{}
foreach($n in @('FVLTFareyContactV1','FVLTFordGeometryV1','FVLTFareyCertificatesV1')){
  foreach($m in [regex]::Matches([IO.File]::ReadAllText("$p/$n.lean"),'(?m)^theorem (\w+)')){
    $done[$m.Groups[1].Value]=$n
  }
}
$sections=@(
  @{id='R1';names='raw_det_one_coprime rawValue_num_den rawValue_canonical rawValue_unique coprime_den_not_adj adjacent_mediant rosette'},
  @{id='R2';names='ford_open_disjoint ford_boundary_disjoint ford_tangent_iff ford_real_axis kiss_unique two_squares kiss_integer_identity kiss_real_identity'},
  @{id='R3';names='unitFrac_injective_positive integerPath_adj unitFrac_adj unitFrac_tangent unitFrac_graph_iso unitFrac_graph_connected empty_graph_convention gap_det minimal_gap_mediant gap_mediant_unit_iff'},
  @{id='R4';names='phases_eq_unreduced phase_domain denominator_partner partner_congruence cross_denominator isolation_criterion endpoint_isolation complement_mem complement_adj complement_graph_auto isolated_complement_pairs'},
  @{id='R5';names='fixture4321_connected fixture4321_repair_edges fixture83_certificate fixture83_counts fixture83_isolated'}
)
$chunks=@{}
foreach($s in $sections){foreach($n in $s.names.Split(' ')){$chunks[$n]=$s.id}}
$headers=[ordered]@{}
$rows=@(foreach($m in $all){
  $n=$m.Groups[1].Value
  if($done.ContainsKey($n)){$status='AUDITED_PREDECESSOR_TARGET';$chunk=$null;$module=$done[$n]}
  elseif($chunks.ContainsKey($n)){$status='UNPROVED_QUEUED';$chunk=$chunks[$n];$module=$null}
  else{throw "Unassigned target $n"}
  $header=$m.Value.TrimEnd()
  if($chunk-eq'R1'){$headers[$n]=$header}
  [ordered]@{name=$n;status=$status;chunk=$chunk;accepted_module=$module;header=$header}
})
if($headers.Count-ne7-or$rows.Count-ne60){throw "Coverage count mismatch rows=$($rows.Count) R1=$($headers.Count)"}
$coverage=[ordered]@{schema='FF1-target-coverage/1';original_signature_sha256='a9382d4054a77d7a569e884b4f7e02b55f7c7e9aa0da2d3a6d1299075ea2b6c7';total=60;audited_predecessor_targets=19;remaining=41;bridge_links_separate=12;targets=$rows}
function WriteJson($name,$obj){[IO.File]::WriteAllText("$b/$name",($obj|ConvertTo-Json -Depth 9),[Text.UTF8Encoding]::new($false))}
WriteJson 'COVERAGE_v0_1.json' $coverage
$old=Get-Content "$p/F2_JOB_TEMPLATE_v0_1.json" -Raw|ConvertFrom-Json
$defs=[ordered]@{
  rawValue='def rawValue (a : ℤ) (q : ℕ) : ℚ := (a : ℚ) / (q : ℚ)'
  mediant="def mediant (x y : ℚ) : ℚ :=`n  rawValue (x.num + y.num) (x.den + y.den)"
  unitFrac='def unitFrac (a : ℕ) : ℚ := 1 / (a : ℚ)'
}
foreach($d in $defs.Values){if(-not$f.Contains($d)){throw 'Definition mismatch'}}
$template=[ordered]@{
  status='AWAITING_OPUS_DESIGN_ACCEPTANCE_AND_FRESH_INPUT_BINDING';phase='R1'
  module='FVLTFareyArithmeticCompletionV1';namespace='FVLT.FareyContactV1'
  root='/home/saphir/fvlt_formalization_20261028/ff1_v03_20261103/stage_a_completion_v1'
  allowed_modes=@('compile','replay');imports_allowed=@('FVLTFareyCertificatesV1','standard Mathlib')
  runner='RUN_R1_v0_1.py';runner_sha256=(Get-FileHash "$b/RUN_R1_v0_1.py" -Algorithm SHA256).Hash.ToLower()
  library=$old.library;library_expected=$old.library_expected
  lean_executable=$old.lean_executable;lean_executable_sha256=$old.lean_executable_sha256
  checker_sha256=$old.checker_sha256
  toolchain='Lean 4.35.0 commit eb6cafb7290e8bd5f2937522d8d804f58f02bafc'
  mathlib_commit='56a005855ea17e0b0958f73ec801ae140b0a1679'
  signature_sha256=$old.signature_sha256;frozen_definitions=$defs;frozen_headers=$headers
  caps=[ordered]@{active_wall_seconds=1800;per_call_wall_seconds=240;one_cpu=$true;nice=19;address_space_bytes=8589934592;lean_M_MiB=7680;stack_KiB=65536;process_limit=256;output_file_limit_bytes=67108864;serial_only=$true;automatic_retries=$false}
  proof_iteration='REQUEST bounded proof-body iteration; explicit manager acceptance required; preserve failed source/job/log/receipt'
  concrete_self_acceptance='REQUEST template-bound receipt checking with timestamp and snapshot; explicit manager acceptance required'
  fresh_input_gate='NO proof drafting or calls until complete fresh observations and bound template independently accepted'
  next_chunks='R2 R3 R4 R5 queued only; separate templates required'
  exclusions=@('Stage B','G1','Rule30','FF2 execution','FF3 execution','library sync','commits','viewer changes','kernel adoption','release')
}
$pred=[ordered]@{}
foreach($name in @('FVLTFareyContactV1.lean','FVLTFordGeometryV1.lean','FVLTFareyCertificatesV1.lean')){
  $pred[$name]=(Get-FileHash "$p/$name" -Algorithm SHA256).Hash.ToLower()
}
$pred['FVLTFareyContactV1.olean']='202d39c1c940eef0a6cd23ea422e251df2d9e111255bbc460cb14650c8f042e8'
$pred['FVLTFordGeometryV1.olean']='ea5dc4ce259c44b6e742ce950dcea3333d83d031511595ac951b68b0570cab54'
$pred['FVLTFareyCertificatesV1.olean']='99d3b3c3a44d0f4b4aa020e0e797dff255eddddb0459b7b1e4a3b7fad8ef651e'
$gates=[ordered]@{}
foreach($name in @('F1_AUDIT_AND_BRIDGE_DECISION_v0_1.md','F2_AUDIT_AND_BRIDGE_RUNNER_DECISION_v0_1.md','BRIDGE_AUDIT_v0_1.md')){
  $gates[$name]=(Get-FileHash "$p/$name" -Algorithm SHA256).Hash.ToLower()
}
$template['predecessor_pins']=$pred
$template['manager_pass_records']=$gates
WriteJson 'R1_JOB_TEMPLATE_v0_1.json' $template
$diff=git diff --no-index -- "$p/RUN_BRIDGE_v0_1.py" "$b/RUN_R1_v0_1.py"
[IO.File]::WriteAllText("$b/RUN_R1_vs_BRIDGE_v0_1.diff",($diff -join "`n"),[Text.UTF8Encoding]::new($false))
Write-Output "Coverage=$($rows.Count); R1=$($headers.Count); prospective runner not executed"
