param([Parameter(Mandatory=$true)][string]$RunId,
  [Parameter(Mandatory=$true)][ValidateSet('FVLTFordRationalV1','FVLTFordExactCoordinatesV1','FVLTFordRationalSmokeV1')][string]$Module,
  [ValidateSet('compile','replay','execute')][string]$Mode='compile',
  [string]$ProducerObject='', [string]$ProofObject='')
$ErrorActionPreference='Stop'
$ffParent=$PSScriptRoot
$ffRoot=Join-Path $ffParent 'computable_bridge_v1'
$ffTemplate=Get-Content -Raw -LiteralPath (Join-Path $ffParent 'BRIDGE_JOB_TEMPLATE_BOUND_v0_1.json')|ConvertFrom-Json
$ffTemplateHash=(Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $ffParent 'BRIDGE_JOB_TEMPLATE_BOUND_v0_1.json')).Hash.ToLower()
if($ffTemplateHash-ne'd3c6fbf9e903a8e81b59a3b20453f8604d8bdd3f49de68a3ae706c537a834bb1'){throw 'Template mismatch'}
$ffProof=[System.IO.File]::ReadAllText((Join-Path $ffRoot 'FVLTFordExactCoordinatesV1.lean'))
foreach($ffP in $ffTemplate.frozen_headers.PSObject.Properties){if(-not $ffProof.Contains($ffP.Value+' :=')){throw ('Frozen header mismatch '+$ffP.Name)}}
$ffProducer=[System.IO.File]::ReadAllText((Join-Path $ffRoot 'FVLTFordRationalV1.lean'))
if($ffProducer-cmatch'\bnoncomputable\b|\bReal\b|\bComplex\b|\bClassical\b'){throw 'Non-rational producer dependency'}
$ffSmoke=[System.IO.File]::ReadAllText((Join-Path $ffRoot 'FVLTFordRationalSmokeV1.lean'))
$ffImports=@($ffSmoke-split"`n"|Where-Object{$_-match'^import '})
if($ffImports.Count-ne1-or$ffImports[0].Trim()-ne'import FVLTFordRationalV1'){throw 'Smoke import violation'}
$ffPins=[ordered]@{}
foreach($ffName in @('FVLTFordRationalV1.lean','FVLTFordExactCoordinatesV1.lean','FVLTFordRationalSmokeV1.lean')){
  $ffBody=[System.IO.File]::ReadAllText((Join-Path $ffRoot $ffName))
  if($ffBody-match'FVLTFareyCertificatesV1|\bsorry\b|\badmit\b|\bnative_decide\b|(?m)^\s*(axiom|unsafe|partial)\b'){throw 'Forbidden source'}
  $ffPins[$ffName]=(Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $ffRoot $ffName)).Hash.ToLower()
}
$ffDeps=[ordered]@{}
if($ProducerObject){$ffDeps['FVLTFordRationalV1.olean']=$ProducerObject}
if($ProofObject){$ffDeps['FVLTFordExactCoordinatesV1.olean']=$ProofObject}
if($Mode-eq'replay'-and -not$ffDeps.Contains($Module+'.olean')){throw 'Replay target object missing'}
if(($Module-eq'FVLTFordRationalSmokeV1')-ne($Mode-eq'execute')){throw 'Smoke is execute-only'}
$ffNow=[DateTimeOffset]::UtcNow.ToString('o')
$ffJob=[ordered]@{phase='BRIDGE';mode=$Mode;module=$Module;run_id=$RunId;
  lean_executable_sha256=$ffTemplate.lean_executable_sha256;source_sha256=$ffPins;
  dependency_olean_sha256=$ffDeps;template_sha256=$ffTemplateHash;owner_accepted_utc=$ffNow;
  finite_evidence_only=($Mode-eq'execute')}
$ffJobName='JOB_'+$RunId+'.json'
if(Test-Path -LiteralPath (Join-Path $ffRoot $ffJobName)){throw 'Do not overwrite job'}
[System.IO.File]::WriteAllText((Join-Path $ffRoot $ffJobName),($ffJob|ConvertTo-Json -Depth 8),[System.Text.UTF8Encoding]::new($false))
$ffHash=(Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $ffRoot $ffJobName)).Hash.ToLower()
$ffReviewPath=Join-Path $ffRoot 'REVIEW_ACCEPTANCE.json'
$ffReview=Get-Content -Raw -LiteralPath $ffReviewPath|ConvertFrom-Json
$ffReview.accepted_job_manifest_sha256=@($ffReview.accepted_job_manifest_sha256)+@($ffHash)
$ffReview.owner_acceptance_log=@($ffReview.owner_acceptance_log)+@([ordered]@{job=$ffJobName;job_sha256=$ffHash;template_sha256=$ffTemplateHash;accepted_utc=$ffNow;headers='12verbatim';source_sha256=$ffPins})
[System.IO.File]::WriteAllText($ffReviewPath,($ffReview|ConvertTo-Json -Depth 10),[System.Text.UTF8Encoding]::new($false))
$ffSnap=Join-Path $ffRoot ('snapshots/'+$RunId)
New-Item -ItemType Directory -Path $ffSnap|Out-Null
foreach($ffName in @('FVLTFordRationalV1.lean','FVLTFordExactCoordinatesV1.lean','FVLTFordRationalSmokeV1.lean',$ffJobName,'REVIEW_ACCEPTANCE.json','RUN_BRIDGE_v0_1.py')){
  Copy-Item -LiteralPath (Join-Path $ffRoot $ffName) -Destination (Join-Path $ffSnap $ffName)
}
$ffHash
