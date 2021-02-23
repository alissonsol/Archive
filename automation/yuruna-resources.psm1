<#PSScriptInfo
.VERSION 0.1
.GUID 06e8bceb-f7aa-47e8-a633-1fc36173d278
.AUTHOR Alisson Sol
.COMPANYNAME None
.COPYRIGHT (c) 2021 Alisson Sol et al.
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

    # For each resource in resources.yml
    if ($null -eq $yaml.resources) { Write-Information "resources cannot be null or empty in file: $resourcesFile"; return $false; }
    foreach ($resource in $yaml.resources) {
        $resourceName = $resource['name']
        $resourceTemplate = $resource['template']
        Write-Debug "resource: $resourceName - template: $resourceTemplate"
        if ([string]::IsNullOrEmpty($resourceName)) { Write-Information "resource without name in file: $resourcesFile"; return $false; }
        # resource template can be empty: just naming already existing resource
        if (![string]::IsNullOrEmpty($resourceTemplate)) {
            $templateFolder = Join-Path -Path $project_root -ChildPath "resources/$resourceTemplate" -ErrorAction "SilentlyContinue"
            if (($null -eq $templateFolder) -or (-Not (Test-Path -Path $templateFolder))) {
                $templateFolder = Join-Path -Path $yuruna_root  -ChildPath "global/resources/$resourceTemplate" -ErrorAction "SilentlyContinue"
                if (($null -eq $templateFolder) -or (-Not (Test-Path -Path $templateFolder)))  {
                    Write-Information "Resources template not found locally or globally: $resourceTemplate`nUsed in file: $resourcesFile";
                    return $false;
                }
            }
            # copy template to work folder under .yuruna
            $workFolder = Join-Path -Path $project_root -ChildPath ".yuruna/$config_subfolder/resources/$resourceName"
            New-Item -ItemType Directory -Force -Path $workFolder -ErrorAction SilentlyContinue
            $workFolder = Resolve-Path -Path $workFolder
            Get-ChildItem -Path "$workFolder/*.tf" | Remove-Item -Verbose
            Copy-Item "$templateFolder/*" -Destination $workFolder -Recurse -Container -ErrorAction SilentlyContinue

            $terraformVarsFile = Join-Path -Path $workFolder -ChildPath "terraform.tfvars"
            New-Item -Path $terraformVarsFile -ItemType File -Force
            $terraformVars = @{}
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
                }
            }
            foreach ($key in $terraformVars.Keys) {
                $value = $terraformVars[$key]
                $line = "$key = `"$value`""
                Add-Content -Path $terraformVarsFile -Value $line
            }
            # execute terraform apply from work folder
            Push-Location $workFolder
            $result = terraform init
            Write-Debug "Terraform init: $result"
            # $result = terraform plan -compact-warnings
            # Write-Debug "Terraform plan: $result"
            # $result = terraform graph | dot -Tsvg > graph.svg
            # Write-Debug "Terraform graph: $result"
            Write-Information "Executing terraform apply from $workFolder"
            $result = terraform apply -auto-approve
            Write-Debug "Terraform apply: $result"
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

    return $true;
}

Export-ModuleMember -Function * -Alias *
