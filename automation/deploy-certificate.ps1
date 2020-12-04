# K8S-generic: Deploy certificate (yuruna)
$git_root=git rev-parse --show-toplevel

$modulePath = Join-Path -Path $git_root -ChildPath "automation/confirm-configuration"
Import-Module -Name $modulePath

function Switch-IngressContext {

    $workloads = Confirm-Workloads
    $namespace = $workloads.namespace
    $ingressContext = $workloads.frontend.context

    # Change below if different from defaults
    kubectl config use-context $ingressContext
    $currentContext = kubectl config current-context
    if ($currentContext -ne $ingressContext) { Write-Output "K8S ingress context not found: $ingressContext"; Exit -1 }
    $existingNamespace = kubectl get namespace $namespace
    if ([string]::IsNullOrEmpty($existingNamespace)) {
        kubectl create namespace $namespace
    }
    kubectl config set-context --current --namespace=$namespace
}

function Add-CertManager {
    Write-Output "Adding certificate manager"

    # Deployment commands
    kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.1.0/cert-manager.yaml
}

function Add-LocalhostCertificate {
    Write-Output "Adding local certificate"

    # Deployment commands
    $certificatePath = Join-Path $git_root -ChildPath "config/certificate"
    New-Item -ItemType Directory -Force -Path $certificatePath
    git update-index --assume-unchanged "$certificatePath/"
    $tlsSecretName = "website-kubernetes-tls"

    Push-Location $certificatePath
    mkcert -install
    mkcert -key-file tls.key -cert-file tls.crt yuruna.com "*.yuruna.com" yuruna.test localhost 127.0.0.1 ::1
    kubectl delete secret $tlsSecretName
    kubectl create secret tls $tlsSecretName --key tls.key --cert tls.crt
    Pop-Location
}

# Main code
$workloads = Confirm-Workloads

$frontendSite = $workloads.frontend.site

# Save original context
$originalContext = kubectl config current-context
Switch-IngressContext

# Always add the certificate manager, even if local, so it is available for deployment
Add-CertManager
if ($frontendSite -eq "localhost") {
    Add-LocalhostCertificate
}

# Back to original context
kubectl config use-context $originalContext

Exit 0