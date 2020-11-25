# Azure-specific: import/update cluster credentials (yuruna)
# Create registry credential for each cluster to pull from registry
# Configure files in ../config/

Import-Module -Name "$PSScriptRoot/import-yaml"

Push-Location $PSScriptRoot

$originalContext = kubectl config current-context
Write-Output "`nStart processing from original context: $originalContext"

$yml = import-yaml "../config/k8s-context-list.yml"
$registryHost = Get-Content ../config/registry-host -First 1
$registryParts = $registryHost.Split(".")
$registryName = $registryParts[0]
# Assumption: cluster resource group will always be thee same as deployment namespace
$resourceGroup = $yml.k8s.namespace
$deployNamespace = $yml.k8s.namespace
Write-Output "Registry host: $registryHost"
$Username = az acr credential show -n $registryName --query username
$Password = az acr credential show -n $registryName --query passwords[0].value
Write-Output "Username: $Username"

foreach ($context in $yml.context) {
    $contextName = $context.name

    Write-Host "Importing $contextName"
    az aks get-credentials --resource-group $resourceGroup --name $contextName
    kubectl config use-context $contextName
    kubectl create namespace $deployNamespace
    kubectl config set-context --current --namespace=$deployNamespace
    kubectl create secret docker-registry registry-credential --docker-server=https://$registryHost  --docker-username=$Username --docker-password=$Password
}

Write-Output "`nBack to original context"
kubectl config use-context $originalContext

Pop-Location
Exit 0