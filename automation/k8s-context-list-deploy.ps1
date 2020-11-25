# K8S: deploy services to clusters (yuruna)
# Configure files in ../config/

Import-Module -Name "$PSScriptRoot/import-yaml"

Push-Location $PSScriptRoot

$originalContext = kubectl config current-context
Write-Output "`nStart processing from original context: $originalContext"

$yml = import-yaml "../config/k8s-context-list.yml"
$deployNamespace = $yml.k8s.namespace

Push-Location "../deployment"
Write-Output "Deploying to namespace: $deployNamespace"
foreach ($context in $yml.context) {
    $servicesToDeploy = $context.services
    $contextName = $context.name
    Write-Output "`nDeploying '$servicesToDeploy' to '$contextName'"
    kubectl config use-context $contextName
    kubectl cluster-info --request-timeout "1s"
    kubectl config set-context --current --namespace=$deployNamespace

    $servicesFile = "../config/$servicesToDeploy"
    if (Test-Path -Path $servicesFile) {
        Get-Content $servicesFile | ForEach-Object {
            $firstLetter = $_.substring(0, 1)
        
            if ($firstLetter -ne "#") {
                Write-Output "`n===="
        
                $splitFile = $_ -split "/"
                $levels = $splitFile.Count
                $scope = $splitFile[0]
                $project = $splitFile[$levels-1]
                $path = "$scope/$project"
        
                Write-Output $path
                Push-Location "../deployment"
                if (Test-Path -Path $path) {
                    kubectl delete -f $path
                    kubectl apply -f $path
                }
                else {
                    Write-Output "ERROR: deployment path '$path not found (relative to current folder)"
                    Exit 1            
                }
                Pop-Location
            }
        }    
    }
    else {
        Write-Output "ERROR: configuration file '$servicesFile' not found (relative to current folder)"
        Exit 1
    }
}
Pop-Location

Write-Output "`nBack to original context"
kubectl config use-context $originalContext

Pop-Location
Exit 0