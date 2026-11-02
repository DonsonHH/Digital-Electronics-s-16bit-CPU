param(
 [ValidateSet('all_ops','baseline','loop','memory_copy','copy_checksum','all')][string]$Program='all',
 [ValidateSet('behavioral','synthesis','full')][string]$Mode='behavioral',
 [string]$VivadoBin='C:\AMDDesignTools\2025.2\Vivado\bin'
)
$ErrorActionPreference='Stop'
$pre6Python='C:\Users\Donson\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
if(-not(Test-Path -LiteralPath $pre6Python)){$pre6Python=(Get-Command python -ErrorAction Stop).Source}
& $pre6Python -B -X utf8 (Join-Path $PSScriptRoot 'run_project.py') --program $Program --kind cpu --mode $Mode --vivado-bin $VivadoBin
if($LASTEXITCODE -ne 0){throw "Pre6 verification failed: $LASTEXITCODE"}
