# GCP-specific: import/update cluster credentials (yuruna)
$git_root=git rev-parse --show-toplevel

$modulePath = Join-Path -Path $git_root -ChildPath "automation/confirm-configuration"
Import-Module -Name $modulePath

$targetConfiguration = "gcp"
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

# GCP version - Retrieve registry credential
$gcpAccessKeyFile = Join-Path -Path $git_root -ChildPath "config/gcp-access-key.json"
if (-Not (Test-Path -Path $gcpAccessKeyFile)) { Write-Output "GCP access key file not found: $gcpAccessKeyFile"; Exit -1 }
$dockerUsername = "_json_key"
$dockerPassword = ((Get-Content $gcpAccessKeyFile) -join '').Replace("""", "\""") 
if ($dockerPassword -clike 'Placeholder*') { Write-Output "Please see authentication instructions to replace the placeholder file: $gcpAccessKeyFile"; Exit -1 }
git update-index --assume-unchanged $gcpAccessKeyFile
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
Write-Output "Importing $contextName"
$contextDescription = gcloud compute project-info describe --project $contextName
$contextYaml = ConvertFrom-Content $contextDescription
$items =$contextYaml.commonInstanceMetadata.items
$keyName = "google-compute-default-region"
$clusterRegion = Find-KeyValue $items $keyName
Write-Output "Importing $contextName at $clusterRegion"
gcloud container clusters get-credentials $contextName --region $clusterRegion
$createdContextName = kubectl config current-context
kubectl config delete-context $contextName
kubectl config rename-context $createdContextName $contextName

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
$workloads.kustomization.registryLocation = $registryLocation
$workloadsFile = Join-Path -Path $git_root -ChildPath "config/workloads.yml"
$workloadsText = ConvertTo-Yaml $workloads
Remove-Item -Path $workloadsFile
Set-Content -Path $workloadsFile -Value $workloadsText

Exit 0