<#PSScriptInfo
.VERSION 0.1
.GUID 06e8bceb-f7aa-47e8-a633-1fc36173d278
.AUTHOR Alisson Sol
.COMPANYNAME None
.COPYRIGHT (c) 2020-2021 Alisson Sol et al.
.TAGS yuruna-resources
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

function Publish-ResourceList {
    param (
        $project_root,
        $config_subfolder
    )

    if (!(Confirm-ResourceList $project_root $config_subfolder)) { return $false; }
    Write-Debug "---- Publishing Resources"
    # For each resource in resources.yml
    #   copy template to work folder under .yuruna
    #   apply variables from resources.yml
    #   execute terraform apply from work folder
    #     creates local .terraform under work folder, which can be used later in terraform destroy

    $resourcesFile = Join-Path -Path $project_root -ChildPath "config/$config_subfolder/resources.yml"
    if (-Not (Test-Path -Path $resourcesFile)) { Write-Information "File not found: $resourcesFile"; return $false; }
    $yaml = ConvertFrom-File $resourcesFile

    $resourcesOutputFile = Join-Path -Path $project_root -ChildPath "config/$config_subfolder/resources.output.yml"
    New-Item -Path $resourcesOutputFile -ItemType File -Force

    # Global variables are saved expanded after first time
    if ((-Not ($null -eq $yaml.globalVariables))  -and (-Not ($null -eq $yaml.globalVariables.Keys))) {
        $keys = @($yaml.globalVariables.Keys)
        foreach ($key in $keys) {
            $value = $ExecutionContext.InvokeCommand.ExpandString($yaml.globalVariables[$key])
            Write-Debug "globalVariables[$key] = $value"
            Set-Item -Path Env:$key -Value ${value}
            # Expanded already
            $yaml.globalVariables[$key] = $value
        }
    }

    # For each resource in resources.yml
    if ($null -eq $yaml.resources) { Write-Information "Resources null or empty in file: $resourcesFile"; return $true; }
    foreach ($resource in $yaml.resources) {
        $resourceName = $resource['name']
        $resourceNameExpanded = $ExecutionContext.InvokeCommand.ExpandString($resourceName)
        Write-Debug "$resourceName = $resourceNameExpanded"
        $resourceName = $resourceNameExpanded
        $resourceTemplate = $resource['template']
        if ([string]::IsNullOrEmpty($resourceName)) { Write-Information "Resource without name in file: $resourcesFile"; return $false; }
        # resource template can be empty: just naming already existing resource
        if (![string]::IsNullOrEmpty($resourceTemplate)) {
            $templateFolder = Join-Path -Path $project_root -ChildPath "resources/$resourceTemplate" -ErrorAction SilentlyContinue
            if (($null -eq $templateFolder) -or (-Not (Test-Path -Path $templateFolder))) {
                $templateFolder = Join-Path -Path $yuruna_root  -ChildPath "global/resources/$resourceTemplate" -ErrorAction SilentlyContinue
                if (($null -eq $templateFolder) -or (-Not (Test-Path -Path $templateFolder)))  {
                    Write-Information "Resources template not found locally or globally: $resourceTemplate`nUsed in file: $resourcesFile";
                    return $false;
                }
            }
            Write-Information "-- Resource: $resourceName from template $templateFolder"
            # copy template to work folder under .yuruna
            $workFolder = Join-Path -Path $project_root -ChildPath ".yuruna/$config_subfolder/resources/$resourceName"
            New-Item -ItemType Directory -Force -Path $workFolder -ErrorAction SilentlyContinue
            $workFolder = Resolve-Path -Path $workFolder
            Get-ChildItem -Path "$workFolder/*.tf" | Remove-Item -Force -ErrorAction SilentlyContinue
            Copy-Item "$templateFolder/*" -Destination $workFolder -Recurse -Container -ErrorAction SilentlyContinue

            $terraformVarsFile = Join-Path -Path $workFolder -ChildPath "terraform.tfvars"
            New-Item -Path $terraformVarsFile -ItemType File -Force
            $terraformVars = [ordered]@{}
            if (-Not ($null -eq  $yaml.globalVariables)) {
                foreach ($key in $yaml.globalVariables.Keys) {
                    $value = $yaml.globalVariables[$key]
                    $terraformVars[$key] = $value
                }
            }
            if (-Not ($null -eq  $resource.variables)) {
                foreach ($key in $resource.variables.Keys) {
                    $value = $resource.variables[$key]
                    $terraformVars[$key] = $value
                    Write-Debug "resourceVariables[$key] = $value"
                }
            }
            foreach ($key in $terraformVars.Keys) {
                $value = $ExecutionContext.InvokeCommand.ExpandString($terraformVars[$key])
                if ([string]::IsNullOrEmpty($value)) { Write-Debug "WARNING: empty value for $key" }
                $line = "$key = `"$value`""
                Add-Content -Path $terraformVarsFile -Value $line
                Set-Item -Path Env:$key -Value ${value}
                Write-Verbose "$line"
            }
            # execute terraform apply from work folder
            Push-Location $workFolder

            # warn if terraform already initialized
            $terraformPath = Join-Path -Path $workFolder -ChildPath ".terraform"
            if (Test-Path -Path $terraformPath) { Write-Information "-- WARNING: terraform already initialized. Resource may not be created. Use 'yuruna clear' to clear terraform state."; }
            Write-Debug "Terraform init"
            $result = $(terraform init *>&1 | Write-Verbose)
            if (![string]::IsNullOrEmpty($result)) { Write-Debug "$result"; }
            # terraform plan -compact-warnings
            # terraform graph | dot -Tsvg > graph.svg
            Write-Debug "Executing terraform apply from $workFolder"
            $result = $(terraform apply -auto-approve *>&1 | Write-Verbose)
            if (![string]::IsNullOrEmpty($result)) { Write-Debug "$result"; }
            # resource.output file processing
            $jsonOutput = "$(terraform output -json)"
            if (![string]::IsNullOrEmpty($jsonOutput)) {
                $terraformYaml = $jsonOutput | ConvertFrom-Json
                $tuple = @{ }
                $tuple."$resourceName" = $terraformYaml
                Add-Content -Path $resourcesOutputFile -Value $(ConvertTo-Yaml $tuple)
            }
            Pop-Location
        }
    }

    if ((Get-Item $resourcesOutputFile).Length -gt 0) { Write-Information "Resources output file: $resourcesOutputFile"; }

    return $true;
}

Export-ModuleMember -Function * -Alias *
