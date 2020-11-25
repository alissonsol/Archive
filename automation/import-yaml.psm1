# import-yaml function that will read YML file and deserialize it
function import-yaml {
    param (
        $FileName
    )

    if (-Not (Get-Module -ListAvailable -Name powershell-yaml)) {
        Write-Output "Need to install powershell-yaml using:`nInstall-Module -Name powershell-yaml"
        Pop-Location
        Exit -1
    }

	# Load file content to a string array containing all YML file lines
    [string[]]$fileContent = Get-Content $FileName
    $content = ''
    # Convert a string array to a string
    foreach ($line in $fileContent) { $content = $content + "`n" + $line }
    # Deserialize a string to the PowerShell object
    $yml = ConvertFrom-YAML $content
    # return the object
    Write-Output $yml
}

Export-ModuleMember -Function import-yaml