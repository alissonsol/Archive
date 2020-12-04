# Cleanup resources

These steps are intentionally not automated to make mistakes harder. **Follow the instructions carefully**. Make sure you are in the correct folder.

## Cleaning up automatically

If needed, resources can be deleted by executing the command below from the folder with the initial deployment files (`deployment/aws`, `deployment/azure`, etc.).

```shell
terraform destroy -auto-approve -refresh=false
```

This process will ask for the variable names. Enter anything (the values are not used, due to the `-refresh=false` parameter). It provides yet another opportunity to abort the process of destroying the resources.

In some cases, that command doesn't find the resources to destroy (`0 destroyed`). It needs the originally created `.terraform` folder to still be available. In that case, instructions for cleaning manually are below.

Don't forget to delete the cluster context from `[user]/.kube/config`. That can be easily done using the [Visual Studio Code](https://code.visualstudio.com/) extension for [Kubernetes](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools). It can also be done from the command line with [kubectl](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-em-delete-context-em-).

## Manually cleaning up AWS resources

- From the [AWS Management Console](https://console.aws.amazon.com/eks/home#/clusters), delete the EKS clusters.

## Manually cleaning up Azure resources

- From the [Azure Portal](https://portal.azure.com), delete the "Azure Resource Groups" that have been created. Deleting the resource groups will delete all associated resources.
  - There will be a global resource containing the registry, containers and any other direclty created resources.
  - For each Kubernetes cluster, there will be a corresponding AKS node resource group (see [AKS faq](https://docs.microsoft.com/en-us/azure/aks/faq)). Those are named with the suffix "_nrg".

## Manually cleaning up GCP resources

- From the [GCP Console](https://console.cloud.google.com/), delete any resources that were previous created.

Back to main [readme](../README.md)
