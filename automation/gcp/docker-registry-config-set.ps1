# GCP-specific: Docker container registry setup (yuruna)
$git_root=git rev-parse --show-toplevel

$gcpAccessKeyFile = Join-Path -Path $git_root -ChildPath "config/gcp-access-key.json"
if (-Not (Test-Path -Path $gcpAccessKeyFile)) { Write-Output "GCP access key file not found: $gcpAccessKeyFile"; Exit -1 }
$dockerPassword = ((Get-Content $gcpAccessKeyFile) -join '').Replace("""", "\""") 
if ($dockerPassword -clike 'Placeholder*') { Write-Output "Please see authentication instructions to replace the placeholder file: $gcpAccessKeyFile"; Exit -1 }
git update-index --assume-unchanged $gcpAccessKeyFile

gcloud auth login
gcloud auth configure-docker
gcloud components install docker-credential-gcr
