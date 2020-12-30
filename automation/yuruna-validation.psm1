# yuruna-validation module

$yuruna_root = $PSScriptRoot
$modulePath = Join-Path -Path $yuruna_root -ChildPath "import-yaml"
Import-Module -Name $modulePath

function Confirm-FolderList {
    param (
        $project_root,
        $config_root
    )
    if (-Not (Test-Path -Path $project_root)) { Write-Information "Project path not found: $project_root"; return $false; }
    if (-Not (Test-Path -Path $config_root)) { Write-Information "Config path not found: $config_root"; return $false; }

    return $true;
}

function Confirm-GlobalVariableList {
    param (
        $yaml,
        $filePath
    )

    # Validate globalVariables
    if (-Not ($null -eq  $yaml.globalVariables)) {
        foreach ($key in $yaml.globalVariables.Keys) {
            $value = $yaml.globalVariables[$key]
            Write-Debug "globalVariables[$key] = $value"
            if ([string]::IsNullOrEmpty($value)) { Write-Information "globalVariables.$key cannot be null or empty in file: $filePath"; return $false; }
        }
    }

    return $true;
}

function Confirm-ResourceList {
    param (
        $project_root,
        $config_root
    )
    Write-Debug "---- Validating Resources"
    if (!(Confirm-FolderList $project_root $config_root)) { return $false; }

    $resourcesFile = Join-Path -Path $config_root -ChildPath "resources.yml"
    if (-Not (Test-Path -Path $resourcesFile)) { Write-Information "File not found: $resourcesFile"; return $false; }
    $yaml = ConvertFrom-File $resourcesFile

    if (!(Confirm-GlobalVariableList $yaml $resourcesFile)) { return $false; }

    # Validate resources list
    if ($null -eq $yaml.resources) { Write-Information "resources cannot be null or empty in file: $resourcesFile"; return $false; }
    foreach ($resource in $yaml.resources) {
        $resourceName = $resource['name']
        $resourceTemplate = $resource['template']
        Write-Debug "resource: $resourceName - template: $resourceTemplate"
        if ([string]::IsNullOrEmpty($resourceName)) { Write-Information "resource without name in file: $resourcesFile"; return $false; }
        $templateFolder = Resolve-Path -Path (Join-Path -Path $project_root -ChildPath "resources/$resourceTemplate")
        if (-Not (Test-Path -Path $templateFolder)) { Write-Information "Resources template folder not found: $templateFolder`nUsed in file: $resourcesFile"; return $false; }
        # Variables
        if (-Not ($null -eq  $resource.variables)) {
            foreach ($key in $resource.variables.Keys) {
                $value = $resource.variables[$key]
                Write-Debug "resource[$resourceName][$key] = $value"
                if ([string]::IsNullOrEmpty($value)) { Write-Information "resource[$resourceName][$key] cannot be null or empty in file: $resourcesFile"; return $false; }
            }
        }
    }

    return $true;
}

function Confirm-ComponentList {
    param (
        $project_root,
        $config_root
    )
    Write-Debug "---- Validating Components"
    if (!(Confirm-FolderList $project_root $config_root)) { return $false; }

    $componentsFile = Join-Path -Path $config_root -ChildPath "components.yml"
    if (-Not (Test-Path -Path $componentsFile)) { Write-Information "File not found: $componentsFile"; return $false; }
    $yaml = ConvertFrom-File $componentsFile

    if (!(Confirm-GlobalVariableList $yaml $componentsFile)) { return $false; }

    # Validate components list
    if ($null -eq $yaml.components) { Write-Information "components cannot be null or empty in file: $componentsFile"; return $false; }
    foreach ($component in $yaml.components) {
        $project = $component['project']
        if ([string]::IsNullOrEmpty($project)) { Write-Information "component.project cannot be null or empty in file: $componentsFile"; return $false; }
        $buildPath = $component['buildPath']
        if ([string]::IsNullOrEmpty($buildPath)) { Write-Information "component.buildPath cannot be null or empty in file: $componentsFile"; return $false; }

        $buildCommand = $component['buildCommand']
        if ([string]::IsNullOrEmpty($buildCommand)) { $buildCommand = $yaml.globalVariables['buildCommand']; }
        if ([string]::IsNullOrEmpty($buildCommand)) { Write-Information "buildCommand cannot be null or empty in file (both globalVariables and component level): $componentsFile"; return $false; }
        $tagCommand = $component['tagCommand']
        if ([string]::IsNullOrEmpty($tagCommand)) { $tagCommand = $yaml.globalVariables['tagCommand']; }
        if ([string]::IsNullOrEmpty($tagCommand)) { Write-Information "tagCommand cannot be null or empty in file (both globalVariables and component level): $componentsFile"; return $false; }
        $pushCommand = $component['pushCommand']
        if ([string]::IsNullOrEmpty($pushCommand)) { $pushCommand = $yaml.globalVariables['pushCommand']; }
        if ([string]::IsNullOrEmpty($pushCommand)) { Write-Information "pushCommand cannot be null or empty in file (both globalVariables and component level): $componentsFile"; return $false; }
        $registryLocation = $yaml.globalVariables['registryLocation']
        if ([string]::IsNullOrEmpty($registryLocation)) { Write-Information "globalVariables.registryLocation cannot be null or empty in file: $componentsFile"; return $false; }

        $buildFolder = Resolve-Path -Path (Join-Path -Path $project_root -ChildPath "components/$buildPath")
        if (-Not (Test-Path -Path $buildFolder)) { Write-Information "Components folder not found: $buildFolder`nUsed in file: $componentsFile"; return $false; }
        Write-Debug "Project: $project in Folder: $buildPath`n$buildCommand"
    }

    return $true;
}

