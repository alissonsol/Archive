# Set development environment variables (yuruna)
$git_root=git rev-parse --show-toplevel

$modulePath = Join-Path -Path $git_root -ChildPath "automation/confirm-configuration"
Import-Module -Name $modulePath

$targetConfiguration = 'localhost'
$deployment = Confirm-Deployment
$workloads = Confirm-Workloads

# Set Docker registry environment variable (and authenticate, if needed)
$registryLocation = $workloads.kustomization.registryLocation
$registryUri = [System.UriBuilder]::new("https://$registryLocation")
$registryHost = $registryUri.Host
Write-Output "Registry host: $registryHost"

# Set Terraform variables
foreach ($configuration in $deployment.configuration) {
    $configurationName = $configuration['name']
    if ($configurationName -eq $targetConfiguration) { break; }
}
if ($configurationName -ne $targetConfiguration) { Write-Output "Configuration '$targetConfiguration' not found in deployment file"; Exit -1; }
foreach ($key in $configuration.Keys) {
    $value = $configuration[$key]
    Set-Item -Path Env:TF_$key -Value $value
}

$registryParts = $registryHost.Split(".")
$registryName = $registryParts[0]
$registryDomain = $registryParts[1]
Set-Item -Path Env:DOCKER_REGISTRY -Value $registryLocation
if ($registryDomain -eq "azurecr") {
    az acr login -n $registryName
}

Write-Output "`nDone. Showing environment below."
Get-ChildItem env:

Exit 0