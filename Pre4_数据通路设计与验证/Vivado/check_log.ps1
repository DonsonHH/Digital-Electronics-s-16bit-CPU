param([Parameter(Mandatory=$true)][ValidateSet('datapath','units','stress')][string]$Suite)
$ErrorActionPreference='Stop'
$expected=@{
 datapath='DATAPATH_PASS cases=128 reset_probes=16 retired=3380 failures=0 legal_opcode_coverage=14/14'
 units='UNITS_PASS CLA4=512 CLA16=564300 ADD_SUB=564300 ALU=2257200 DECODE=65536 IMM=512 FLAGS=512 RF=262161 PC=65539 TARGET=3584'
 stress='STRESS_PASS cases=4696 memory_offset_boundary=3584 loops=100 random_control_flow=500 branch_offset_edges=512 completed=33134 fault_tokens=1408 taken=3636 not_taken=2155 legal_opcodes=14/14 failures=0 seed=A9D41009'
}
$path=Join-Path $PSScriptRoot ($Suite+'.log')
if(!(Test-Path -LiteralPath $path -PathType Leaf)){throw 'Required fresh log missing'}
$raw=Get-Content -LiteralPath $path -Raw
if($raw -match '(?im)Fatal:|FATAL_ERROR|ERROR:'){throw 'Log contains a fatal/error'}
# ReadLine/Get-Content accepts LF and CRLF without editing the native log.
# FINDSTR /X rejects the LF-only logs emitted by this XSim version.
$lines=@(Get-Content -LiteralPath $path)
if(!($lines -ccontains $expected[$Suite])){throw 'Exact terminal PASS line missing'}
Write-Output ('PRE4_LOG_ACCEPTED suite='+$Suite)
