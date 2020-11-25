# Azure-specific: deploy resources using Terraform (yuruna)
# Configure files in ../deployment/azure

Push-Location "$PSScriptRoot/../deployment/azure"

terraform init
terraform apply -auto-approve

Pop-Location
Exit 0