<#PSScriptInfo
.VERSION 0.1
.GUID 06e8bceb-f7aa-47e8-a633-1fc36173d278
.AUTHOR Alisson Sol
.COMPANYNAME None
.COPYRIGHT (c) 2020-2021 Alisson Sol et al.
.TAGS yuruna-workloads
.LICENSEURI http://www.yuruna.com
.PROJECTURI http://www.yuruna.com
.ICONURI
.EXTERNALMODULEDEPENDENCIES powershell-yaml
.REQUIREDSCRIPTS
.EXTERNALSCRIPTDEPENDENCIES
.RELEASENOTES
.PRIVATEDATA
#>

$yuruna_root = Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..")
$validationModulePath = Join-Path -Path $yuruna_root -ChildPath "automation/yuruna-validation"
Import-Module -Name $validationModulePath

function Publish-WorkloadList {
    param (
        $project_root,
        $config_subfolder
    )

    if (!(Confirm-WorkloadList $project_root $config_subfolder)) { return $false; }
    Write-Debug "---- Publish Workloads"
    # For each workload in workloads.yml
    #   switch to context
    #     apply deployments: chart, kubectl, helm, or shell
    #       copy chart to work folder under .yuruna
    #       apply global variables, resources.output variables, workload variables
    #         execute helm install in work folder
    #       other expressions use ${env:vars}
    $workloadsFile = Join-Path -Path $project_root -ChildPath "config/$config_subfolder/workloads.yml"
    if (-Not (Test-Path -Path $workloadsFile)) { Write-Information "File not found: $workloadsFile"; return $false; }
    $workloadsYaml = ConvertFrom-File $workloadsFile
    if ($null -eq $workloadsYaml) { Write-Information "workloads cannot be null or empty in file: $workloadsFile"; return $false; }
    if ($null -eq $workloadsYaml.workloads) { Write-Information "workloads cannot be null or empty in file: $workloadsFile"; return $false; }

    $resourcesOutputFile = Join-Path -Path $project_root -ChildPath "config/$config_subfolder/resources.output.yml"
    $resourcesOutputYaml = $null
    if (Test-Path -Path $resourcesOutputFile) {
        $resourcesOutputYaml = ConvertFrom-File $resourcesOutputFile
    }
    else {
        # Allow deployment of workloads in phases, reusing upper resource output
        $resourcesOutputFile = Join-Path -Path $project_root -ChildPath "config/$config_subfolder/../resources.output.yml"
        if (Test-Path -Path $resourcesOutputFile) {
            $resourcesOutputYaml = ConvertFrom-File $resourcesOutputFile
        }
    }

    # Debug info
    if ((-Not ($null -eq $resourcesOutputYaml)) -and (-Not ($null -eq $resourcesOutputYaml.Keys))) {
        foreach ($resource in $resourcesOutputYaml.Keys) {
            foreach ($key in $resourcesOutputYaml.$resource.Keys) {
                $resourceKey = "$resource.$key"
                $value = $ExecutionContext.InvokeCommand.ExpandString($resourcesOutputYaml.$resource[$key].value)
                Write-Debug "resourcesOutput[$resourceKey] = $value"
                Set-Item -Path Env:$resourceKey -Value ${value}
            }
        }
    }

    if ((-Not ($null -eq $workloadsYaml.globalVariables))  -and (-Not ($null -eq $workloadsYaml.globalVariables.Keys))) {
        foreach ($key in $workloadsYaml.globalVariables.Keys) {
            $value = $ExecutionContext.InvokeCommand.ExpandString($workloadsYaml.globalVariables[$key])
            Write-Debug "globalVariables[$key] = $value"
            Set-Item -Path Env:$key -Value ${value}
        }
    }

    # For each workload in workloads.yml
    foreach ($workload in $workloadsYaml.workloads) {
        # new work folder
        $contextName = $ExecutionContext.InvokeCommand.ExpandString($workload['context'])
        Write-Information "-- Workloads for context: $contextName"
        if ([string]::IsNullOrEmpty($contextName)) { Write-Information "workloads.context cannot be null or empty in file: $workloadsFile"; return $false; }
        $workFolder = Join-Path -Path $project_root -ChildPath ".yuruna/$config_subfolder/workloads/$contextName"
        if (-Not ([string]::IsNullOrEmpty($workFolder))) {
            $workFolder = Resolve-Path -Path $workFolder -ErrorAction SilentlyContinue
            if (-Not ([string]::IsNullOrEmpty($workFolder))) {
                Remove-Item -Path $workFolder -Force -Recurse -ErrorAction SilentlyContinue
            }
        }
        Set-Item -Path Env:contextName -Value ${contextName}

        if ((-Not ($null -eq $workload.variables))  -and (-Not ($null -eq $workload.variables.Keys))) {
            foreach ($key in $workload.variables.Keys) {
                $value = $ExecutionContext.InvokeCommand.ExpandString($workload.variables[$key])
                Write-Debug "workloadVariables[$key] = $value"
                Set-Item -Path Env:$key -Value ${value}
            }
        }

        $workFolder = Join-Path -Path $project_root -ChildPath ".yuruna/$config_subfolder/workloads/$contextName"
        New-Item -ItemType Directory -Force -Path $workFolder -ErrorAction Si
        #context should exist
        $originalContext = kubectl config current-context
        kubectl config use-context $contextName *>&1 | Write-Verbose
        $currentContext = kubectl config current-context
        kubectl config use-context $originalContext *>&1 | Write-Verbose
        if ($currentContext -ne $contextName) { Write-Information "K8S context not found: $contextName`nFile: $workloadsFile"; return $false; }
        kubectl config use-context $contextName *>&1 | Write-Verbose

        # deployments shoudn't be null or empty
        foreach ($deployment in $workload.deployments) {
            # apply deployments: chart, kubectl, helm, or shell
            $isChart = !([string]::IsNullOrEmpty($deployment['chart']))
            $isKubectl = !([string]::IsNullOrEmpty($deployment['kubectl']))
            $isHelm = !([string]::IsNullOrEmpty($deployment['helm']))
            $isShell = !([string]::IsNullOrEmpty($deployment['shell']))
            if (!($isChart -or $isKubectl -or $isHelm -or $isShell)) { Write-Information "context.deployment should be 'chart', 'kubectl', 'helm' or 'shell' in file: $workloadsFile"; return $false; }

            $deploymentVars = [ordered]@{}
            # apply global variables, resources.output variables, workload variables, deployment variables
            # previous loops just presented values for debugging
            if ((-Not ($null -eq $resourcesOutputYaml)) -and (-Not ($null -eq  $resourcesOutputYaml.Keys))) {
                foreach ($resource in $resourcesOutputYaml.Keys) {
                    foreach ($key in $resourcesOutputYaml.$resource.Keys) {
                        $resourceKey = "$resource.$key"
                        $value = $ExecutionContext.InvokeCommand.ExpandString($resourcesOutputYaml.$resource[$key].value)
                        $deploymentVars[$resourceKey] = $value
                        Set-Item -Path Env:$resourceKey -Value ${value}
                    }
                }
            }

            if ((-Not ($null -eq $workloadsYaml.globalVariables)) -and (-Not ($null -eq $workloadsYaml.globalVariables.Keys))) {
                foreach ($key in $workloadsYaml.globalVariables.Keys) {
                    $value = $ExecutionContext.InvokeCommand.ExpandString($workloadsYaml.globalVariables[$key])
                    $deploymentVars[$key] = $value
                    Set-Item -Path Env:$key -Value ${value}
                }
            }

            if ((-Not ($null -eq $workload.variables)) -and (-Not ($null -eq $workload.variables.Keys))) {
                foreach ($key in $workload.variables.Keys) {
                    $value = $ExecutionContext.InvokeCommand.ExpandString($workload.variables[$key])
                    $deploymentVars[$key] = $value
                    Set-Item -Path Env:$key -Value ${value}
                }
            }

            if ((-Not ($null -eq $deployment.variables)) -and (-Not ($null -eq $deployment.variables.Keys))) {
                foreach ($key in $deployment.variables.Keys) {
                    $rawValue = $deployment.variables[$key]
                    $value = $ExecutionContext.InvokeCommand.ExpandString($rawValue)
                    if ([string]::IsNullOrEmpty($value)) { Write-Debug "WARNING: empty value for $key" }
                    $deploymentVars[$key] = $value
                    Set-Item -Path Env:$key -Value ${value}
                    Write-Debug "deploymentVariables[$key] = $value"
                }
            }

            if ($isChart) {
                $chartName = $deployment['chart']
                if ([string]::IsNullOrEmpty($chartName)) { Write-Information "context.chart cannot be null or empty in file: $workloadsFile"; return $false; }
                $chartFolder = Resolve-Path -Path (Join-Path -Path $project_root -ChildPath "workloads/$chartName")
                if (-Not (Test-Path -Path $chartFolder)) { Write-Information "workload[$contextName]chart[$chartName] folder not found: $chartFolder"; return $false; }
                $installName = $ExecutionContext.InvokeCommand.ExpandString($deployment.variables['installName'])
                if ([string]::IsNullOrEmpty($installName)) {
                    Write-Information "Chart[$chartName] missing variables['installName'] in file: $workloadsFile"; return $false;
                }
                # copy chart to work folder under .yuruna
                $workFolder = Join-Path -Path $project_root -ChildPath ".yuruna/$config_subfolder/workloads/$contextName/$installName"
                New-Item -ItemType Directory -Force -Path $workFolder -ErrorAction SilentlyContinue
                $workFolder = Resolve-Path -Path $workFolder
                Write-Debug "Copying chart from: $chartFolder to $workFolder"
                Copy-Item "$chartFolder/*" -Destination $workFolder -Recurse -Container -ErrorAction SilentlyContinue

                # deploymentVars to values.yaml
                $helmValuesFile = Join-Path -Path $workFolder -ChildPath "values.yaml"
                New-Item -Path $helmValuesFile -ItemType File -Force
                foreach ($key in $deploymentVars.Keys) {
                    $value = $deploymentVars[$key]
                    # https://helm.sh/docs/intro/using_helm/#the-format-and-limitations-of---set
                    $value =  $value -replace '\\', ''
                    $line = "${key}: `"$value`""
                    if (($value.ToString().StartsWith("`"")) -and ($value.ToString().EndsWith("`""))) {
                        $line = "${key}: $value"
                    }
                    Add-Content -Path $helmValuesFile -Value $line
                }
                $line = "contextName: `"$contextName`""
                Add-Content -Path $helmValuesFile -Value $line
                # execute helm install in work folder
                Write-Debug "`Helm execute from: $workFolder"
                Push-Location $workFolder
                $result = $(helm lint *>&1 | Write-Verbose)
                Write-Debug "Helm lint`n$result"
                $result = $(helm uninstall $installName *>&1 | Write-Verbose)
                Write-Debug "Helm uninstall $installName`n$result"
                $result = $(helm install $installName . --debug *>&1 | Write-Verbose)
                Write-Debug "Helm install $installName`n$result"
                Pop-Location
            }
            else {
                # deploymentVars to environment
                foreach ($key in $deploymentVars.Keys) {
                    $value = $deploymentVars[$key]
                    Set-Item -Path Env:$key -Value ${value}
                }
                Set-Item -Path Env:contextName -Value ${contextName}
                $expression = $null
                if ($isKubectl) { $value = $deployment['kubectl']; $expression = "kubectl $value" }
                if ($isHelm) { $value = $deployment['helm']; $expression = "helm $value"; }
                if ($isShell) { $value = $deployment['shell']; $expression = "$value"}

                $workFolder = Join-Path -Path $project_root -ChildPath ".yuruna/$config_subfolder/workloads/$contextName"
                $workFolder = Resolve-Path -Path $workFolder
                Set-Item -Path Env:workFolder -Value ${workFolder}
                Push-Location $workFolder
                $expression = $ExecutionContext.InvokeCommand.ExpandString($expression)
                Write-Debug "$expression"
                # Shell could be used to Write-Information back to user
                if ($isShell) {
                    $result = Invoke-Expression $expression *>&1 | Write-Information
                }
                else {
                    $result = Invoke-Expression $expression *>&1 | Write-Verbose
                }
                Write-Debug "$result"
                Pop-Location
            }
        }
        kubectl config use-context $originalContext *>&1 | Write-Verbose
    }

    return $true;
}

Export-ModuleMember -Function * -Alias *
