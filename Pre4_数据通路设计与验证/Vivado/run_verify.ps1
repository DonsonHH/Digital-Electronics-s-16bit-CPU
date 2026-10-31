param(
  [string]$Python='C:\Users\Donson\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe',
  [string]$VivadoBin='C:\AMDDesignTools\2025.2\Vivado\bin',
  [switch]$SkipStress
)
$ErrorActionPreference='Stop'
$savedVivadoBin=$env:PRE4_VIVADO_BIN
Push-Location $PSScriptRoot
try {
  if(!(Test-Path -LiteralPath $Python -PathType Leaf)){throw 'Python executable missing; pass -Python'}
  foreach($tool in @('xvlog.bat','xelab.bat','xsim.bat')){
    if(!(Test-Path -LiteralPath (Join-Path $VivadoBin $tool) -PathType Leaf)){throw ('Vivado executable missing: '+$tool)}
  }
  $env:PRE4_VIVADO_BIN=$VivadoBin
  # Preserve previous evidence, then require newly produced results. This
  # prevents an old PASS log/JSON from making an incomplete run appear valid.
  $runArchive=Join-Path $PSScriptRoot ('previous_runs\'+(Get-Date -Format 'yyyyMMdd_HHmmssffff'))
  foreach($artifact in @('datapath.log','units.log','case_results.csv','baseline_trace.csv','case_timings.csv','unit_results.json','datapath.vcd','datapath.wdb','stress.log','stress_results.json')){
    $existing=Join-Path $PSScriptRoot $artifact
    if(Test-Path -LiteralPath $existing -PathType Leaf){
      New-Item -ItemType Directory -Path $runArchive -Force | Out-Null
      Move-Item -LiteralPath $existing -Destination (Join-Path $runArchive $artifact)
    }
  }
  # desktop_launch.py resolves the process-DLL context of a packaged caller.
  # The vendor environment and installation are not modified.
  & $Python desktop_launch.py $env:ComSpec /d /c run_datapath.cmd
  if($LASTEXITCODE -ne 0){throw 'Datapath launch/compile failed'}
  $dp=Get-Content -LiteralPath datapath.log -Raw
  if($dp -match '(?im)Fatal:|FATAL_ERROR|ERROR:'){throw 'Datapath log has an error'}
  if($dp -notmatch '(?m)^DATAPATH_PASS cases=128 reset_probes=16 retired=3380 failures=0 legal_opcode_coverage=14/14\r?$'){throw 'Required datapath PASS receipt missing'}
  & $Python desktop_launch.py $env:ComSpec /d /c run_units.cmd
  if($LASTEXITCODE -ne 0){throw 'Unit launch failed'}
  $ul=Get-Content -LiteralPath units.log -Raw
  if($ul -match '(?im)Fatal:|FATAL_ERROR|ERROR:'){throw 'Unit log has an error'}
  if($ul -notmatch '(?m)^UNITS_PASS CLA4=512 CLA16=564300 ADD_SUB=564300 ALU=2257200 DECODE=65536 IMM=512 FLAGS=512 RF=262161 PC=65539 TARGET=3584\r?$'){throw 'Required unit PASS receipt missing'}
  $cases=Import-Csv -LiteralPath case_results.csv
  if($cases.Count -ne 128){throw 'Case result row count mismatch'}
  if(@($cases.case | Select-Object -Unique).Count -ne 128){throw 'Duplicate case result names'}
  if(@($cases | Where-Object {$_.witness_seen -ne $_.witness_required}).Count){throw 'Required timing witness missing'}
  if(($cases | Measure-Object -Property retired -Sum).Sum -ne 3380){throw 'Retirement total mismatch'}
  if(@($cases | Where-Object {([int]$_.halted+[int]$_.fault) -ne 1}).Count){throw 'Case final stop mismatch'}
  $baseline=@($cases | Where-Object {$_.case -eq 'BASELINE'})
  if($baseline.Count -ne 1 -or [int]$baseline[0].cycles -ne 17 -or [int]$baseline[0].retired -ne 10 -or [int]$baseline[0].stalls -ne 1 -or [int]$baseline[0].redirects -ne 1){throw 'Baseline result mismatch'}
  $unit=Get-Content -LiteralPath unit_results.json -Raw | ConvertFrom-Json
  if($unit.status -ne 'PASS' -or $unit.failures -ne 0 -or $unit.spec_version -ne '1.4'){throw 'Unit JSON receipt invalid'}
  $counts=@{cla4_exhaustive=512;cla16_cases=564300;addsub_cases=564300;alu_cases=2257200;decode_exhaustive=65536;immediate_exhaustive=512;flags_transitions_exhaustive=512;rf_transactions=262161;pc_transitions=65539;branch_target_cases=3584}
  foreach($field in $counts.Keys){if($unit.$field -ne $counts[$field]){throw ('Unit JSON count mismatch: '+$field)}}
  foreach($file in @('baseline_trace.csv','case_timings.csv','datapath.vcd','datapath.wdb')){
    if(!(Test-Path -LiteralPath $file -PathType Leaf) -or (Get-Item -LiteralPath $file).Length -eq 0){throw ('Fresh result missing: '+$file)}
  }
  Write-Output 'PRE4_VERIFIED datapath=128 reset=16 legal_opcodes=14 unit_receipts=PASS'
  if(!$SkipStress){
    if(!(Test-Path -LiteralPath 'tb\tb_stress.sv' -PathType Leaf)){throw 'Supplemental stress TB missing'}
    & $Python desktop_launch.py $env:ComSpec /d /c run_stress.cmd
    if($LASTEXITCODE -ne 0){throw 'Stress launch/compile failed'}
    $stressLog=Get-Content -LiteralPath stress.log -Raw
    if($stressLog -match '(?im)Fatal:|FATAL_ERROR|ERROR:' -or $stressLog -notmatch '(?m)^STRESS_PASS cases=4696 memory_offset_boundary=3584 loops=100 random_control_flow=500 branch_offset_edges=512 completed=33134 fault_tokens=1408 taken=3636 not_taken=2155 legal_opcodes=14/14 failures=0 seed=A9D41009\r?$'){throw 'Stress PASS missing or error found'}
    $stress=Get-Content -LiteralPath stress_results.json -Raw | ConvertFrom-Json
    if($stress.status -ne 'PASS' -or $stress.failures -ne 0 -or $stress.spec_version -ne '1.4' -or $stress.seed -ne 'A9D41009'){throw 'Stress JSON receipt invalid'}
    $stressCounts=@{cases=4696;memory_offset_boundary=3584;loops=100;random_control_flow=500;branch_offset_edges=512;completed=33134;fault_tokens=1408;taken=3636;not_taken=2155;initial_flag_states=8;legal_opcode_coverage=14}
    foreach($field in $stressCounts.Keys){if($stress.$field -ne $stressCounts[$field]){throw ('Stress JSON count mismatch: '+$field)}}
    Write-Output 'PRE4_STRESS_VERIFIED cases=4696 completed=33134 fault_tokens=1408 failures=0'
  }
} finally {[Environment]::SetEnvironmentVariable('PRE4_VIVADO_BIN',$savedVivadoBin,'Process');Pop-Location}
