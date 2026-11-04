param([Parameter(Mandatory=$true)][string]$RunId,
  [ValidateSet('compile','replay')][string]$Mode='compile', [string]$TargetObject='')
$ErrorActionPreference='Stop'
$ffRoot=$PSScriptRoot
$ffTemplate=Get-Content -Raw -LiteralPath (Join-Path $ffRoot 'F2_JOB_TEMPLATE_v0_1.json')|ConvertFrom-Json
$ffTemplateHash=(Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $ffRoot 'F2_JOB_TEMPLATE_v0_1.json')).Hash.ToLower()
if($ffTemplateHash-ne'd1bffb5df9c8a3e04daf71a6d722cf518f4239e4cad35874f3540886ca2db461'){throw 'Wrong template'}
$ffSourceName='FVLTFareyCertificatesV1.lean'
$ffText=[System.IO.File]::ReadAllText((Join-Path $ffRoot $ffSourceName))
foreach($ffP in $ffTemplate.frozen_headers.PSObject.Properties){if(-not $ffText.Contains($ffP.Value+' :=')){throw ('Changed header '+$ffP.Name)}}
if($ffText-match'\bsorry\b|\badmit\b|\bnative_decide\b|(?m)^\s*(axiom|unsafe|partial)\b'){throw 'Forbidden source token'}
foreach($ffLine in ($ffText-split"`n"|Where-Object{$_-match'^import '})){
  if($ffLine.Trim()-notmatch'^import (Mathlib\.[A-Za-z0-9_.]+|FVLTFareyContactV1)$'){throw 'Unadmitted import'}
}
$ffPins=[ordered]@{$ffSourceName=(Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $ffRoot $ffSourceName)).Hash.ToLower();'FVLTFareyContactV1.lean'='2760392f984bd1375169920a702ae53c13115ddfb36d71bae36b3855950d1e4b'}
$ffDeps=[ordered]@{'FVLTFareyContactV1.olean'='202d39c1c940eef0a6cd23ea422e251df2d9e111255bbc460cb14650c8f042e8'}
if($Mode-eq'replay'){if(-not$TargetObject){throw 'Target object required'};$ffDeps['FVLTFareyCertificatesV1.olean']=$TargetObject}
$ffNow=[DateTimeOffset]::UtcNow.ToString('o')
$ffJob=[ordered]@{phase='F2';mode=$Mode;module='FVLTFareyCertificatesV1';run_id=$RunId;lean_executable_sha256=$ffTemplate.lean_executable_sha256;source_sha256=$ffPins;dependency_olean_sha256=$ffDeps;template_sha256=$ffTemplateHash;owner_accepted_utc=$ffNow;annotation_erratum='03c54bbfa34cb9854f7e10179f50a5e2fa2fdef3332e6886ec2a9613a92f9299'}
$ffJobName='JOB_'+$RunId+'.json'
if(Test-Path -LiteralPath (Join-Path $ffRoot $ffJobName)){throw 'Do not overwrite job'}
[System.IO.File]::WriteAllText((Join-Path $ffRoot $ffJobName),($ffJob|ConvertTo-Json -Depth 8),[System.Text.UTF8Encoding]::new($false))
$ffHash=(Get-FileHash -Algorithm SHA256 -LiteralPath (Join-Path $ffRoot $ffJobName)).Hash.ToLower()
$ffReviewPath=Join-Path $ffRoot 'REVIEW_ACCEPTANCE.json'
$ffReview=Get-Content -Raw -LiteralPath $ffReviewPath|ConvertFrom-Json
$ffReview.accepted_job_manifest_sha256=@($ffReview.accepted_job_manifest_sha256)+@($ffHash)
$ffReview.owner_acceptance_log=@($ffReview.owner_acceptance_log)+@([ordered]@{job=$ffJobName;job_sha256=$ffHash;template_sha256=$ffTemplateHash;timestamp=$ffNow;source_sha256=$ffPins;headers='16verbatim;S1annotationonly'})
[System.IO.File]::WriteAllText($ffReviewPath,($ffReview|ConvertTo-Json -Depth 10),[System.Text.UTF8Encoding]::new($false))
$ffSnap=Join-Path $ffRoot ('F2_snapshots/'+$RunId)
New-Item -ItemType Directory -Path $ffSnap|Out-Null
foreach($ffName in @($ffSourceName,$ffJobName,'REVIEW_ACCEPTANCE.json','RUN_FF2_v0_1.py')){Copy-Item -LiteralPath (Join-Path $ffRoot $ffName) -Destination (Join-Path $ffSnap $ffName)}
$ffHash
