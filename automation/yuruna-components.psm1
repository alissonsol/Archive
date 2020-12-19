# yuruna-components module

$yuruna_root = $PSScriptRoot
$validationModulePath = Join-Path -Path $yuruna_root -ChildPath "yuruna-validation"
Import-Module -Name $validationModulePath

function Deploy-Components {
    param (
        $project_root,
        $config_root
    )

    if (!(Confirm-Components $project_root $config_root)) { return $false; }
    Write-Debug "---- Deploying Components"
    # For each component in components.yml
    #   execute build command in the folder
    #     command is parameter in components.yml
    #   push component to registry

    $componentsFile = Join-Path -Path $config_root -ChildPath "components.yml"
    if (-Not (Test-Path -Path $componentsFile)) { Write-Information "File not found: $componentsFile"; return $false; }
    $yaml = ConvertFrom-File $componentsFile

    # Set globalVariables
    if (-Not ($null -eq  $yaml.globalVariables)) {
        foreach ($key in $yaml.globalVariables.Keys) {
            $value = $yaml.globalVariables[$key]
            Set-Item -Path Env:$key -Value ${value}
            Write-Debug "Env:$key is $(Get-Content -Path Env:$key)"
        }
    }

    $componentsPath = Join-Path -Path $project_root -ChildPath "components/"
    $containerPrefix = $yaml.globalVariables['containerPrefix']

    # For each component in components.yml
    if ($null -eq $yaml.components) { Write-Information "components cannot be null or empty in file: $componentsFile"; return $false; }
    foreach ($component in $yaml.components) {
        $project = $component['project']
        if ([string]::IsNullOrEmpty($project)) { Write-Information "component.project cannot be null or empty in file: $componentsFile"; return $false; }
        $buildPath = $component['buildPath']
        if ([string]::IsNullOrEmpty($buildPath)) { Write-Information "component.buildPath cannot be null or empty in file: $componentsFile"; return $false; }

        $buildFolder = Resolve-Path -Path (Join-Path -Path $project_root -ChildPath "components/$buildPath")
        if (-Not (Test-Path -Path $buildFolder)) { Write-Information "Components folder not found: $buildFolder`nUsed in file: $componentsFile"; return $false; }
        #   execute build command in the folder
        #     command is parameter in components.yml
        $buildCommand = $component['buildCommand']
        if ([string]::IsNullOrEmpty($buildCommand)) { $buildCommand = $yaml.globalVariables['buildCommand'] }
        if ([string]::IsNullOrEmpty($buildCommand)) { Write-Information "buildCommand cannot be null or empty in file (both globalVariables and component level): $componentsFile"; return $false; }

        $executionCommand = $ExecutionContext.InvokeCommand.ExpandString($buildCommand)
        Write-Information "Building project: $project in Folder: $buildFolder`n$executionCommand"
        $dockerfile = Join-Path -Path $buildFolder -ChildPath "Dockerfile"
        if (-Not (Test-Path -Path $dockerfile)) { $dockerfile = Join-Path -Path $buildFolder -ChildPath "dockerfile"; }
        if (-Not (Test-Path -Path $dockerfile)) { Write-Information "Missing dockerfile in folder: $buildFolder"; return $false; }
        Push-Location $componentsPath
        Set-Item -Path Env:$project -Value $project
        Set-Item -Path Env:$buildPath -Value $buildPath
        Set-Item -Path Env:$containerPrefix -Value $containerPrefix

        Invoke-Expression $buildCommand
        Pop-Location
        #   push component to registry
        $registryLocation = $yaml.globalVariables['registryLocation']
        if ([string]::IsNullOrEmpty($registryLocation)) { Write-Information "globalVariables.registryLocation cannot be null or empty in file: $componentsFile"; return $false; }
        $tagCommand = $component['tagCommand']
        if ([string]::IsNullOrEmpty($tagCommand)) { $tagCommand = $yaml.globalVariables['tagCommand']; }
        if ([string]::IsNullOrEmpty($tagCommand)) { Write-Information "tagCommand cannot be null or empty in file (both globalVariables and component level): $componentsFile"; return $false; }
        $pushCommand = $component['pushCommand']
        if ([string]::IsNullOrEmpty($pushCommand)) { $pushCommand = $yaml.globalVariables['pushCommand']; }
        if ([string]::IsNullOrEmpty($pushCommand)) { Write-Information "pushCommand cannot be null or empty in file (both globalVariables and component level): $componentsFile"; return $false; }
        Invoke-Expression $tagCommand
        $executionCommand = $ExecutionContext.InvokeCommand.ExpandString($pushCommand)
        Write-Information "$executionCommand"
        Invoke-Expression $pushCommand
    }

    return $true;
}

Export-ModuleMember -Function * -Alias *