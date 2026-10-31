function Resolve-CpuTools {
 param([string]$Python,[string]$VivadoBin,[string]$ToolConfig)
 $configPath=if($ToolConfig){$ToolConfig}else{Join-Path (Split-Path -Parent $PSScriptRoot) 'tools.local.json'}
 $values=if(Test-Path -LiteralPath $configPath){Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json}else{$null}
 if(-not $Python){$Python=if($values.python){$values.python}elseif($env:CPU_PYTHON){$env:CPU_PYTHON}else{'python'}}
 $pythonCommand=Get-Command $Python -ErrorAction Stop
 $Python=$pythonCommand.Source
 $arguments=@((Join-Path $PSScriptRoot 'tool_config.py'),'--python',$Python)
 if($ToolConfig -or (Test-Path -LiteralPath $configPath)){$arguments+=@('--config',$configPath)}
 if($VivadoBin){$arguments+=@('--vivado-bin',$VivadoBin)}
 $output=& $Python -B -X utf8 @arguments
 if($LASTEXITCODE -ne 0){throw 'CPU tool configuration failed before execution.'}
 return ($output | ConvertFrom-Json)
}