function Confirm-WorkloadList {
    param (
        $project_root,
        $config_root
    )
    Write-Debug "---- Validating Workloads"
    if (!(Confirm-FolderList $project_root $config_root)) { return $false; }

    $workloadsFile = Join-Path -Path $config_root -ChildPath "workloads.yml"
    if (-Not (Test-Path -Path $workloadsFile)) { Write-Information "File not found: $workloadsFile"; return $false; }
    $yaml = ConvertFrom-File $workloadsFile

    if (!(Confirm-GlobalVariableList $yaml $workloadsFile)) { return $false; }

    # Validate workloads list
    if ($null -eq $yaml.workloads) { Write-Information "workloads cannot be null or empty in file: $workloadsFile"; return $false; }
    foreach ($workload in $yaml.workloads) {
        # context should exist
        $contextName = $workload['context']
        if ([string]::IsNullOrEmpty($contextName)) { Write-Information "workloads.context cannot be null or empty in file: $workloadsFile"; return $false; }
        $originalContext = kubectl config current-context
        kubectl config use-context $contextName | Out-Null
        $currentContext = kubectl config current-context
        kubectl config use-context $originalContext | Out-Null
        if ($currentContext -ne $contextName) { Write-Information "K8S context not found: $contextName`nFile: $workloadsFile"; return $false; }
        # deployments shoudn't be null or empty
        foreach ($deployment in $workload.deployments) {
            # valid deployments are chart, kubectl, helm and shell
            $isChart = !([string]::IsNullOrEmpty($deployment['chart']))
            $isKubectl = !([string]::IsNullOrEmpty($deployment['kubectl']))
            $isHelm = !([string]::IsNullOrEmpty($deployment['helm']))
            $isShell = !([string]::IsNullOrEmpty($deployment['shell']))
            if (!($isChart -or $isKubectl -or $isHelm -or $isShell)) { Write-Information "context.deployment should be 'chart', 'kubectl', 'helm' or 'shell' in file: $workloadsFile"; return $false; }
            if ($isChart) {
                $chartName = $deployment['chart'];
                if ([string]::IsNullOrEmpty($chartName)) { Write-Information "context.chart cannot be null or empty in file: $workloadsFile"; return $false; }
                $chartFolder = Resolve-Path -Path (Join-Path -Path $project_root -ChildPath "workloads/$chartName")
                if (-Not (Test-Path -Path $chartFolder)) { Write-Information "workload[$contextName]chart[$chartName] folder not found: $chartFolder"; return $false; }
                foreach ($key in $chart.variables.Keys) {
                    $value = $chart.variables[$key]
                    if ([string]::IsNullOrEmpty($value)) { Write-Information "workload[$contextName]chart[$chartName][$key] variable cannot be null or empty in file: $workloadsFile"; return $false; }
                    Write-Debug "workload[$contextName]chart[$chartName][$key] = $value"
                }
            }
            # if ($isKubectl -or $isHelm -or $isShell)
            #   only possible to verify it is not null or empty, what has already been done!
        }
    }

    return $true;
}

function Confirm-Configuration {
    param (
        $project_root,
        $config_root
    )

    if (!(Confirm-ResourceList $project_root $config_root)) { return $false; }
    if (!(Confirm-ComponentList $project_root $config_root)) { return $false; }
    if (!(Confirm-WorkloadList $project_root $config_root)) { return $false; }

    return $true;
}

Export-ModuleMember -Function * -Alias *