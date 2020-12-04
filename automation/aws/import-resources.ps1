# AWS-specific: import/update cluster credentials (yuruna)
$git_root=git rev-parse --show-toplevel

$modulePath = Join-Path -Path $git_root -ChildPath "automation/import-yaml"
Import-Module -Name $modulePath

# Save original context
$originalContext = kubectl config current-context

$registryParts = $registryHost.Split(".")
$registryName = $registryParts[0]
$deployNamespace = $yaml.k8s.namespace
Write-Output "Registry location: $registryLocation"

# TODO: AWS version - Retrieve registry credential
$Username = az acr credential show -n $registryName --query username
$Password = az acr credential show -n $registryName --query passwords[0].value
Write-Output "Username: $Username"

foreach ($context in $yaml.context) {
    $contextName = $context.name

    # Import and set contextName
    Write-Output "Importing $contextName"
    aws eks update-kubeconfig --name $contextName
    $createdContextName = kubectl config current-context
    kubectl config rename-context $createdContextName $contextName

    # Create registry-credential
    kubectl config use-context $contextName
    kubectl create namespace $deployNamespace
    kubectl config set-context --current --namespace=$deployNamespace
    kubectl create secret docker-registry registry-credential --docker-server=https://$registryLocation --docker-username=$Username --docker-password=$Password
}

# Back to original context
kubectl config use-context $originalContext

Exit 0