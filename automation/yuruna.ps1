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

if ([string]::IsNullOrEmpty($project_root)) { $project_root = Get-Location; }
$config_root = Join-Path -Path $project_root -ChildPath "config/$config_subfolder"
$project_root = Resolve-Path -Path $project_root -ErrorAction "SilentlyContinue" 
$config_root = Resolve-Path -Path $config_root -ErrorAction "SilentlyContinue"

$transcriptFileName = [System.IO.Path]::GetTempFileName()
$null = Start-Transcript $transcriptFileName
$DebugPreference = "Continue"
$InformationPreference = "Continue"
$VerbosePreference = "Continue"
$result = $false
switch -Exact ($operation)
{
    'clear' { $result = Clear-Configuration $project_root }
    'validate' { $result = Confirm-Configuration $project_root $config_root }
    'resources' { $result = Publish-ResourceList $project_root $config_root }
    'components' { $result = Publish-ComponentList $project_root $config_root }
    'workloads' { $result = Publish-WorkloadList $project_root $config_root }
    Default {
        Write-Output "yuruna clear [project_root]`n    Clear intermediate execution files.";
        Write-Output "yuruna validate [project_root] [config_subfolder]`n    Validate configuration files.";
        Write-Output "yuruna resources [project_root] [config_subfolder]`n    Deploys resources using Terraform as helper.";
        Write-Output "yuruna components [project_root] [config_subfolder]`n    Build and push components to registry.";
        Write-Output "yuruna workloads [project_root] [config_subfolder]`n    Deploy workloads using Helm as helper.";
    }
}

$null = Stop-Transcript
if (-Not $result) { Write-Output $(Get-Content -Path $transcriptFileName) }
