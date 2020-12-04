# GCP-specific: Docker container registry show (yuruna)
$git_root=git rev-parse --show-toplevel

$current_project_id=$(gcloud config get-value project)
Write-Output "Current project id: $current_project_id"
$current_project_number = gcloud projects list --filter="$current_project_id" --format="value(PROJECT_NUMBER)"
Write-Output "Project number: $current_project_number"

Write-Output "Access policy"
gcloud projects get-iam-policy $current_project_id --flatten="bindings[].members" --format='table(bindings.role)' --filter="bindings.members:service-$current_project_number@containerregistry.iam.gserviceaccount.com"

$gcpAccessKeyFile = Join-Path -Path $git_root -ChildPath "config/gcp-access-key.json"
if (-Not (Test-Path -Path $gcpAccessKeyFile)) { Write-Output "GCP access key file not found: $gcpAccessKeyFile"; Exit -1 }
$dockerPassword = ((Get-Content $gcpAccessKeyFile) -join '').Replace("""", "\""") 
if ($dockerPassword -clike 'Placeholder*') { Write-Output "Please see authentication instructions to replace the placeholder file: $gcpAccessKeyFile"; }