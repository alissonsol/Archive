# TO DO

## Global

- Creation of multiple clusters passing different variables to Terraform.
- Should be possible to move the entire "infrastructure" step to a Helm chart.
- Better PowerShell scripts (likely eternal goal!).
- Diagram: Pptx vs PDF
- Seek for TODO tag
- Use verbs as per [Approved Verbs for PowerShell Commands](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.1)

## AWS

- Fix issue with Windows (/bin/sh) when executing `terraform apply` [Works for macOS]
  - <https://github.com/terraform-aws-modules/terraform-aws-eks/issues/757>
- Terraform
  - Create+output registry
  - Standard names
- import-clusters: get created registry crendentials
- Cluster IP?
  - <https://docs.aws.amazon.com/vpc/latest/userguide/vpc-ip-addressing.html#vpc-public-ipv4-addresses>
  - public_subnet_map_public_ip_on_launch

## Azure

- Global improvements

## GCP

- Global improvements
- Fix the cluster.min_master_version: creating with v1.19+ failed
  - Consequence: hack to deploy the ingress, since today it depends on v1.19+ syntax
- IP load balancer not working.

Back to main [readme](../README.md)
