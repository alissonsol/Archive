# Azure-specific: deploy resources using Terraform (yuruna)
$git_root=git rev-parse --show-toplevel

$targetConfiguration = $args[0]
if ([string]::IsNullOrEmpty($targetConfiguration)) { Write-Output "Enter configuration name. Example:`ndeploy-resources azure"; Exit -1; }

# Validate deployment path
$deploymentPath = Join-Path -Path $git_root -ChildPath "deployment/$targetConfiguration"
if (-Not (Test-Path -Path $deploymentPath)) { Write-Output "Deployment path not found: $deploymentPath"; Exit -1 }

$modulePath = Join-Path -Path $git_root -ChildPath "automation/confirm-configuration"
Import-Module -Name $modulePath

$deployment = Confirm-Deployment

# Set Terraform variables
$globalVars = $deployment.globalVars
foreach ($key in $globalVars.Keys) {
    $value = $globalVars[$key]
    Set-Item -Path Env:TF_VAR_$key -Value $value
    Write-Output "Env:TF_VAR_$key = $(Get-Content -Path Env:TF_VAR_$key)"
}
foreach ($configuration in $deployment.configuration) {
    $configurationName = $configuration['name']
    if ($configurationName -eq $targetConfiguration) { break; }
}
if ($configurationName -ne $targetConfiguration) { Write-Output "Configuration '$targetConfiguration' not found in deployment file"; Exit -1; }
foreach ($key in $configuration.Keys) {
    $value = $configuration[$key]
    Set-Item -Path Env:TF_VAR_$key -Value $value
    Write-Output "Env:TF_VAR_$key = $(Get-Content -Path Env:TF_VAR_$key)"
}

# Terraform execution
Write-Output "Deployment path: $deploymentPath"
Push-Location $deploymentPath
terraform init
# terraform plan -compact-warnings
terraform apply -auto-approve
Pop-Location

Exit 0