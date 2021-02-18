# Yuruna: A developer toolset for cross-cloud Kubernetes-based applications.
# Showing Write-Debug messages: $DebugPreference = "Continue"
#  https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-debug
# Showing Write-Information message: $InformationPreference = "Continue"
#   https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-information

<#
    .SYNOPSIS
    Cross-cloud Kubernetes-based applications deployment.

    .DESCRIPTION
    Cross-cloud Kubernetes-based applications deployment.

    .PARAMETER operation
    Valid operations: resources, components and workloads.

    .PARAMETER project_root
    Base folder for the operations.

    .PARAMETER config_subfolder
    Configuration subfolder.

    .INPUTS
    Template files.

    .OUTPUTS
    Helper application output.

    .EXAMPLE
    C:\PS> yuruna resources
    Deploys resources using Terraform as helper.

    .EXAMPLE
    C:\PS> yuruna components
    Build and push components to registry.

    .EXAMPLE
    C:\PS> yuruna workloads
    Deploy workloads using Helm as helper.

    .LINK
    Online version: http://bit.ly/asol-yrn
#>

param (
    [string]$operation,
    [string]$project_root,
    [string]$config_subfolder
)

$yuruna_root = Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..")
Set-Item -Path Env:yuruna_root -Value ${yuruna_root}
Get-Module | Remove-Module | Out-Null
$requirementsModulePath = Join-Path -Path $yuruna_root -ChildPath "automation/yuruna-requirements"
$clearModulePath = Join-Path -Path $yuruna_root -ChildPath "automation/yuruna-clear"
$validationModulePath = Join-Path -Path $yuruna_root -ChildPath "automation/yuruna-validation"
$resourcesModulePath = Join-Path -Path $yuruna_root -ChildPath "automation/yuruna-resources"
$componentsModulePath = Join-Path -Path $yuruna_root -ChildPath "automation/yuruna-components"
$workloadsModulePath = Join-Path -Path $yuruna_root -ChildPath "automation/yuruna-workloads"
Import-Module -Name $requirementsModulePath
Import-Module -Name $clearModulePath
Import-Module -Name $validationModulePath
Import-Module -Name $resourcesModulePath
Import-Module -Name $componentsModulePath
Import-Module -Name $workloadsModulePath

if ([string]::IsNullOrEmpty($project_root)) { $project_root = Get-Location; }
$project_root = Resolve-Path -Path $project_root -ErrorAction "SilentlyContinue"

$transcriptFileName = [System.IO.Path]::GetTempFileName()
$null = Start-Transcript $transcriptFileName
$global:DebugPreference = "Continue"
$global:InformationPreference = "Continue"
$global:VerbosePreference = "SilentlyContinue"
$result = $false
switch -Exact ($operation)
{
    'requirements' { $result = Confirm-RequirementList }
    'clear' { $result = Clear-Configuration $project_root $config_subfolder }
    'validate' { $result = Confirm-Configuration $project_root $config_subfolder }
    'resources' { $result = Publish-ResourceList $project_root $config_subfolder }
    'components' { $result = Publish-ComponentList $project_root $config_subfolder }
    'workloads' { $result = Publish-WorkloadList $project_root $config_subfolder }
    Default {
        Write-Output "yuruna requirements`n    Check if machine has all requirements.";
        Write-Output "yuruna clear [project_root] [config_subfolder]`n    Clear resources for given configuration.";
        Write-Output "yuruna validate [project_root] [config_subfolder]`n    Validate configuration files.";
        Write-Output "yuruna resources [project_root] [config_subfolder]`n    Deploys resources using Terraform as helper.";
        Write-Output "yuruna components [project_root] [config_subfolder]`n    Build and push components to registry.";
        Write-Output "yuruna workloads [project_root] [config_subfolder]`n    Deploy workloads using Helm as helper.";
    }
}

$null = Stop-Transcript
if (-Not $result) {
    Write-Output $(Get-Content -Path $transcriptFileName)
}
else {
    Write-Output "See transcript with command: Write-Output `$(Get-Content -Path $transcriptFileName)"
}
