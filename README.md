# yuruna

A cross-cloud Kubernetes-based application skeleton.

It is provided "as is" without guarantees. See [license](LICENSE.md). Always check for the [latest version](https://bit.ly/asol-yrn).

## Cloud-specific steps

These steps need be executed just once, unless you modify configurations. Steps 3 and 4 are not needed if using Docker Desktop in the `localhost`.

1. Search and replace 'yuruna' with your domain name across the entire project before starting
2. Check [requirements](docs/requirements.md)
   - There is an extra script to run if using Kubernetes locally (it starts a local container registry).
3. [Authenticate](docs/authenticate.md) with your cloud provider
   - Instructions from now on assume execution from a PowerShell prompt connected to the cloud account.
4. Create cloud resources
   - Instructions on using Terraform to create the [cloud resources](docs/terraform.md) (Kubernetes cluster, databases, etc.).
   - Create [Public IP](docs/create-public-ip.md) addresses and bind DNS entries.
   - From now on, scripts are just executing standard `helm` and `kubectl` commands, independently of the cloud being used!

## Step using the Kubernetes infrastructure

1. Build and push container images to registry
   - Follow the [build](docs/build.md) guide.
2. Deploy infrastructure components
   - Follow the instructions to deploy [infrastructure](docs/infrastructure.md) resources: certification issuer, ingress controller, etc.
3. Deploy the services and configuration
   - Follow [instructions](docs/deploy-workloads.md) to deploy lists of Kubernetes services to clusters in an easily configurable way.
4. Done! On to the next goal!
   - If not in use, remember to [clean up](docs/cleanup.md) the resources.

## Notes

- Creating cloud resources and not deleting them may result in a growing bill even if the clusters aren't used.
  - You should [clean up](docs/cleanup.md) if those won't be in use.
- Instructions assume that only one cloud will be used at a time. See the [hacks](docs/hacks.md) document.
- There are known improvements [to do](docs/todo.md) in this template project.
- Read more in the list of [references](docs/references.md).
- Questions? Check the [FAQ](docs/faq.md) document.

Copyright (c) 2020 by Alisson Sol
