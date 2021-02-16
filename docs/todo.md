# TO DO

## Global

### P0, P1

- Seek for TODO tag.
  - peerkeys: ClusterIP for exposed services not the frontendIp or clusterIp
  - onnx: final step for workloads (helper)
- Implement `yuruna requirements` that tests for requirements.
- Tags in resources

### P1

- Better PowerShell scripts (likely eternal goal!).
  - Consider check behavior like that of the [GitHub actions](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions), appending to each command: `if ((Test-Path -LiteralPath variable:\LASTEXITCODE)) { exit $LASTEXITCODE }`
- Warn if .terraform already exists: may not create resources.
- Rolling PowerShell environment in the workloads steps (or document this: create single .ps1 file and execute it instead!)
- Finish testing and publish the resources for AWS and GCP

### P2

- For resources created using terraform `local-exec`: destry when doing `terraform destroy`
- Create Visual Studio Code extension to start projects, run commands, etc.
  - Visual Studio Code: [Your First Extension](https://code.visualstudio.com/api/get-started/your-first-extension)
- Graph from YML: Python [graphviz 0.15](https://pypi.org/project/graphviz/)

### P3+

- Confirm use only of [Approved Verbs for PowerShell Commands](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.1)
- Non-repro or hard to repro issues
  - Cert-manager: workloads in Azure
    - DEBUG: helm install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.1.0 --set installCRDs=true --set nodeSelector."beta\.kubernetes\.io/os"=linux --debug
  - install.go:172: [debug] Original chart version: "v1.1.0"
    - Error: read tcp dev-machine-IP:62410->130.211.96.40(charts.jetstack.io):443: wsarecv: An existing connection was forcibly closed by the remote host.
    - helm.go:81: [debug] read tcp dev-machine-IP:62410->130.211.96.40(charts.jetstack.io):443: wsarecv: An existing connection was forcibly closed by the remote host.
  - NGINX: workloads in Azure: 2nd time+: Error: cannot re-use a name that is still in use
  - Error: Internal error occurred: failed calling webhook "webhook.cert-manager.io": Post "https://cert-manager-webhook.cert-manager.svc:443/mutate?timeout=10s": dial tcp 10 x.y.z:443: connect: connection refused

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
