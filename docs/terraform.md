# Creating cloud resources using Terraform

Examples based on articles on how to [Manage Kubernetes with Terraform](https://learn.hashicorp.com/collections/terraform/kubernetes).

If making changes to the Terraform files, it is recommended to verify the plan with the command `terraform plan`.

## Creating resources

In the instructions below, `[cloud]` should be replaced by `aws`, `azure` or `gcp`, depending on your cloud provider. Folders are relative to the to Git root folder.

Configure deployment variables in the file `config/deployment.yml`.

The first PowerShell script uses Terraform to create the a Docker registry, a Kubernetes cluster, and any other related resources (worker nodes, VPC, etc.). Execute the script below from the folder `automation`.

```shell
deploy-resources.ps1 [cloud]
```

If there is a timeout while running this script then you can safely rerun it.

The second script imports Kubernetes cluster credentials into `[user]/.kube/config`. It also creates a `registry-credential` secret for each imported cluster (so it can [pull images from the a private registry](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)). Execute the script below from the folder `automation/[cloud]`.

```shell
import-resources.ps1
```

Back to main [readme](../README.md)
