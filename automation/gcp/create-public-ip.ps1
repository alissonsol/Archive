# GCP-specific: create public IP address (yuruna)
$git_root=git rev-parse --show-toplevel

$modulePath = Join-Path -Path $git_root -ChildPath "automation/confirm-configuration"
Import-Module -Name $modulePath

$workloads = Confirm-WorkloadList

# Change below if different from defaults
$frontendIpName = $workloads.frontend.ipName

gcloud compute addresses create $frontendIpName --global
$yaml = ConvertFrom-Content $(gcloud compute addresses describe $frontendIpName --global)
$frontendIpAddress = $yaml.address

# Persist new workloads information
$workloads.frontend.ipAddress = $frontendIpAddress
$workloadsFile = Join-Path -Path $git_root -ChildPath "config/workloads.yml"
$workloadsText = ConvertTo-Yaml $workloads
Remove-Item -Path $workloadsFile
Set-Content -Path $workloadsFile -Value $workloadsText

Exit 0