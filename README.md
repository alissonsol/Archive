# yuruna

yuruna template project

## Instructions

- Check [requirements](docs/requirements.md).
- Search and replace 'yuruna' with your domain name across the entire project before starting.
- Login/Connect to Azure (should be needed just once from PowerShell session).
  - `az login --use-device-code`
  - If needed: show available subscriptions and set default
    - `az account list -o table`
    - `az account set --subscription xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx`
    - Show current subscription
      - `az account show --query "{name:name, isDefault:isDefault, id:id, user:user.name}" -o tsv`
  - Instructions from now on assume execution from the PowerShell prompt connected to the Azure account.
- Resources
  - Instructions on using Terraform to create the [cloud resources](docs/terraform.md) (Kubernetes cluster, databases, etc.).
  - Create [Public IP](docs/create-public-ip.md) and bind DNS entry.
- Code
  - Follow guide to execute scripts that [build](docs/build.md) and deploy container images.
- Ingress
  - Follow the instructions to [create the ingress](docs/create-ingress.md) resources in the Kubernetes cluster.
- Certificates
  - Use the [cert-manager](docs/cert-manager.md) to automatically get a Let's Encrypt certificate.
- Questions? Check the [FAQ](docs/faq.md) document.

Copyright (c) 2020 by Alisson Sol
