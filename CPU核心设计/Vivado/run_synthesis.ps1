param(
 [string]$Python='',
 [string]$VivadoBin='',
 [string]$ToolConfig=''
)
$ErrorActionPreference='Stop'
$packageRoot=(Resolve-Path -LiteralPath (Split-Path -Parent $PSScriptRoot)).Path
$statusPath=Join-Path $packageRoot '最近综合.json'
$attempt=[ordered]@{status='running';spec_version='1.6';started_at_utc=[DateTime]::UtcNow.ToString('o');note='综合结果.json is the last completed synthesis, not proof of this attempt or timing closure.'}
$previousCpuVivadoBin=$env:CPU_VIVADO_BIN
$locationPushed=$false
try{
 $attempt | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $statusPath -Encoding utf8
 . (Join-Path $PSScriptRoot 'tool_config.ps1')
 $resolvedCpuTools=Resolve-CpuTools -Python $Python -VivadoBin $VivadoBin -ToolConfig $ToolConfig
 $Python=$resolvedCpuTools.python;$VivadoBin=$resolvedCpuTools.vivado_bin
 if(-not(Test-Path -LiteralPath $Python -PathType Leaf)){throw 'Bundled Python is missing; supply -Python.'}
 if(-not(Test-Path -LiteralPath (Join-Path $VivadoBin 'vivado.bat') -PathType Leaf)){throw 'Required Vivado executable is missing; supply -VivadoBin.'}
 $runtimeDirectory=Join-Path ([System.IO.Path]::GetTempPath()) ('cpu_v16_synth_'+[guid]::NewGuid().ToString('N'))
 $attempt['runtime']=$runtimeDirectory
 New-Item -ItemType Directory -Path (Join-Path $runtimeDirectory 'rtl') | Out-Null
 Get-ChildItem -LiteralPath (Join-Path $PSScriptRoot 'rtl') -File | ForEach-Object {Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $runtimeDirectory 'rtl')}
 Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'constraints') -Destination (Join-Path $runtimeDirectory 'constraints') -Recurse
 $drivers=@('run_synth.cmd','synth_ooc.tcl','run_synthesis.ps1','verify_synthesis.py','desktop_launch.py')
 foreach($name in $drivers){Copy-Item -LiteralPath (Join-Path $PSScriptRoot $name) -Destination $runtimeDirectory}
 $attempt | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $statusPath -Encoding utf8
 Push-Location $runtimeDirectory
 $locationPushed=$true
 $env:CPU_VIVADO_BIN=$VivadoBin
 Write-Output ('V16_SYNTH_RUNTIME='+$runtimeDirectory)
 & $Python (Join-Path $runtimeDirectory 'desktop_launch.py') $env:ComSpec /d /c run_synth.cmd
 if($LASTEXITCODE -ne 0){throw 'Vivado synthesis failed.'}
 $runKey=Split-Path -Leaf $runtimeDirectory
 $archiveRelative='Vivado/综合记录/'+$runKey
 & $Python (Join-Path $runtimeDirectory 'verify_synthesis.py') --run $runtimeDirectory --package $packageRoot --archive-relative $archiveRelative
 if($LASTEXITCODE -ne 0){throw 'Fresh synthesis result verification failed; no completed receipt will be published.'}
 $archive=Join-Path $packageRoot $archiveRelative
 New-Item -ItemType Directory -Path $archive | Out-Null
 foreach($name in @('utilization.rpt','post_synth_timing.rpt','core_synth.dcp','core_netlist.v')){Copy-Item -LiteralPath (Join-Path $runtimeDirectory ('eda\'+$name)) -Destination $archive}
 foreach($name in ($drivers+@('synthesis.log','synthesis_results.json'))){Copy-Item -LiteralPath (Join-Path $runtimeDirectory $name) -Destination $archive}
 foreach($name in @('rtl','constraints')){Copy-Item -LiteralPath (Join-Path $runtimeDirectory $name) -Destination (Join-Path $archive $name) -Recurse}
 # Publish only after source snapshots and reports have all been archived.
 Copy-Item -LiteralPath (Join-Path $archive 'synthesis_results.json') -Destination (Join-Path $packageRoot '综合结果.json')
 $attempt['status']='completed';$attempt['completed_at_utc']=[DateTime]::UtcNow.ToString('o');$attempt['archived_run']=$archive;$attempt['note']='Fresh native OOC synthesis recorded; timing closure and board validation remain pending.'
 $attempt | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $statusPath -Encoding utf8
 Write-Output ('V16_SYNTHESIS_SAVED='+$archive)
 Write-Output 'SCOPE=post-synthesis OOC estimate only; timing closure and board validation remain pending.'
}catch{
 $attempt['status']='failed';$attempt['completed_at_utc']=[DateTime]::UtcNow.ToString('o');$attempt['error']=$_.Exception.Message;$attempt['note']='No new completed receipt published; previous 综合结果.json is historical.'
 $attempt | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $statusPath -Encoding utf8
 throw
}finally{
 [Environment]::SetEnvironmentVariable('CPU_VIVADO_BIN',$previousCpuVivadoBin,'Process')
 if($locationPushed){Pop-Location}
}
