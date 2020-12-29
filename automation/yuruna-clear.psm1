# yuruna-clear module

$yuruna_root = $PSScriptRoot
$modulePath = Join-Path -Path $yuruna_root -ChildPath "import-yaml"
Import-Module -Name $modulePath

function Clear-Configuration {
    param (
        $project_root,
        $config_root
    )

    if (!(Confirm-ResourceList $project_root $config_root)) { return $false; }
    # $executionFolder = Join-Path -Path $project_root -ChildPath ".yuruna"
    # Remove-Item -Path $executionFolder -Force -Recurse -ErrorAction "SilentlyContinue"

    Write-Output "Clear-Configuration not yet implemented" -InformationAction Stop; Exit -1;

    return $true;
}

Export-ModuleMember -Function * -Alias *