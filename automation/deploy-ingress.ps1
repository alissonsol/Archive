# K8S-generic: Deploy ingress (yuruna)
$git_root=git rev-parse --show-toplevel

$modulePath = Join-Path -Path $git_root -ChildPath "automation/confirm-configuration"
Import-Module -Name $modulePath

$workloads = Confirm-Workloads

$namespace = $workloads.namespace
$frontendContext = $workloads.frontend.context
$frontendIpAddress = $workloads.frontend.ipAddress
$frontendIpName = $yaml.frontend.ipName

# Save original context
$originalContext = kubectl config current-context

# Change below if different from defaults
Write-Output "`n==== Deploying ingress to '$frontendContext'"
kubectl config use-context $frontendContext
$currentContext = kubectl config current-context
if ($currentContext -ne $frontendContext) { Write-Output "K8S context not found: $frontendContext"; Exit -1 }
kubectl cluster-info --request-timeout "1s"
$existingNamespace = kubectl get namespace $namespace
if ([string]::IsNullOrEmpty($existingNamespace)) {
    kubectl create namespace $namespace
}
kubectl config set-context --current --namespace=$namespace

Write-Output "Ingress Public IP: $frontendIpAddress"
# Deployment commands
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm uninstall nginx-ingress
helm install nginx-ingress ingress-nginx/ingress-nginx `
    --namespace $namespace `
    --set controller.replicaCount=2 `
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux `
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux `
    --set controller.service.loadBalancerIP="$frontendIpAddress" `
    --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-dns-label-name"="$frontendIpName" `
    --set controller.service.annotations."kubernetes\.io/ingress\.global-static-ip-name"="$frontendIpName"

# Back to original context
kubectl config use-context $originalContext

Exit 0