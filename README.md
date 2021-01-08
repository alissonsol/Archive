# yuruna

Cross-cloud Kubernetes-based applications.

It is provided "as is" without guarantees. See [license](LICENSE.md). Always check for the [latest version](https://bit.ly/asol-yrn) and read the [updates](docs/updates.md) file.

## Requirements and cloud-specific steps

These steps need be executed just once, unless you modify configurations.

- Confirm [requirements](docs/requirements.md)
  - The PowerShell scripts do not verify that requirements are met.
- [Authenticate](docs/authenticate.md) with your cloud provider
  - Instructions from now on assume execution from a PowerShell prompt connected to the cloud account.

## Using Yuruna to deploy Kubernetes-based applications to multiple clouds

Include the `automation` folder in the path. Then deploy resources, build components, and install workloads. See project [examples](projects/examples/README.md) and check the [syntax](docs/yuruna.md) documentation for more details.

Below are the end-to-end steps to deploy the `website` example to `localhost` (assuming Docker is installed and Kubernetes enabled). Execution below is from the `automation` folder.

- Create resources: a Kubernetes cluster

```shell
./yuruna.ps1 resources ../projects/examples/website localhost
```

- Build the components: a simple C# website application

```shell
./yuruna.ps1 components ../projects/examples/website localhost
```

- Deploy the  workloads: deploy the website to the cluster, with certificates and NGINX ingress

```shell
./yuruna.ps1 workloads ../projects/examples/website localhost
```

- Done! On to the next goal!
  - If not in use, remember to [clean up](docs/cleanup.md) the resources.

## Notes

- Creating cloud resources and not deleting them may result in a growing bill even if the clusters aren't used.
  - You should [clean up](docs/cleanup.md) if those won't be in use.
- Instructions assume that only one cloud will be used at a time. See the [hacks](docs/hacks.md) document.
- There are known improvements [to do](docs/todo.md) in this template project.
- Read more in the list of [references](docs/references.md).
- Questions? Check the [FAQ](docs/faq.md) document.

Copyright (c) 2020-2021 by Alisson Sol
