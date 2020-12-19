# Yuruna: Cross-cloud Kubernetes-based applications
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

    .LINK
    yuruna.com
#>

param (
    [string]$operation,
    [string]$project_root,
    [string]$config_subfolder
)

$yuruna_root = $PSScriptRoot
Get-Module | Remove-Module
$validationModulePath = Join-Path -Path $yuruna_root -ChildPath "yuruna-validation"
$resourcesModulePath = Join-Path -Path $yuruna_root -ChildPath "yuruna-resources"
$componentsModulePath = Join-Path -Path $yuruna_root -ChildPath "yuruna-components"
$workloadsModulePath = Join-Path -Path $yuruna_root -ChildPath "yuruna-workloads"
Import-Module -Name $validationModulePath
Import-Module -Name $resourcesModulePath
Import-Module -Name $componentsModulePath
Import-Module -Name $workloadsModulePath

$InformationPreference = "Continue"

if ([string]::IsNullOrEmpty($project_root)) { $project_root = Get-Location; }
$config_root = Join-Path -Path $project_root -ChildPath "config/$config_subfolder"

switch -Exact ($operation)
{
    'validate' { Confirm-Configuration $project_root $config_root | out-null }
    'resources' { Deploy-Resources $project_root $config_root | out-null }
    'components' { Deploy-Components $project_root $config_root | out-null }
    'workloads' { Deploy-Workloads $project_root $config_root | out-null }
    Default {
        Write-Output "yuruna validate [project_root] [config_subfolder]`n    Validate configuration files.";
        Write-Output "yuruna resources [project_root] [config_subfolder]`n    Deploys resources using Terraform as helper.";
        Write-Output "yuruna components [project_root] [config_subfolder]`n    Build and push components to registry.";
        Write-Output "yuruna workloads [project_root] [config_subfolder]`n    Deploy workloads using Helm as helper.";
    }
}

Write-Output "Done!"