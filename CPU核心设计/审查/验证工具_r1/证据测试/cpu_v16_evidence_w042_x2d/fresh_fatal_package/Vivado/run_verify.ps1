param([string]$Python='',[string]$VivadoBin='',[string]$ToolConfig='')
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'tool_config.ps1')
$resolvedCpuTools=Resolve-CpuTools -Python $Python -VivadoBin $VivadoBin -ToolConfig $ToolConfig
$Python=$resolvedCpuTools.python;$VivadoBin=$resolvedCpuTools.vivado_bin
$packageRoot=(Resolve-Path -LiteralPath (Split-Path -Parent $PSScriptRoot)).Path
$attemptStatusPath=Join-Path $packageRoot '最近运行.json'
$attemptId=[guid]::NewGuid().ToString('D')
$attemptStatus=[ordered]@{status='running';result_kind='fresh_execution';attempt_id=$attemptId;spec_version='1.6';isa_version='1.5';verification_revision='1.6-vtools-r1';started_at_utc=[DateTime]::UtcNow.ToString('o');note='验证结果.json records the previous successful execution until this attempt is fully verified.'}
$runtimeDirectory=$null
function Save-AttemptEvidence([string]$runtimeAudit,[string]$destinationAudit) {
 if(Test-Path -LiteralPath $destinationAudit){throw 'Attempt evidence must not be overwritten.'}
 New-Item -ItemType Directory -Path $destinationAudit | Out-Null
 Get-ChildItem -LiteralPath $runtimeAudit -File | ForEach-Object {Copy-Item -LiteralPath $_.FullName -Destination $destinationAudit}
 foreach($folderAudit in @('rtl','tb','programs','tool_commands')){
  $sourceAudit=Join-Path $runtimeAudit $folderAudit
  if(Test-Path -LiteralPath $sourceAudit){Copy-Item -LiteralPath $sourceAudit -Destination (Join-Path $destinationAudit $folderAudit) -Recurse}
 }
}
try {
 $attemptStatus | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $attemptStatusPath -Encoding utf8
 foreach($toolAudit in @('xvlog.bat','xelab.bat','xsim.bat')){if(-not(Test-Path -LiteralPath (Join-Path $VivadoBin $toolAudit) -PathType Leaf)){throw "Required tool missing: $toolAudit"}}
 if(-not(Test-Path -LiteralPath $Python -PathType Leaf)){throw 'Bundled Python missing; supply -Python.'}
 $runtimeDirectory=Join-Path ([System.IO.Path]::GetTempPath()) ('cpu_v16_'+$attemptId.Replace('-',''))
 New-Item -ItemType Directory -Path $runtimeDirectory | Out-Null
 foreach($folderAudit in @('rtl','tb')){Copy-Item -LiteralPath (Join-Path $PSScriptRoot $folderAudit) -Destination (Join-Path $runtimeDirectory $folderAudit) -Recurse}
 foreach($driverAudit in @('run_all.cmd','run_all.tcl','sim.tcl','trace.tcl','desktop_launch.py','verify_results.py','run_verify.ps1','execute_regression.py')){Copy-Item -LiteralPath (Join-Path $PSScriptRoot $driverAudit) -Destination $runtimeDirectory}
 Copy-Item -LiteralPath (Join-Path $packageRoot '程序镜像') -Destination (Join-Path $runtimeDirectory 'programs') -Recurse
 $attemptStatus['runtime']=$runtimeDirectory
 $attemptStatus | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $attemptStatusPath -Encoding utf8
 Write-Output ('V16_FRESH_RUNTIME='+$runtimeDirectory)
 # Actual runner owns 19 native calls and content validation in one process.
 # Standalone verify_results.py CLI is historical-only and cannot publish here.
 & $Python (Join-Path $runtimeDirectory 'execute_regression.py') --run $runtimeDirectory --package $packageRoot --vivado-bin $VivadoBin --attempt-id $attemptId
 if($LASTEXITCODE -ne 0){throw 'Actual native execution or bound evidence validation failed; no new execution PASS published.'}
 $receiptAudit=Get-Content -LiteralPath (Join-Path $runtimeDirectory 'verification_results.json') -Raw | ConvertFrom-Json
 if($receiptAudit.status -ne 'PASS' -or $receiptAudit.result_kind -ne 'fresh_execution' -or $receiptAudit.attempt_id -ne $attemptId -or -not $receiptAudit.new_xsim_execution){throw 'Fresh execution receipt does not match this attempt.'}
 $archiveAudit=Join-Path $packageRoot ('验证记录\'+(Split-Path -Leaf $runtimeDirectory))
 New-Item -ItemType Directory -Path (Split-Path -Parent $archiveAudit) -Force | Out-Null
 Save-AttemptEvidence $runtimeDirectory $archiveAudit
 Copy-Item -LiteralPath (Join-Path $archiveAudit 'verification_results.json') -Destination (Join-Path $packageRoot '验证结果.json')
 $attemptStatus['status']='PASS';$attemptStatus['completed_at_utc']=[DateTime]::UtcNow.ToString('o');$attemptStatus['archived_run']=$archiveAudit
 $attemptStatus['note']='New native execution passed; 19 tool records, pre-run inputs, raw artifacts and validation are bound to this attempt.'
 $attemptStatus | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $attemptStatusPath -Encoding utf8
 Write-Output ('V16_VERIFIED_RESULTS='+$archiveAudit)
} catch {
 $attemptStatus['status']='failed';$attemptStatus['completed_at_utc']=[DateTime]::UtcNow.ToString('o');$attemptStatus['error']=$_.Exception.Message
 $attemptStatus['note']='No new successful execution receipt published; prior 验证结果.json remains historical.'
 if($null -ne $runtimeDirectory -and (Test-Path -LiteralPath $runtimeDirectory)){
  $failedArchiveAudit=Join-Path $packageRoot ('验证记录\'+(Split-Path -Leaf $runtimeDirectory))
  if(-not(Test-Path -LiteralPath $failedArchiveAudit)){New-Item -ItemType Directory -Path (Split-Path -Parent $failedArchiveAudit) -Force | Out-Null;Save-AttemptEvidence $runtimeDirectory $failedArchiveAudit}
  $attemptStatus['archived_run']=$failedArchiveAudit
 }
 $attemptStatus | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $attemptStatusPath -Encoding utf8
 throw
}
