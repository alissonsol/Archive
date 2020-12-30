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
    Write-Debug "---- Destroying Resources"

    $resourcesFile = Join-Path -Path $config_root -ChildPath "resources.yml"
    if (-Not (Test-Path -Path $resourcesFile)) { Write-Information "File not found: $resourcesFile"; return $false; }
    $yaml = ConvertFrom-File $resourcesFile

    # For each resource in resources.yml
    if ($null -eq $yaml.resources) { Write-Information "resources cannot be null or empty in file: $resourcesFile"; return $false; }
    foreach ($resource in $yaml.resources) {
        $resourceName = $resource['name']
        $resourceTemplate = $resource['template']
        Write-Debug "resource: $resourceName - template: $resourceTemplate"
        if ([string]::IsNullOrEmpty($resourceName)) { Write-Information "resource without name in file: $resourcesFile"; return $false; }
        # resource template can be empty: just naming already existing resource
        if (![string]::IsNullOrEmpty($resourceTemplate)) {
            # go to work folder under .yuruna
            $workFolder = Join-Path -Path $project_root -ChildPath ".yuruna/resources/$resourceTemplate"
            $workFolder = Resolve-Path -Path $workFolder

            # execute terraform destroy from work folder
            Push-Location $workFolder
            Write-Information "Executing terraform destroy from $workFolder"
            $result = terraform destroy -auto-approve -refresh=false
            Write-Debug "Terraform destroy: $result"
            Pop-Location
            Remove-Item -Path $workFolder -Force -Recurse -ErrorAction "SilentlyContinue"
        }
    }

    return $true;
}

Export-ModuleMember -Function * -Alias *