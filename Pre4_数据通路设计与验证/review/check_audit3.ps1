param([switch]$Prepare)
$ErrorActionPreference='Stop'
$path=Join-Path $PSScriptRoot 'audit3.log'
if($Prepare){
 if(Test-Path -LiteralPath $path){
  if(!(Test-Path -LiteralPath $path -PathType Leaf)){throw 'Audit log path is not a file'}
  $backup=Join-Path $PSScriptRoot ('previous_audit_runs\'+(Get-Date -Format 'yyyyMMdd_HHmmssffff'))
  New-Item -ItemType Directory -Path $backup -Force|Out-Null
  Move-Item -LiteralPath $path -Destination (Join-Path $backup 'audit3.log')
 }
}else{
 $raw=Get-Content -LiteralPath $path -Raw
 if($raw -match '(?im)Fatal:|FATAL_ERROR|ERROR:'){throw 'Audit log contains error'}
 if(!(@(Get-Content -LiteralPath $path) -ccontains 'AUDIT3_PASS directed=12 reset_restart=4 total=16 failures=0')){throw 'Exact audit PASS missing'}
 Write-Output 'AUDIT3_RECEIPT_ACCEPTED total=16 failures=0'
}
