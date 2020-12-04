# Azure-specific: create public IP address (yuruna)
$git_root=git rev-parse --show-toplevel

$modulePath = Join-Path -Path $git_root -ChildPath "automation/confirm-configuration"
Import-Module -Name $modulePath

$workloads = Confirm-Workloads

# Change below if different from defaults
$namespace = $workloads.namespace
$resourceGroup = $namespace
$frontendIpName = $workloads.frontend.ipName
$clusterName = $namespace

$networkResourceGroup = az aks show --resource-group $resourceGroup --name $clusterName --query nodeResourceGroup -o tsv
Write-Output "Network resource group: $networkResourceGroup"

$frontendIpAddress = az network public-ip create --resource-group $networkResourceGroup --name $frontendIpName --sku Standard --allocation-method static --query publicIp.ipAddress -o tsv
Write-Output "Frontend IP: $frontendIpAddress"

# Persist new workloads information
$workloads.frontend.ipAddress = $frontendIpAddress
$workloadsFile = Join-Path -Path $git_root -ChildPath "config/workloads.yml"
$workloadsText = ConvertTo-Yaml $workloads
Remove-Item -Path $workloadsFile
Set-Content -Path $workloadsFile -Value $workloadsText

Exit 0