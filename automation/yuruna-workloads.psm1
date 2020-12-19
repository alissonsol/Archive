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
    #       apply variables from workloads.yml
    #       copy chart to work folder under .yuruna
    #         execute helm install in work folder
    #       other expressions use ${env:vars}
    $workloadsFile = Join-Path -Path $config_root -ChildPath "workloads.yml"
    if (-Not (Test-Path -Path $workloadsFile)) { Write-Information "File not found: $workloadsFile"; return $false; }
    $yaml = ConvertFrom-File $workloadsFile

    # For each workload in workloads.yml
    if ($null -eq $yaml.workloads) { Write-Information "workloads cannot be null or empty in file: $workloadsFile"; return $false; }
    foreach ($workload in $yaml.workloads) {
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
            #   apply variables from workloads.yml
            if (-Not ($null -eq  $yaml.globalVariables)) {
                foreach ($key in $yaml.globalVariables.Keys) {
                    $value = $yaml.globalVariables[$key]
                    $deploymentVars[$key] = $value
                }
            }
            foreach ($key in $deployment.variables.Keys) {
                $value = $deployment.variables[$key]
                if ([string]::IsNullOrEmpty($value)) { Write-Information "workload[$contextName]chart[$chartName][$key] variable cannot be null or empty in file: $workloadsFile"; return $false; }
                $deploymentVars[$key] = $value
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