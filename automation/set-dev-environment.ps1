# Set development environment variables (yuruna)
# Configure files in ../config

Push-Location $PSScriptRoot

if ($LASTEXITCODE -ne 0) {
    Pop-Location
    exit $env:ERRORLEVEL
}

Write-Output "`nBack to define other environment settings"

$registryHost = Get-Content ../config/registry-host -First 1
$registryParts = $registryHost.Split(".")
$registryName = $registryParts[0]
$registryDomain = $registryParts[1]

Write-Output "Registry host: $registryHost"
Write-Output "Registry name: $registryName"
Write-Output "Registry domain: $registryDomain"

Set-Item -Path Env:DOCKER_REGISTRY -Value $registryHost

if ($registryDomain -eq "azurecr") {
    az acr login -n $registryName
}

Write-Output "`nDone. Showing environment below."
Get-ChildItem env:

Pop-Location
Exit 0