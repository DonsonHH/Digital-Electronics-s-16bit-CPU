param([string]$VivadoBin='C:\AMDDesignTools\2025.2\Vivado\bin')
$ErrorActionPreference='Stop'
Push-Location $PSScriptRoot
try {
 $sources=@(Get-ChildItem -LiteralPath 'rtl' -Filter '*.v' | ForEach-Object FullName)
 & (Join-Path $VivadoBin 'xvlog.bat') --sv @sources tb/tb_modules.sv tb/tb_decode.sv
 if($LASTEXITCODE -ne 0){throw 'Compilation failed'}
 foreach($pair in @(@('tb_modules','pre3_sim','sim.tcl','modules.log'),@('tb_decode','decode_sim','run_all.tcl','decode.log'))){
  & (Join-Path $VivadoBin 'xelab.bat') $pair[0] -s $pair[1] -debug typical
  if($LASTEXITCODE -ne 0){throw 'Elaboration failed'}
  & (Join-Path $VivadoBin 'xsim.bat') $pair[1] -tclbatch $pair[2] -log $pair[3]
  if($LASTEXITCODE -ne 0){throw 'XSim failed'}
 }
 if(-not(Select-String -LiteralPath modules.log -SimpleMatch 'PRE3_PASS imm=512 alu=2177160 rf_transactions=263405 pc_transitions=1048582 targets=1792' -Quiet)){throw 'Module PASS missing'}
 if(-not(Select-String -LiteralPath decode.log -SimpleMatch 'DECODE_PASS words=65536 failures=0' -Quiet)){throw 'Decode PASS missing'}
 Write-Output 'VERIFIED all expected receipts present'
} finally {Pop-Location}
