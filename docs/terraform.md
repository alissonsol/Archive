# Terraform Guidance

## Azure resources

This is based on the article [Provision an AKS Cluster (Azure)](https://learn.hashicorp.com/tutorials/terraform/aks). Assumes terraform is [downloaded](https://www.terraform.io/downloads.html) and installed. Check you have the latest version with `terraform version`.

Configure the variables in `terraform.tfvars`.

Then, execute script from the folder `automation`

```shell
azure-deploy-resources.ps1
```

Attention: the registry name should be globally unique. Changing it requires changes to these files:

- `terraform.tfvars`
- `config/registry-host`
- Yaml deployment files under `deployment` folder

### Configure kubectl

Use the following script to import the cluster credentials into `[user]/.kube/config`. The script will also create the `registry-credential` for each imported cluster.

```shell
azure-import-clusters.ps1
```

Back to main [readme](../README.md)

### Cleaning up (if ever needed)

If needed, resources can be deleted by executing commands below from folder `deployment/azure`.

```shell
terraform destroy -auto-approve
```

Don't forget to delete the cluster from `[user]/.kube/config`. That can be easily done using the [Visual Studio Code](https://code.visualstudio.com/) extension for [Kubernetes](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools).

Back to main [readme](../README.md)
