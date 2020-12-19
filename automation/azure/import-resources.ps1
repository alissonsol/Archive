# Azure-specific: import/update cloud resources (yuruna)
$git_root=git rev-parse --show-toplevel

$modulePath = Join-Path -Path $git_root -ChildPath "automation/confirm-configuration"
Import-Module -Name $modulePath

$targetConfiguration = "azure"
$deploymentPath = Join-Path -Path $git_root -ChildPath "deployment/$targetConfiguration"
if (-Not (Test-Path -Path $deploymentPath)) { Write-Output "Deployment path not found: $deploymentPath"; Exit -1 }

$deployment = Confirm-Deployment

# Change below if different from defaults
$namespace = $deployment.namespace
$resourceGroup = $namespace

# Save original context
$originalContext = kubectl config current-context

Push-Location $deploymentPath
$registryLocation = terraform output "registryLocation"
$registryLocation = $registryLocation.Replace("`"","")
Pop-Location
try {
    $registryUri = [System.UriBuilder]::new("https://$registryLocation")
    $registryHost = $registryUri.Host
    $null = Resolve-DNSName -name $registryHost -ErrorAction Stop
}
catch { Write-Output "terraform output: registryLocation not valid: $registryLocation"; Exit -1; }

$registryParts = $registryHost.Split(".")
$registryName = $registryParts[0]
Write-Output "Registry location: $registryLocation"

# Azure version - Retrieve registry credential
$dockerUsername = az acr credential show -n $registryName --query username
$dockerPassword = az acr credential show -n $registryName --query passwords[0].value
Write-Output "Docker username: $dockerUsername"

# Find target configuration
# Set Terraform variables
foreach ($configuration in $deployment.configuration) {
    $configurationName = $configuration['name']
    if ($configurationName -eq $targetConfiguration) { break; }
}
if ($configurationName -ne $targetConfiguration) { Write-Output "Configuration '$targetConfiguration' not found in deployment file"; Exit -1; }

# Import cluster and set contextName
$contextName = $configuration['clusterName']
if ([string]::IsNullOrEmpty($contextName)) { $contextName = $deployment.globalVars.clusterName; }
Write-Output "Importing $contextName"
az aks get-credentials --resource-group $resourceGroup --name $contextName

# Create registry-credential
kubectl config use-context $contextName
kubectl create namespace $namespace
kubectl config set-context --current --namespace=$namespace
kubectl delete secret registry-credential
kubectl create secret docker-registry registry-credential --docker-server=https://$registryLocation --docker-username=$dockerUsername --docker-password=$dockerPassword

# Back to original context
kubectl config use-context $originalContext

# Persist new workloads information
$workloads = Confirm-WorkloadList
$workloads.kustomization."registryLocation" = $registryLocation
$workloadsFile = Join-Path -Path $git_root -ChildPath "config/workloads.yml"
$workloadsText = ConvertTo-Yaml $workloads
Remove-Item -Path $workloadsFile
Set-Content -Path $workloadsFile -Value $workloadsText

Exit 0