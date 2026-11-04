$ErrorActionPreference='Stop'
$b=$PSScriptRoot
$p=Split-Path $b
$a="$p/stage_a_completion_v1"
$q="$p/computable_bridge_v1"
$specs=@(
  @{module='FVLTFareyContactV1';origin='FVLTFareyContactV1.lean';ns='FVLT.FareyContactV1';count=2;object='202d39c1c940eef0a6cd23ea422e251df2d9e111255bbc460cb14650c8f042e8'},
  @{module='FVLTFordGeometryV1';origin='FVLTFordGeometryV1.lean';ns='FVLT.FordGeometryV1';count=20;object='ea5dc4ce259c44b6e742ce950dcea3333d83d031511595ac951b68b0570cab54'},
  @{module='FVLTFareyCertificatesV1';origin='FVLTFareyCertificatesV1.lean';ns='FVLT.FareyContactV1';count=61;object='99d3b3c3a44d0f4b4aa020e0e797dff255eddddb0459b7b1e4a3b7fad8ef651e'},
  @{module='FVLTFareyArithmeticCompletionV1';origin='stage_a_completion_v1/FVLTFareyArithmeticCompletionV1.lean';ns='FVLT.FareyContactV1';count=29;object='ab3351ff996fe0b676a322907cb445fed4dc32eed7ddbc04db8d9a17559fea56'},
  @{module='FVLTFordGeometryCompletionV1';origin='stage_a_completion_v1/FVLTFordGeometryCompletionV1.lean';ns='FVLT.FordGeometryV1';count=21;object='ce38bf44fe8556c09588461b69782b6752a2e1bd6fe8361f496981ef252ced9b'},
  @{module='FVLTUnitFractionSpineV1';origin='stage_a_completion_v1/FVLTUnitFractionSpineV1.lean';ns='FVLT.FareyContactV1';count=33;object='8d5f4cae1a6693a1e873ecc2ad73e81a50d380254eb289ba304d9ddb67508870'},
  @{module='FVLTPhasePartnersV1';origin='stage_a_completion_v1/FVLTPhasePartnersV1.lean';ns='FVLT.FareyContactV1';count=40;object='875d7726a34ca13d247b53d71525087141481441fbef5b0928586712b84f77a3'},
  @{module='FVLTFareyFixturesCompletionV1';origin='stage_a_completion_v1/FVLTFareyFixturesCompletionV1.lean';ns='FVLT.FareyContactV1';count=18;object='237223a3837de4529d87d08264eeae3eead7bec8d28775b73587e262b7aca9c5'},
  @{module='FVLTFordRationalV1';origin='computable_bridge_v1/FVLTFordRationalV1.lean';ns='FVLT.FordExactCoordinatesV1';count=11;object='6691b599440e4413ed4dd2aed348cbc12d419177a5465044c22515a14fd446f6'},
  @{module='FVLTFordExactCoordinatesV1';origin='computable_bridge_v1/FVLTFordExactCoordinatesV1.lean';ns='FVLT.FordExactCoordinatesV1';count=19;object='ff7193e200351820627eba32fe846892e4ff2c0fdea43b1b3109d62c7328a3e2'}
)
$expectedSource=@{
  FVLTFareyContactV1='2760392f984bd1375169920a702ae53c13115ddfb36d71bae36b3855950d1e4b'
  FVLTFordGeometryV1='0b380fd6cf1319317edbc9bbd5c56ed6f913bfbb7ac45104877b0f754b7e6db8'
  FVLTFareyCertificatesV1='4119bffe98e36c703dfef30a1ff48b956ee90a623b12dbc931a1d6695a91121e'
  FVLTFareyArithmeticCompletionV1='01abe886ef9e92dd2cf8d4289a0093733ecb519facefc6345212e758fc4da2ac'
  FVLTFordGeometryCompletionV1='c3251f10239e178c243a7793f35e60fddda64637342adfc7c52fdd95dd5b18a1'
  FVLTUnitFractionSpineV1='21b2efd2defd0d42f7a1238c1ee417926a0033f41df700d13c937feee6156bf1'
  FVLTPhasePartnersV1='81b55661b4e1c6c8e4a8a837fdd62bf1ce61b7358499334d818756fa173e80ac'
  FVLTFareyFixturesCompletionV1='85b05d8021e6f44979c0f98533ade819f1b88363adfce331cdbe9f26e5ba0a2d'
  FVLTFordRationalV1='fdccda2c22abe186acc8530f4c7f28bcbce7c8498407061dd2f5ba693c606559'
  FVLTFordExactCoordinatesV1='23f776a40d9daec1cd7ec4f27c9c64917be6430595416756c6d7fe7d88dc7f3d'
}
New-Item -ItemType Directory -Path "$b/src" -Force|Out-Null
$pins=[ordered]@{};$origins=[ordered]@{};$counts=[ordered]@{}
foreach($s in $specs){
  Copy-Item -LiteralPath "$p/$($s.origin)" -Destination "$b/src/$($s.module).lean"
  $hash=(Get-FileHash "$p/$($s.origin)" -Algorithm SHA256).Hash.ToLower()
  if($hash-ne$expectedSource[$s.module]){throw "Audited source pin mismatch $($s.module)"}
  $pins[$s.module+'.lean']=$hash
  $origins[$s.origin]=$hash
  $origins[$s.origin.Replace('.lean','.olean')]=$s.object
  $counts[$s.module]=$s.count
}
Copy-Item "$p/IndependentFVLTReplay435.lean" "$b/IndependentFVLTReplay435.lean"
$references=@(
  @{source=(Join-Path (Split-Path (Split-Path $p)) '.agent/skills/fvlt/kernel_v3_3_1.md');file='REFERENCE_kernel_v3_3_1.md';sha='e49533088843e2cd0a1c531c4d8ba113ea30113e8135a15c17c040bdfca3e0e0'},
  @{source="$p/WORK_ORDER_v0_3.md";file='REFERENCE_WORK_ORDER_v0_3.md';sha='43560b88ab50dc77d8e222562f83bad68c8ba17d12a073523a99597a484d6fdd'},
  @{source="$p/SIGNATURE_FREEZE_DRAFT_v0_1.md";file='REFERENCE_SIGNATURE_FREEZE_v0_1.md';sha='a9382d4054a77d7a569e884b4f7e02b55f7c7e9aa0da2d3a6d1299075ea2b6c7'},
  @{source="$p/ERRATUM_v0_3_E1.md";file='REFERENCE_ERRATUM_E1.md';sha='b7240e8fe36a239d66e19986308b2a2d59aa5212d1c4b5af74dc0683768f4243'},
  @{source="$p/SIGNATURE_FREEZE_ERRATUM_S1.md";file='REFERENCE_ERRATUM_S1.md';sha='03c54bbfa34cb9854f7e10179f50a5e2fa2fdef3332e6886ec2a9613a92f9299'}
)
foreach($ref in $references){
  if((Get-FileHash $ref.source -Algorithm SHA256).Hash.ToLower()-ne$ref.sha){throw 'Governing reference drift'}
  Copy-Item -LiteralPath $ref.source -Destination "$b/$($ref.file)"
}
$coverage=Get-Content "$a/COVERAGE_v0_1.json" -Raw|ConvertFrom-Json
$chunkModules=@{R1='FVLTFareyArithmeticCompletionV1';R2='FVLTFordGeometryCompletionV1';R3='FVLTUnitFractionSpineV1';R4='FVLTPhasePartnersV1';R5='FVLTFareyFixturesCompletionV1'}
$classic=@('raw_det_one_coprime','rawValue_num_den','rawValue_canonical','rawValue_unique','coprime_den_not_adj','adjacent_mediant','radius_pos','ford_distance_identity','ford_open_disjoint','ford_boundary_disjoint','ford_tangent_iff','ford_real_axis','kiss_membership','kiss_unique','two_squares','kiss_integer_identity','kiss_real_identity','unitFrac_injective_positive')
$support=@('fareyAdj_symm','fareyAdj_irrefl','fareyGraph_adj','integerPath_adj','empty_graph_convention','spanning_tree_connected','certificate_component_bijection','certificate_component_count','certificate_isolation','contactCount_eq_edge_count','rational_certificate_count')
function SourceRole($name){
  if($name-in$classic){return @('Classical background/helper extension; no directly named native theorem claimed','II.5b supporting background, line 716; exact source role requires independent review')}
  if($name-in$support){return @('Definitional/implementation helper; no new kernel standing','Original work-order/signature-freeze support obligation, not a directly named kernel claim')}
  if($name-eq'rosette'){return @('Unconditional scoped arithmetic specialization','II.5b, lines 719-724; geometry remains separately named')}
  if($name-in@('unitFrac_adj','unitFrac_tangent','unitFrac_graph_iso','unitFrac_graph_connected')){return @('Unconditional scoped unit-fraction result','II.5f (i), line 895; no anchoring or label action')}
  if($name-in@('gap_det','minimal_gap_mediant','gap_mediant_unit_iff')){return @('Unconditional scoped gap result; check harmless generalizations explicitly','II.5f (iii), line 899; no complete insertion repair')}
  if($name-in@('phases_eq_unreduced','phase_domain')){return @('Unconditional phase-domain/set statement','Setting / II.5g, lines 908-963')}
  if($name-in@('denominator_partner','partner_congruence')){return @('Unconditional exact partner/range criterion','II.5i, beginning line 1013')}
  if($name-eq'cross_denominator'){return @('Unconditional on interior domain only','II.5i.1, beginning line 1050')}
  if($name-eq'isolation_criterion'){return @('Unconditional isolation criterion with guards','II.5j, beginning line 1061')}
  if($name-in@('endpoint_isolation','complement_mem','complement_adj','complement_graph_auto','isolated_complement_pairs')){return @('Unconditional scoped endpoint/complement statement','II.5j.1, beginning line 1075')}
  if($name-match'^fixture(421|4321)_'){return @('Exact worked finite instance','Worked fixture after II.5j.1, beginning line 1105')}
  if($name-match'^fixture(92|83)_'){return @('Unconditional finite witness only','II.5k, beginning line 1158')}
  throw "Unmapped source role $name"
}
$rows=@();$id=0
foreach($row in $coverage.targets){
  $id++
  $module=if($row.accepted_module){$row.accepted_module}else{$chunkModules[$row.chunk]}
  $ns=if($module-eq'FVLTFordGeometryV1'-or$module-eq'FVLTFordGeometryCompletionV1'-or$row.name-eq'unitFrac_tangent'){'FVLT.FordGeometryV1'}else{'FVLT.FareyContactV1'}
  $source=[IO.File]::ReadAllText("$b/src/$module.lean")
  $index=$source.IndexOf($row.header+' :=')
  if($index-lt0){throw "Header missing $($row.name)"}
  $line=($source.Substring(0,$index)-split"`n").Count
  $role=SourceRole $row.name
  $rows+=@([ordered]@{id=('A{0:d2}'-f$id);lean_name=($ns+'.'+$row.name);module=$module;source_file=('src/'+$module+'.lean');source_sha256=$pins[$module+'.lean'];source_line=$line;frozen_header=$row.header;kernel_locator=$role[1];standing_proposal=$role[0];reviewer=$null;fidelity_verdict='PENDING';scope_difference_note=$null;mathematical_review='PENDING';signoff_artifact=$null;signoff_sha256=$null})
}
if($rows.Count-ne60-or@($rows.lean_name|Sort-Object -Unique).Count-ne60){throw 'Original target coverage mismatch'}
$bridge=Get-Content "$p/BRIDGE_JOB_TEMPLATE_BOUND_v0_1.json" -Raw|ConvertFrom-Json
$extra=@();$id=0
foreach($h in $bridge.frozen_headers.PSObject.Properties){
  $id++;$source=[IO.File]::ReadAllText("$b/src/FVLTFordExactCoordinatesV1.lean");$index=$source.IndexOf($h.Value+' :=');if($index-lt0){throw 'Bridge header missing'}
  $extra+=@([ordered]@{id=('B{0:d2}'-f$id);lean_name=('FVLT.FordExactCoordinatesV1.'+$h.Name);module='FVLTFordExactCoordinatesV1';source_file='src/FVLTFordExactCoordinatesV1.lean';source_sha256=$pins['FVLTFordExactCoordinatesV1.lean'];source_line=($source.Substring(0,$index)-split"`n").Count;frozen_header=$h.Value;standing_proposal='Additional computable-coordinate bridge, not one of original sixty';reviewer=$null;fidelity_verdict='PENDING';signoff_artifact=$null;signoff_sha256=$null})
}
if($extra.Count-ne12){throw 'Bridge coverage mismatch'}
function WriteJson($name,$obj){[IO.File]::WriteAllText("$b/$name",($obj|ConvertTo-Json -Depth 12),[Text.UTF8Encoding]::new($false))}
WriteJson 'FIDELITY_MATRIX_v0_1.json' ([ordered]@{status='PRODUCER_MAPPING_ONLY_ALL_SIGNOFFS_PENDING';kernel_file='.agent/skills/fvlt/kernel_v3_3_1.md';kernel_sha256='e49533088843e2cd0a1c531c4d8ba113ea30113e8135a15c17c040bdfca3e0e0';signature_sha256='a9382d4054a77d7a569e884b4f7e02b55f7c7e9aa0da2d3a6d1299075ea2b6c7';original_targets=$rows;additional_bridge_links=$extra})
$driver=@('import FVLTFareyFixturesCompletionV1','import FVLTFordExactCoordinatesV1','','/-! Integration entry point: name/type and axiom inventory only; no new theorem. -/','')
foreach($r in @($rows)+@($extra)){$driver+=('#check @'+$r.lean_name);$driver+=('#print axioms '+$r.lean_name)}
[IO.File]::WriteAllText("$b/src/FVLTStageAIntegrationV1.lean",($driver -join "`n")+"`n",[Text.UTF8Encoding]::new($false))
$pins['FVLTStageAIntegrationV1.lean']=(Get-FileHash "$b/src/FVLTStageAIntegrationV1.lean" -Algorithm SHA256).Hash.ToLower()
$aux=@()
foreach($s in $specs){
  $text=[IO.File]::ReadAllText("$b/src/$($s.module).lean")
  foreach($m in [regex]::Matches($text,'(?m)^(?<private>private )?(?<noncomputable>noncomputable )?(?<kind>theorem|def|abbrev|instance)\b(?<rest>[^\n]*)')){
    $rest=$m.Groups['rest'].Value.Trim();$name=if($rest-match'^(\w+)'){$Matches[1]}else{$null}
    $full=$s.ns+'.'+$name
    if($m.Groups['kind'].Value-eq'theorem'-and-not$m.Groups['private'].Success-and$full-in(@($rows.lean_name)+@($extra.lean_name))){continue}
    if($name-eq'unitFrac_tangent'){continue}
    $aux+=@([ordered]@{module=$s.module;source_line=($text.Substring(0,$m.Index)-split"`n").Count;kind=$m.Groups['kind'].Value;private=$m.Groups['private'].Success;noncomputable_marker=$m.Groups['noncomputable'].Success;source_declaration_line=$m.Value;integration_grants_new_kernel_standing=$false;review_status='PENDING_SUPPORT_CLASSIFICATION'})
  }
}
if(@($aux|Where-Object{$_.kind-eq'theorem'-and-not$_.private}).Count-ne0){throw 'Unexpected public theorem outside reviewed targets'}
WriteJson 'SUPPORT_DECLARATIONS_v0_1.json' ([ordered]@{status='SOURCE_INVENTORY_NOT_INDEPENDENT_REVIEW';declarations=$aux})
$old=Get-Content "$a/R5_JOB_TEMPLATE_v0_1.json" -Raw|ConvertFrom-Json
$gates=$old.manager_pass_records
$gates|Add-Member -NotePropertyName 'R5_AUDIT_v0_1.md' -NotePropertyValue '832e76cca510f26261313691754d906a198b652f57b0adb5f36a746ba24f0b4e'
$template=[ordered]@{status='AWAITING_EXPLICIT_INTEGRATION_TEMPLATE_ACCEPTANCE_NO_EXECUTION';phase='INTEGRATION';root='/home/saphir/fvlt_formalization_20261028/ff1_v03_20261103/stage_a_integration_v1';runner='RUN_INTEGRATION_v0_1.py';runner_sha256=(Get-FileHash "$b/RUN_INTEGRATION_v0_1.py" -Algorithm SHA256).Hash.ToLower();modules_in_order=@($specs.module);entrypoint='FVLTStageAIntegrationV1';entrypoint_role='Compile-only 72-name/type/axiom inventory; zero new theorem declarations; never an empty strict-replay PASS';original_targets=60;additional_bridge_links=12;staged_source_sha256=$pins;protected_origin_sha256=$origins;historical_objects='Protected and excluded from LEAN_PATH; fresh integration objects are separately recorded';expected_replay_counts=$counts;expected_total_replayed_declarations=254;recorded_manager_gates=$gates;R5_manager_gate=[ordered]@{status='RECORDED_PASS';file='R5_AUDIT_v0_1.md';sha256='832e76cca510f26261313691754d906a198b652f57b0adb5f36a746ba24f0b4e'};library=$old.library;library_expected=$old.library_expected;lean_executable=$old.lean_executable;lean_executable_sha256=$old.lean_executable_sha256;mathlib_commit=$old.mathlib_commit;checker_sha256=$old.checker_sha256;caps=$old.caps;fresh_binding='Required after integration-template acceptance; any mismatch returns for review';acceptance_on_posting='NOT ASSUMED: manager must explicitly grant or accept final bound receipt';source_policy='Exact pinned source copies only; no proof/body/signature repairs permitted by integration job';concrete_jobs='Requested reviewed-template-bound self-acceptance; fixed run IDs, compile/replay each module serially, then entrypoint compile';kernel_adoption='None; discrepancies to independent review and Idea Catalog candidates only';sync='Separately authorized by Robin, conditional on integrated build and independent fidelity PASS; own additive versioned plan still required';fidelity='Independent signed verdict for each of 60 original rows; twelve bridge rows separate'}
$inputs=[ordered]@{}
foreach($name in @('FIDELITY_MATRIX_v0_1.json','SUPPORT_DECLARATIONS_v0_1.json','REFERENCE_kernel_v3_3_1.md','REFERENCE_WORK_ORDER_v0_3.md','REFERENCE_SIGNATURE_FREEZE_v0_1.md','REFERENCE_ERRATUM_E1.md','REFERENCE_ERRATUM_S1.md','INTEGRATION_AND_FIDELITY_PLAN_v0_1.md','CONDITIONAL_LIBRARY_SYNC_AUTHORIZATION_20261103.md')){
  $inputs[$name]=(Get-FileHash "$b/$name" -Algorithm SHA256).Hash.ToLower()
}
$template['review_input_sha256']=$inputs
$template['toolchain']=$old.toolchain
WriteJson 'INTEGRATION_JOB_TEMPLATE_v0_1.json' $template
$md=@('# FF-1 final statement-review index','','Producer mapping only. All independent sign-offs remain pending. Full frozen headers and source hashes are in FIDELITY_MATRIX_v0_1.json.','','| Row | Lean name | Source | Kernel/source role | Independent sign-off |','| --- | --- | --- | --- | --- |')
foreach($r in $rows){$md+=('| '+$r.id+' | '+$r.lean_name+' | '+$r.source_file+':'+$r.source_line+' | '+$r.kernel_locator+' | Pending |')}
$md+=@('','The twelve B rows in the JSON are additional bridge links, excluded from the original sixty. Support declarations are listed separately and receive no new standing from integration. The review must read every statement and its explicit hypotheses against the pinned kernel, rather than sign off from compilation or this proposed routing alone.')
[IO.File]::WriteAllText("$b/FIDELITY_INDEX_v0_1.md",($md -join "`n")+"`n",[Text.UTF8Encoding]::new($false))
Write-Output "Pinned 10 source modules and one entry point; 60 original rows, 12 additional bridge rows; no Lean invoked."
