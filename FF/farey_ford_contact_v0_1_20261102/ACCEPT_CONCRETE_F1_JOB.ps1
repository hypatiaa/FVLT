param(
  [Parameter(Mandatory=$true)][string]$RunId,
  [Parameter(Mandatory=$true)][ValidateSet('FVLTFareyContactV1','FVLTFordGeometryV1')][string]$Module,
  [ValidateSet('compile','replay')][string]$Mode='compile',
  [string]$ArithmeticObject='',
  [string]$TargetObject=''
)
$ErrorActionPreference='Stop'
$ffRoot=$PSScriptRoot
$ffTemplatePath=Join-Path $ffRoot 'F1_JOB_TEMPLATE_v0_1.json'
$ffTemplateHash=(Get-FileHash -LiteralPath $ffTemplatePath -Algorithm SHA256).Hash.ToLower()
if($ffTemplateHash -ne '45c7d8bf2046298f2f7d9e428e90ce173391050156e77f526c8da5cedd10c274'){throw 'Wrong template'}
$ffTemplate=Get-Content -Raw -LiteralPath $ffTemplatePath|ConvertFrom-Json
$ffReviewPath=Join-Path $ffRoot 'REVIEW_ACCEPTANCE.json'
$ffReview=Get-Content -Raw -LiteralPath $ffReviewPath|ConvertFrom-Json
$ffText=[System.IO.File]::ReadAllText((Join-Path $ffRoot 'FVLTFordGeometryV1.lean'))
foreach($ffHead in $ffTemplate.frozen_F1_headers){if(-not $ffText.Contains($ffHead+' := by')){throw 'Frozen header mismatch'}}
$ffPins=[ordered]@{}
foreach($ffName in @('FVLTFareyContactV1.lean','FVLTFordGeometryV1.lean')){
  $ffBody=[System.IO.File]::ReadAllText((Join-Path $ffRoot $ffName))
  if($ffBody -match '(?m)^\s*(axiom|unsafe|partial)\b|\bsorry\b|\badmit\b|\bnative_decide\b'){throw 'Forbidden target token'}
  foreach($ffLine in ($ffBody -split "`n"|Where-Object {$_ -match '^import '})){
    if($ffLine.Trim() -notmatch '^import (Mathlib(\.[A-Za-z0-9_.]+)?|FVLTFareyContactV1)$'){throw 'Unadmitted import'}
  }
  $ffPins[$ffName]=(Get-FileHash -LiteralPath (Join-Path $ffRoot $ffName) -Algorithm SHA256).Hash.ToLower()
}
$ffDeps=[ordered]@{}
if($ArithmeticObject){$ffDeps['FVLTFareyContactV1.olean']=$ArithmeticObject}
if($Mode -eq 'replay'){
  if(-not $TargetObject){throw 'Replay must pin target object'}
  $ffDeps[$Module+'.olean']=$TargetObject
}
$ffNow=[DateTimeOffset]::UtcNow.ToString('o')
$ffJob=[ordered]@{phase='F1';mode=$Mode;module=$Module;run_id=$RunId;
  lean_executable_sha256=$ffTemplate.lean_executable_sha256;source_sha256=$ffPins;
  dependency_olean_sha256=$ffDeps;template_sha256=$ffTemplateHash;owner_accepted_utc=$ffNow}
$ffJobName='JOB_'+$RunId+'.json'
$ffJobPath=Join-Path $ffRoot $ffJobName
if(Test-Path -LiteralPath $ffJobPath){throw 'Do not overwrite existing concrete job'}
[System.IO.File]::WriteAllText($ffJobPath,($ffJob|ConvertTo-Json -Depth 7),[System.Text.UTF8Encoding]::new($false))
$ffHash=(Get-FileHash -LiteralPath $ffJobPath -Algorithm SHA256).Hash.ToLower()
$ffReview.accepted_job_manifest_sha256=@($ffReview.accepted_job_manifest_sha256)+@($ffHash)
$ffReview.owner_acceptance_log=@($ffReview.owner_acceptance_log)+@([ordered]@{
  job=$ffJobName;job_sha256=$ffHash;template_sha256=$ffTemplateHash;accepted_utc=$ffNow;
  header_check='both F1 target headers verbatim; imports Mathlib/own arithmetic only';source_sha256=$ffPins})
[System.IO.File]::WriteAllText($ffReviewPath,($ffReview|ConvertTo-Json -Depth 10),[System.Text.UTF8Encoding]::new($false))
$ffSnapshot=Join-Path $ffRoot ('F1_snapshots/'+$RunId)
if(Test-Path -LiteralPath $ffSnapshot){throw 'Do not overwrite a snapshot'}
New-Item -ItemType Directory -Path $ffSnapshot|Out-Null
foreach($ffName in @('FVLTFareyContactV1.lean','FVLTFordGeometryV1.lean',$ffJobName,'REVIEW_ACCEPTANCE.json','RUN_FF1_v0_2.py')){
  Copy-Item -LiteralPath (Join-Path $ffRoot $ffName) -Destination (Join-Path $ffSnapshot $ffName)
}
$ffHash
