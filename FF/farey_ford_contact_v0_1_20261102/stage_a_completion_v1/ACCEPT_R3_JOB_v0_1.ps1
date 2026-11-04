param([Parameter(Mandatory=$true)][string]$RunId,
  [ValidateSet('compile','replay')][string]$Mode='compile', [string]$ObjectHash='')
$ErrorActionPreference='Stop'
$b=$PSScriptRoot
$templateHash=(Get-FileHash "$b/R3_JOB_TEMPLATE_BOUND_v0_1.json" -Algorithm SHA256).Hash.ToLower()
if($templateHash-ne'32b0444d0945bbe5fc48a0131a1ad7f88f00e17900e43c838907dd764db4e4d8'){throw 'Template mismatch'}
$t=Get-Content "$b/R3_JOB_TEMPLATE_BOUND_v0_1.json" -Raw|ConvertFrom-Json
$sourceName=$t.module+'.lean'
$s=[IO.File]::ReadAllText("$b/$sourceName")
foreach($h in $t.frozen_headers.PSObject.Properties){if(-not$s.Contains($h.Value+' :=')){throw ('Header mismatch '+$h.Name)}}
foreach($d in $t.frozen_definitions.PSObject.Properties){if(-not$s.Contains($d.Value)){throw ('Definition mismatch '+$d.Name)}}
if($s-match'\bsorry\b|\badmit\b|\bnative_decide\b|(?m)^\s*(axiom|unsafe|partial|variable)\b|FVLTFordExactCoordinatesV1|FVLTFordRationalV1'){throw 'Forbidden source construct'}
$imports=@($s-split"`n"|Where-Object{$_-match'^import '})
foreach($i in $imports){if($i.Trim()-ne'import FVLTFordGeometryCompletionV1'-and$i-notmatch'^import Mathlib[.]'){throw 'Unexpected import'}}
$stamp=[DateTimeOffset]::UtcNow.ToString('o')
$pins=[ordered]@{}; $pins[$sourceName]=(Get-FileHash "$b/$sourceName" -Algorithm SHA256).Hash.ToLower()
$deps=[ordered]@{}
if($ObjectHash){$deps[$t.module+'.olean']=$ObjectHash}
if($Mode-eq'replay'-and-not$ObjectHash){throw 'Replay object pin missing'}
$job=[ordered]@{phase='R3';mode=$Mode;module=$t.module;run_id=$RunId;template_sha256=$templateHash;lean_executable_sha256=$t.lean_executable_sha256;source_sha256=$pins;dependency_olean_sha256=$deps;owner_accepted_utc=$stamp}
$jobName='JOB_'+$RunId+'.json'
if(Test-Path "$b/$jobName"){throw 'Preserve prior job'}
[IO.File]::WriteAllText("$b/$jobName",($job|ConvertTo-Json -Depth 7),[Text.UTF8Encoding]::new($false))
$hash=(Get-FileHash "$b/$jobName" -Algorithm SHA256).Hash.ToLower()
$review=Get-Content "$b/R3_REVIEW_ACCEPTANCE.json" -Raw|ConvertFrom-Json
if($review.final_template_review_reference-match'PENDING'){throw 'Posting not verified'}
$review.accepted_job_manifest_sha256=@($review.accepted_job_manifest_sha256)+@($hash)
$review.owner_acceptance_log=@($review.owner_acceptance_log)+@([ordered]@{job=$jobName;job_sha256=$hash;template_sha256=$templateHash;accepted_utc=$stamp;headers_verbatim=10;definitions_verbatim=2;source_sha256=$pins})
[IO.File]::WriteAllText("$b/R3_REVIEW_ACCEPTANCE.json",($review|ConvertTo-Json -Depth 10),[Text.UTF8Encoding]::new($false))
$snap="$b/snapshots/$RunId"
New-Item -ItemType Directory -Path $snap|Out-Null
foreach($n in @($sourceName,$jobName,'R3_REVIEW_ACCEPTANCE.json','RUN_R3_v0_1.py')){Copy-Item "$b/$n" "$snap/$n"}
$hash
