# Docker-generic: Build container images (yuruna)
$git_root=git rev-parse --show-toplevel

$modulePath = Join-Path -Path $git_root -ChildPath "automation/confirm-configuration"
Import-Module -Name $modulePath

$workloads = Confirm-Workloads

$containerPrefix = $workloads.kustomization.containerPrefix
$configPath = Join-Path -Path $git_root -ChildPath "config"
$srcPath = Join-Path -Path $git_root -ChildPath "src"
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
                Write-Output  "`n====`n$dockerfile"
                if ([string]::IsNullOrEmpty($args[0])) {
                    docker build --rm -f $dockerfile -t "${containerPrefix}/${project}:latest" "$dockerBuildPath"
                }
                else {
                    docker build --rm -f $dockerfile -t "${containerPrefix}/${project}:latest" "$dockerBuildPath" --build-arg "DEV=$($args[0])"
                }
            }
            else {
                Write-Output "`n====`nDockerfile not found: $dockerfile. Skipping build for this service."
            }
        }
    }
}

Exit 0