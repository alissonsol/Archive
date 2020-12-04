# K8S-generic: deploy workloads to clusters (yuruna)
$git_root=git rev-parse --show-toplevel

$modulePath = Join-Path -Path $git_root -ChildPath "automation/confirm-configuration"
Import-Module -Name $modulePath

$workloads = Confirm-Workloads
$namespace = $workloads.namespace

$workloadsFile = Join-Path -Path $git_root -ChildPath "config/workloads.yml"
$helmPath = Join-Path -Path $git_root -ChildPath "deployment/helm"

# Save original context
$originalContext = kubectl config current-context

foreach ($context in $workloads.context) {
    $contextName = $context.name
    $contextChart = $context.chart

    # Switch context
    kubectl config use-context $contextName
    $currentContext = kubectl config current-context
    if ($currentContext -ne $contextName) { Write-Output "K8S context not found: $contextName"; Exit -1 }
    $existingNamespace = kubectl get namespace $namespace
    if ([string]::IsNullOrEmpty($existingNamespace)) {
        kubectl create namespace $namespace
    }
    kubectl config set-context --current --namespace=$namespace

    # Copy workloads.yml over values.yaml
    $chartPath = Join-Path -Path $helmPath -ChildPath  $contextChart
    $valuesFile = Join-Path -Path $chartPath -ChildPath "values.yaml"
    Copy-Item -Path $workloadsFile -Destination $valuesFile -Force

    Write-Output "`n==== Deploying chart '$contextChart' to context '$contextName'"
    Push-Location $chartPath
    helm lint
    helm install $contextChart .
    Pop-Location   
}


# Back to original context
kubectl config use-context $originalContext

Exit 0