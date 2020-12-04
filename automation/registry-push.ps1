# Docker-generic: tag and push all services to the registry (yuruna)
$git_root=git rev-parse --show-toplevel

$modulePath = Join-Path -Path $git_root -ChildPath "automation/confirm-configuration"
Import-Module -Name $modulePath

$workloads = Confirm-Workloads

$containerPrefix = $workloads.kustomization.containerPrefix
$configPath = Join-Path -Path $git_root -ChildPath "config"
$srcPath = Join-Path -Path $git_root -ChildPath "src"

$registryLocation = $workloads.kustomization.registryLocation
try {
    $registryUri = [System.UriBuilder]::new("https://$registryLocation")
    $registryHost = $registryUri.Host
    $null = Resolve-DNSName -name $registryHost -ErrorAction Stop
}
catch { Write-Output "kustomization.registryLocation not valid: $registryLocation"; Exit -1; }

# Registry "login"
$registryParts = $registryHost.Split(".")
$registryName = $registryParts[0]
$registryDomain = $registryParts[1]
Set-Item -Path Env:DOCKER_REGISTRY -Value $registryLocation
if ($registryDomain -eq "azurecr") {
    az acr login -n $registryName
}
if ($registryHost -clike "gcr.io*") {
    # GCP version - Retrieve registry credential
    $gcpAccessKeyFile = Join-Path -Path $git_root -ChildPath "config/gcp-access-key.json"
    if (-Not (Test-Path -Path $gcpAccessKeyFile)) { Write-Output "GCP access key file not found: $gcpAccessKeyFile"; Exit -1 }
    $dockerUsername = "_json_key"
    $dockerPassword = ((Get-Content $gcpAccessKeyFile) -join '').Replace("""", "\""")
    Write-Output "Docker username: $dockerUsername"
    if ($dockerPassword -clike 'Placeholder*') { Write-Output "Please see authentication instructions to replace the placeholder file: $gcpAccessKeyFile"; Exit -1 }
    git update-index --assume-unchanged $gcpAccessKeyFile

    Get-Content $gcpAccessKeyFile | docker login --username $dockerUsername --password-stdin https://$registryHost

    gcloud auth login
    gcloud auth configure-docker
    gcloud components install docker-credential-gcr
}

foreach ($context in $workloads.context) {
    $contextComponents = $context.components
    $contextComponentsFile = Join-Path -Path $configPath -ChildPath $contextComponents
    if (-Not (Test-Path -Path $contextComponentsFile)) { Write-Output "context.components file not found: $contextComponentsFile"; Exit -1; }

    Get-Content $contextComponentsFile | ForEach-Object {
        $firstLetter = $_.substring(0, 1)

        if ($firstLetter -ne "#") {
            $splitFile = $_ -split "/"
            $levels = $splitFile.Count
            $scope = $splitFile[0]
            $project = $splitFile[$levels-1]
            $dockerBuildPath = Join-Path -Path $srcPath -ChildPath "$scope/$project"
            $dockerfile = Join-Path -Path $dockerBuildPath -ChildPath "Dockerfile"

            if (Test-Path -Path $dockerfile) {
                Write-Output  "`n====`n${registryLocation}/${containerPrefix}/${project}:latest"

                docker tag "${containerPrefix}/${project}:latest" "${registryLocation}/${containerPrefix}/${project}:latest"
                docker push "${registryLocation}/${containerPrefix}/${project}:latest"
            }
            else {
                Write-Output "`n====`nSkipping: $_"
            }
        }
    }
}

Exit 0