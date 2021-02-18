# yuruna-requirements module

$yuruna_root = Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath "..")
$modulePath = Join-Path -Path $yuruna_root -ChildPath "automation/import-yaml"
Import-Module -Name $modulePath

function Confirm-RequirementList {

    Write-Output "Confirm-RequirementList not yet implemented" -InformationAction Stop; Exit -1;

    return $true;
}

Export-ModuleMember -Function * -Alias *
