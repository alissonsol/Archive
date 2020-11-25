# Azure-specific: create public IP address (yuruna)
# Configure files in ../config/

Push-Location $PSScriptRoot

# Change below if different form defaults
$containerPrefix = Get-Content ../config/container-prefix -First 1
$resourceGroup = $containerPrefix
$clusterName =  $containerPrefix
$publicIPName = $containerPrefix

$networkResourceGroup = az aks show --resource-group $resourceGroup --name $clusterName --query nodeResourceGroup -o tsv
Write-Output "Network resource group: $networkResourceGroup"

$publicIP = az network public-ip create --resource-group $networkResourceGroup --name $publicIPName --sku Standard --allocation-method static --query publicIp.ipAddress -o tsv
Write-Output "Public IP: $publicIP"

Pop-Location
Exit 0