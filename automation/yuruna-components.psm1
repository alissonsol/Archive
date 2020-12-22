# yuruna-components module

$yuruna_root = $PSScriptRoot
$validationModulePath = Join-Path -Path $yuruna_root -ChildPath "yuruna-validation"
Import-Module -Name $validationModulePath

function Publish-ComponentList {
    param (
        $project_root,
        $config_root
    )

    if (!(Confirm-ComponentList $project_root $config_root)) { return $false; }
    Write-Debug "---- Publishing Components"
    # For each component in components.yml
    #   apply global variables, resources.output variables, workload variables
    #   execute build command in the folder
    #     command is parameter in components.yml
    #   tag and push component to registry

    $componentsFile = Join-Path -Path $config_root -ChildPath "components.yml"
    if (-Not (Test-Path -Path $componentsFile)) { Write-Information "File not found: $componentsFile"; return $false; }
    $componentsYaml = ConvertFrom-File $componentsFile
    if ($null -eq $componentsYaml) { Write-Information "components cannot be null or empty in file: $componentsFile"; return $false; }
    if ($null -eq $componentsYaml.components) { Write-Information "components cannot be null or empty in file: $componentsFile"; return $false; }

    $resourcesOutputFile = Join-Path -Path $config_root -ChildPath "resources.output.yml"
    $resourcesOutputYaml = $null
    if (Test-Path -Path $resourcesOutputFile) {
        $resourcesOutputYaml = ConvertFrom-File $resourcesOutputFile
    }

    $componentsPath = Join-Path -Path $project_root -ChildPath "components/"
    # For each component in components.yml
    foreach ($component in $componentsYaml.components) {
        # Component project
        $project = $component['project']
        if ([string]::IsNullOrEmpty($project)) { Write-Information "component.project cannot be null or empty in file: $componentsFile"; return $false; }
        $buildPath = $component['buildPath']
        if ([string]::IsNullOrEmpty($buildPath)) { Write-Information "component.buildPath cannot be null or empty in file: $componentsFile"; return $false; }

        $componentVars = @{}
        # apply global variables, resources.output variables, workload variables
        if (-Not ($null -eq $componentsYaml.globalVariables)) {
            foreach ($key in $componentsYaml.globalVariables.Keys) {
                $value = $componentsYaml.globalVariables[$key]
                $componentVars[$key] = $value
            }
        }
        if ((-Not ($null -eq $resourcesOutputYaml)) -and (-Not ($null -eq  $resourcesOutputYaml.Keys))) {
            foreach ($key in $resourcesOutputYaml.Keys) {
                $value = $resourcesOutputYaml[$key].value
                $componentVars[$key] = $value
            }
        }
        if ((-Not ($null -eq $component.variables))  -and (-Not ($null -eq  $component.variables.Keys))) {
            foreach ($key in $component.variables.Keys) {
                $value = $component.variables[$key]
                $componentVars[$key] = $value
            }
        }
        $buildFolder = Resolve-Path -Path (Join-Path -Path $project_root -ChildPath "components/$buildPath")
        if (-Not (Test-Path -Path $buildFolder)) { Write-Information "Components folder not found: $buildFolder`nUsed in file: $componentsFile"; return $false; }
        #   execute build command in the folder
        #     command is parameter in components.yml
        $buildCommand = $component['buildCommand']
        if ([string]::IsNullOrEmpty($buildCommand)) { $buildCommand = $componentsYaml.globalVariables['buildCommand'] }
        if ([string]::IsNullOrEmpty($buildCommand)) { Write-Information "buildCommand cannot be null or empty in file (both globalVariables and component level): $componentsFile"; return $false; }

        Write-Information "-- Building project: $project in Folder: $buildFolder"
        $dockerfile = Join-Path -Path $buildFolder -ChildPath "Dockerfile"
        if (-Not (Test-Path -Path $dockerfile)) { $dockerfile = Join-Path -Path $buildFolder -ChildPath "dockerfile"; }
        if (-Not (Test-Path -Path $dockerfile)) { Write-Information "Missing dockerfile in folder: $buildFolder"; return $false; }

        $componentVars['project'] = $project
        $componentVars['buildPath'] = $buildPath
        $componentVars['dockerfile'] = $dockerfile
        foreach ($key in $componentVars.Keys) {
            $value = $componentVars[$key]
            Set-Item -Path Env:$key -Value ${value}
            Write-Debug "$project[Env:$key] is $(Get-Content -Path Env:$key)"
        }

        Push-Location $componentsPath
        Invoke-Expression $buildCommand
        $executionCommand = $ExecutionContext.InvokeCommand.ExpandString($buildCommand)
        Write-Information "Build: $executionCommand"
        Invoke-Expression $executionCommand
        Pop-Location
        #   tag and push component to registry
        $tagCommand = $component['tagCommand']
        if ([string]::IsNullOrEmpty($tagCommand)) { $tagCommand = $componentsYaml.globalVariables['tagCommand']; }
        if ([string]::IsNullOrEmpty($tagCommand)) { Write-Information "tagCommand cannot be null or empty in file (both globalVariables and component level): $componentsFile"; return $false; }
        $pushCommand = $component['pushCommand']
        if ([string]::IsNullOrEmpty($pushCommand)) { $pushCommand = $componentsYaml.globalVariables['pushCommand']; }
        if ([string]::IsNullOrEmpty($pushCommand)) { Write-Information "pushCommand cannot be null or empty in file (both globalVariables and component level): $componentsFile"; return $false; }
        $executionCommand = $ExecutionContext.InvokeCommand.ExpandString($tagCommand)
        Write-Information "Tag: $executionCommand"
        Invoke-Expression $executionCommand
        # TODO: generic registry login approach
        $executionCommand = $ExecutionContext.InvokeCommand.ExpandString("az acr login -n ${env:registryName}")
        Invoke-Expression $executionCommand | Out-Null
        $executionCommand = $ExecutionContext.InvokeCommand.ExpandString($pushCommand)
        Write-Information "Push: $executionCommand"
        Invoke-Expression $executionCommand
    }

    return $true;
}

Export-ModuleMember -Function * -Alias *