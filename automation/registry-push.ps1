# Docker-specific: tag and push all services to the registry (yuruna)
# Configure files in ../config

Push-Location $PSScriptRoot

$containerPrefix = Get-Content ../config/container-prefix -First 1
$targetRegistry = $env:DOCKER_REGISTRY

Write-Output "Sending containers to $targetRegistry"

Get-Content ../config/services-list | ForEach-Object {
    $firstLetter = $_.substring(0, 1)

    if ($firstLetter -ne "#") {
        Write-Output "`n===="

        $splitFile = $_ -split "/"
        $levels = $splitFile.Count
        $project = $splitFile[$levels-1]

        docker tag "$($containerPrefix)/$($project):latest" "$($targetRegistry)/$($containerPrefix)/$($project):latest"
        docker push "$($targetRegistry)/$($containerPrefix)/$($project):latest"
    }
}

Pop-Location
Exit 0