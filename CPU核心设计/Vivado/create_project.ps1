param([string]$Python='',[string]$VivadoBin='',[string]$ProjectDirectoryName='project',[string]$ToolConfig='')
$ErrorActionPreference='Stop'
. (Join-Path $PSScriptRoot 'tool_config.ps1')
$resolvedCpuTools=Resolve-CpuTools -Python $Python -VivadoBin $VivadoBin -ToolConfig $ToolConfig
$Python=$resolvedCpuTools.python;$VivadoBin=$resolvedCpuTools.vivado_bin
if($ProjectDirectoryName -notmatch '^[A-Za-z0-9_-]+$'){throw 'ProjectDirectoryName must be a short ASCII directory name.'}
$existingCoreProject=Join-Path $PSScriptRoot $ProjectDirectoryName
if(Test-Path -LiteralPath $existingCoreProject){throw 'Project output already exists; choose a new -ProjectDirectoryName. Existing projects are never erased.'}
$runtimeCoreProject=Join-Path ([IO.Path]::GetTempPath()) ('cpu_core_project_'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $runtimeCoreProject | Out-Null
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'desktop_launch.py') -Destination $runtimeCoreProject
$projectSourceCore=(Join-Path $PSScriptRoot 'create_project.tcl').Replace('\','/')
# Vivado's source-file default encoding on this Windows installation is not
# UTF-8. Keep the launcher Tcl ASCII and decode non-ASCII path characters in Tcl.
$encodedPathCore=New-Object System.Text.StringBuilder
foreach($charCore in $projectSourceCore.ToCharArray()){
 if([int]$charCore -gt 127){$null=$encodedPathCore.Append(('\u{0:x4}' -f [int]$charCore))}
 elseif($charCore -in @('[',']','$','"','\')){$null=$encodedPathCore.Append('\').Append($charCore)}
 else{$null=$encodedPathCore.Append($charCore)}
}
$contentCore="set argv [list {$ProjectDirectoryName}]`nsource `"$($encodedPathCore.ToString())`"`n"
$utfCore=New-Object System.Text.UTF8Encoding($false)
[IO.File]::WriteAllText((Join-Path $runtimeCoreProject 'entry.tcl'),$contentCore,[Text.Encoding]::ASCII)
[IO.File]::WriteAllText((Join-Path $runtimeCoreProject 'run.cmd'),"@echo off`r`ncall `"$VivadoBin\vivado.bat`" -mode batch -source entry.tcl -log create.log -nojournal`r`nexit /b %errorlevel%`r`n",[Text.Encoding]::ASCII)
Push-Location $runtimeCoreProject
try{
 & $Python (Join-Path $runtimeCoreProject 'desktop_launch.py') $env:ComSpec /d /c run.cmd
 if($LASTEXITCODE -ne 0){throw 'Native Vivado project creation failed.'}
 $nativeCore=(Get-Content -LiteralPath (Join-Path $runtimeCoreProject 'create.log') -Raw)
 if($nativeCore -notmatch '(?m)^CORE_PROJECT_SOURCES_VERIFIED tool=2025\.2 part=xc7z020clg484-1\s*$' -or $nativeCore -match '(?m)^ERROR:'){throw 'Project creation completion/version/source verification failed.'}
 $projectPathCore=Join-Path $existingCoreProject 'cpu_v16.xpr'
 if(-not(Test-Path -LiteralPath $projectPathCore)){throw 'Expected XPR missing.'}
 $logDirCore=Join-Path $PSScriptRoot ('创建记录\'+(Split-Path -Leaf $runtimeCoreProject))
 New-Item -ItemType Directory -Path (Split-Path -Parent $logDirCore) -Force | Out-Null
 Copy-Item -LiteralPath $runtimeCoreProject -Destination $logDirCore -Recurse
 Write-Output ('CORE_PROJECT_READY='+$projectPathCore)
 Write-Output 'SCOPE=project/source registration only; no new XSim, synthesis, implementation or board PASS.'
}finally{Pop-Location}
