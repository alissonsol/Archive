# yuruna-requirements module

$yuruna_root = $PSScriptRoot
$modulePath = Join-Path -Path $yuruna_root -ChildPath "import-yaml"
Import-Module -Name $modulePath

function Confirm-Requirements {

    Write-Output "Confirm-Requirements not yet implemented" -InformationAction Stop; Exit -1;

    return $true;
}

Export-ModuleMember -Function * -Alias *