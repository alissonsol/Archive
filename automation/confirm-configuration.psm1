# Module that retrieves and validates Yaml from configuration files
$git_root=git rev-parse --show-toplevel

$modulePath = Join-Path -Path $git_root -ChildPath "automation/import-yaml"
Import-Module -Name $modulePath

function Confirm-Deployment {

    $deploymentFile = Join-Path -Path $git_root -ChildPath "config/deployment.yml"
    if (-Not (Test-Path -Path $deploymentFile)) { Write-Output "Deployment file not found: $deploymentFile"; exit -1 }
    $yaml = ConvertFrom-File $deploymentFile

    # Validate namespace
    $namespace = $yaml.namespace
    if ([string]::IsNullOrEmpty($namespace)) { Write-Output "namespace cannot be null or empty in file: $deploymentFile"; Exit -1; }

    # Validate configurations
    foreach ($configuration in $yaml.configuration) {
        $configurationName = $configuration['name']
        foreach ($key in $configuration.Keys)
        {
            $value = $configuration[$key]
            if ([string]::IsNullOrEmpty($value)) { Write-Output "deployment.configuration[$configurationName][$key] cannot be null or empty in file: $deploymentFile"; Exit -1; }
        }
    }

    # Return the object
    return $yaml
}

function Confirm-Workloads {

    $workloadsFile = Join-Path -Path $git_root -ChildPath "config/workloads.yml"
    if (-Not (Test-Path -Path $workloadsFile)) { Write-Output "K8S workloads file not found: $workloadsFile"; exit -1 }
    $yaml = ConvertFrom-File $workloadsFile

    # Write-Host "Validating namespace"
    $namespace = $yaml.namespace
    if ([string]::IsNullOrEmpty($namespace)) { Write-Output "namespace cannot be null or empty in file: $workloadsFile"; Exit -1; }

    $configPath = Join-Path -Path $git_root -ChildPath "config"
    foreach ($context in $yaml.context) {
        $contextName = $context.name
        # Write-Host "Validating context section: $contextName"
        if ([string]::IsNullOrEmpty($contextName)) { Write-Output "context.name cannot be null or empty in file: $workloadsFile"; Exit -1; }
        $originalContext = kubectl config current-context
        kubectl config use-context $contextName | out-null
        $currentContext = kubectl config current-context
        kubectl config use-context $originalContext | out-null
        if ($currentContext -ne $contextName) { Write-Output "K8S context not found: $contextName`nFile: $workloadsFile"; Exit -1 }

        $contextComponents = $context.components
        if ([string]::IsNullOrEmpty($contextComponents)) { Write-Output "context.components cannot be null or empty in file: $workloadsFile"; Exit -1; }
        $contextComponentsFile = Join-Path -Path $configPath -ChildPath $contextComponents
        if (-Not (Test-Path -Path $contextComponentsFile)) { Write-Output "context.components file not found: $contextComponentsFile`nFile: $workloadsFile"; Exit -1; }
    }

    # Write-Host "Validate frontend section"
    $frontendContext = $yaml.frontend.context
    if ([string]::IsNullOrEmpty($frontendContext)) { Write-Output "frontend.context cannot be empty or null in file: $workloadsFile"; Exit -1; }

    $frontendSite = $yaml.frontend.site
    try {
        $frontendSiteUri = [System.UriBuilder]::new("https://$frontendSite")
        $frontendSiteHost = $frontendSiteUri.Host
        $null = Resolve-DNSName -name $frontendSiteHost -ErrorAction Stop
        $frontendIpAddress = [System.Net.Dns]::GetHostAddresses($frontendSiteHost).IPAddressToString
        Write-Verbose "Public ingress '$frontendSite' resolved to '$frontendIpAddress'"
    }
    catch { Write-Verbose "frontend.site not valid: $frontendSite`nFile: $workloadsFile"; }

    $frontendIpAddress = $yaml.frontend.ipAddress
    if (-Not ($frontendIpAddress -as [System.Net.IPAddress])) { Write-Output "frontend.ipAddress not valid: $frontendIpAddress`nFile: $workloadsFile"; Exit -1 }

    $frontendIpName = $yaml.frontend.ipName
    if ([string]::IsNullOrEmpty($frontendIpName)) { Write-Output "frontend.ipName cannot be empty or null in file: $workloadsFile"; Exit -1; }

    $certManagerIssuerEmail = $yaml.frontend.certManagerIssuerEmail
    try {
        $null = [mailaddress]$certManagerIssuerEmail
    }
    catch { Write-Output "frontend.certManagerIssuerEmail not valid: $certManagerIssuerEmail`nFile: $workloadsFile"; Exit -1; }

    # Write-Host "Validate kustomization section"
    $containerPrefix = $yaml.kustomization.containerPrefix
    if ([string]::IsNullOrEmpty($containerPrefix)) { Write-Output "kustomization.containerPrefix cannot be empty or null in file: $workloadsFile"; Exit -1; }

    $registryLocation = $yaml.kustomization.registryLocation
    try {
        $registryUri = [System.UriBuilder]::new("https://$registryLocation")
        $registryHost = $registryUri.Host
        $null = Resolve-DNSName -name $registryHost -ErrorAction Stop
    }
    catch { Write-Output "kustomization.registryLocation not valid: $registryLocation`nFile: $workloadsFile"; Exit -1; }

    # Return the object
    return $yaml
}

Export-ModuleMember -Function * -Alias *