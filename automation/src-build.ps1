# Build container images (yuruna)
# Configure files in ../config/

Push-Location "$PSScriptRoot/../src"

$containerPrefix = Get-Content ../config/container-prefix -First 1

Get-Content ../config/services-list | ForEach-Object {
    $firstLetter = $_.substring(0, 1)

    if ($firstLetter -ne "#") {
        Write-Output "`n===="

        $splitFile = $_ -split "/"
        $levels = $splitFile.Count
        $scope = $splitFile[0]
        $project = $splitFile[$levels-1]
        $path = "$scope/$project/Dockerfile"

        Write-Output $path
        if (Test-Path -Path $path) {
            if ([string]::IsNullOrEmpty($args[0])) {
                docker build --rm -f $path -t "$($containerPrefix)/$($project):latest" "$scope/$project/"
            }
            else {
                docker build --rm -f $path -t "$($containerPrefix)/$($project):latest" "$scope/$project/" --build-arg "DEV=$($args[0])"
            }
        }
    }
}

Pop-Location
Exit 0