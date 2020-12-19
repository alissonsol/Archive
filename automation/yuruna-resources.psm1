# yuruna-resources module

$yuruna_root = $PSScriptRoot
$validationModulePath = Join-Path -Path $yuruna_root -ChildPath "yuruna-validation"
Import-Module -Name $validationModulePath

function Deploy-Resources {
    param (
        $project_root,
        $config_root
    )

    if (!(Confirm-Resources $project_root $config_root)) { return $false; }
    Write-Debug "---- Deploying Resources"
    # For each resource in resources.yml
    #   copy template to work folder under .yuruna
    #   apply variables from resources.yml
    #   execute terraform apply from work folder
    #     creates local .terraform under work folder, which can be used later in terraform destroy

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
            $templateFolder = Resolve-Path -Path (Join-Path -Path $project_root -ChildPath "resources/$resourceTemplate")
            if (-Not (Test-Path -Path $templateFolder)) { Write-Information "Resources template folder not found: $templateFolder`nUsed in file: $resourcesFile"; return $false; }
            # copy template to work folder under .yuruna
            $workFolder = Resolve-Path -Path (Join-Path -Path $project_root -ChildPath ".yuruna/resources/$resourceTemplate")
            New-Item -ItemType Directory -Force -Path $workFolder -ErrorAction SilentlyContinue
            Copy-Item "$templateFolder/*" -Destination $workFolder -Recurse -ErrorAction SilentlyContinue

            $terraformVarsFile = Join-Path -Path $workFolder -ChildPath "terraform.tfvars"
            New-Item -Path $terraformVarsFile -ItemType File -Force
            $terraformVars = @{}
            if (-Not ($null -eq  $yaml.globalVariables)) {
                foreach ($key in $yaml.globalVariables.Keys) {
                    $value = $yaml.globalVariables[$key]
                    $terraformVars[$key] = $value
                }
            }
            if (-Not ($null -eq  $resource.variables)) {
                foreach ($key in $resource.variables.Keys) {
                    $value = $resource.variables[$key]
                    $terraformVars[$key] = $value
                }
            }
            foreach ($key in $terraformVars.Keys) {
                $value = $terraformVars[$key]
                $line = "$key = `"$value`""
                Add-Content -Path $terraformVarsFile -Value $line
            }
            # execute terraform apply from work folder
            Push-Location $workFolder
            $result = terraform init
            Write-Debug "Terraform init: $result"
            $result = terraform plan -compact-warnings
            Write-Debug "Terraform plan: $result"
            $result = terraform graph | dot -Tsvg > graph.svg
            Write-Debug "Terraform graph: $result"
            Write-Information "Executing terraform apply from $workFolder"
            $result = terraform apply -auto-approve
            Write-Debug "Terraform apply: $result"
            Pop-Location
        }
    }

    return $true;
}

Export-ModuleMember -Function * -Alias *