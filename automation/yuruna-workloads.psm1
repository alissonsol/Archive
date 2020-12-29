# yuruna-workloads module

$yuruna_root = $PSScriptRoot
$validationModulePath = Join-Path -Path $yuruna_root -ChildPath "yuruna-validation"
Import-Module -Name $validationModulePath

function Publish-WorkloadList {
    param (
        $project_root,
        $config_root
    )

    if (!(Confirm-WorkloadList $project_root $config_root)) { return $false; }
    Write-Debug "---- Publish Workloads"
    # For each workload in workloads.yml
    #   switch to context
    #     apply deployments: chart, kubectl, helm, or shell
    #       copy chart to work folder under .yuruna
    #       apply global variables, resources.output variables, workload variables
    #         execute helm install in work folder
    #       other expressions use ${env:vars}
    $workloadsFile = Join-Path -Path $config_root -ChildPath "workloads.yml"
    if (-Not (Test-Path -Path $workloadsFile)) { Write-Information "File not found: $workloadsFile"; return $false; }
    $workloadsYaml = ConvertFrom-File $workloadsFile
    if ($null -eq $workloadsYaml) { Write-Information "workloads cannot be null or empty in file: $workloadsFile"; return $false; }
    if ($null -eq $workloadsYaml.workloads) { Write-Information "workloads cannot be null or empty in file: $workloadsFile"; return $false; }

    $resourcesOutputFile = Join-Path -Path $config_root -ChildPath "resources.output.yml"
    $resourcesOutputYaml = $null
    if (Test-Path -Path $resourcesOutputFile) {
        $resourcesOutputYaml = ConvertFrom-File $resourcesOutputFile
    }

    # For each workload in workloads.yml
    foreach ($workload in $workloadsYaml.workloads) {
        # context should exist
        $contextName = $workload['context']
        if ([string]::IsNullOrEmpty($contextName)) { Write-Information "workloads.context cannot be null or empty in file: $workloadsFile"; return $false; }
        $originalContext = kubectl config current-context
        kubectl config use-context $contextName | out-null
        $currentContext = kubectl config current-context
        kubectl config use-context $originalContext | out-null
        if ($currentContext -ne $contextName) { Write-Information "K8S context not found: $contextName`nFile: $workloadsFile"; return $false; }
        # deployments shoudn't be null or empty
        foreach ($deployment in $workload.deployments) {
            # apply deployments: chart, kubectl, helm, or shell
            $isChart = !([string]::IsNullOrEmpty($deployment['chart']))
            $isKubectl = !([string]::IsNullOrEmpty($deployment['kubectl']))
            $isHelm = !([string]::IsNullOrEmpty($deployment['helm']))
            $isShell = !([string]::IsNullOrEmpty($deployment['shell']))
            if (!($isChart -or $isKubectl -or $isHelm -or $isShell)) { Write-Information "context.deployment should be 'chart', 'kubectl', 'helm' or 'shell' in file: $workloadsFile"; return $false; }

            $deploymentVars = @{}
            #       apply global variables, resources.output variables, workload variables
            if ((-Not ($null -eq $workloadsYaml.globalVariables))  -and (-Not ($null -eq  $workloadsYaml.globalVariables.Keys))) {
                foreach ($key in $workloadsYaml.globalVariables.Keys) {
                    $value = $workloadsYaml.globalVariables[$key]
                    $deploymentVars[$key] = $value
                }
            }
            if ((-Not ($null -eq $resourcesOutputYaml)) -and (-Not ($null -eq  $resourcesOutputYaml.Keys))) {
                foreach ($key in $resourcesOutputYaml.Keys) {
                    $value = $resourcesOutputYaml[$key].value
                    $deploymentVars[$key] = $value
                }
            }
            if ((-Not ($null -eq $deployment.variables))  -and (-Not ($null -eq  $deployment.variables.Keys))) {
                foreach ($key in $deployment.variables.Keys) {
                    $value = $deployment.variables[$key]
                    $deploymentVars[$key] = $value
                }
            }
            if ($isChart) {
                $chartName = $deployment['chart']
                if ([string]::IsNullOrEmpty($chartName)) { Write-Information "context.chart cannot be null or empty in file: $workloadsFile"; return $false; }
                $chartFolder = Resolve-Path -Path (Join-Path -Path $project_root -ChildPath "workloads/$chartName")
                if (-Not (Test-Path -Path $chartFolder)) { Write-Information "workload[$contextName]chart[$chartName] folder not found: $chartFolder"; return $false; }
                #   copy chart to work folder under .yuruna
                $workFolder = Join-Path -Path $project_root -ChildPath ".yuruna/workloads/$contextName/$chartName"
                New-Item -ItemType Directory -Force -Path $workFolder -ErrorAction SilentlyContinue
                $workFolder = Resolve-Path -Path $workFolder
                Copy-Item "$chartFolder/*" -Destination $workFolder -Recurse -ErrorAction SilentlyContinue

                # deploymentVars to values.yaml
                $helmValuesFile = Join-Path -Path $workFolder -ChildPath "values.yaml"
                New-Item -Path $helmValuesFile -ItemType File -Force
                foreach ($key in $deploymentVars.Keys) {
                    $value = $deploymentVars[$key]
                    $line = "${key}: `"$value`""
                    Add-Content -Path $helmValuesFile -Value $line
                }
                #   execute helm install in work folder
                Write-Debug "`Helm execute from: $workFolder"
                Push-Location $workFolder
                $result = helm lint
                Write-Debug "Helm link`n$result"
                $installName = $chartName -replace '[^a-zA-Z]', ''
                $result = helm uninstall $installName
                Write-Debug "helm uninstall $installName`n$result"
                $result = helm install $installName .
                Write-Debug "Helm install $installName`n$result"
                Pop-Location
            }
            else {
                # deploymentVars to environment
                foreach ($key in $deploymentVars.Keys) {
                    $value = $deploymentVars[$key]
                    Set-Item -Path Env:$key -Value ${value}
                }
                $expression = $null
                if ($isKubectl) { $value = $deployment['kubectl']; $expression = "kubectl $value" }
                if ($isHelm) { $value = $deployment['helm']; $expression = "helm $value"; }
                if ($isShell) { $value = $deployment['shell']; $expression = "$value"}

                $workFolder = Join-Path -Path $project_root -ChildPath ".yuruna/workloads/$contextName"
                New-Item -ItemType Directory -Force -Path $workFolder -ErrorAction SilentlyContinue
                $workFolder = Resolve-Path -Path $workFolder
                Set-Item -Path Env:workFolder -Value ${workFolder}
                Push-Location $workFolder
                $expression = $ExecutionContext.InvokeCommand.ExpandString($expression)
                Write-Debug "$expression"
                $result = Invoke-Expression $expression
                Write-Debug "$result"
                Pop-Location
            }
        }
    }

    return $true;
}

Export-ModuleMember -Function * -Alias *