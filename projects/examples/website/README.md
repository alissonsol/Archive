# Website example

A simple .NET C# website container deployed to a Kubernetes cluster.

## End to end deployment

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

## Resources

Terraform will be used to create the following resources:

- A Kubernetes cluster
- A container registry
- A public IP address

As output, the following values will become available for later steps:

- registryLocation
- frontendIpAddress

## Components

- A Docker container image for a .NET C# website.
- NGINX Ingress Controller, which will be installed using a [Helm chart](https://kubernetes.github.io/ingress-nginx/deploy/#using-helm).
- [cert-manager](https://cert-manager.io/docs/), a certificate management controller. It will get a Let’s [Encrypt](https://letsencrypt.org/) certificate for the frontend website. Installed using a [Helm chart](https://cert-manager.io/docs/installation/kubernetes/#installing-with-helm).

## Workloads

- The frontend/website will be deployed to the cluster.
- NGINX controller will be deployed to the cluster redirecting ports to the website.
- Cert-manager will be deployed to the cluster, getting a certificate for the frontend "site".

Back to main [readme](../../README.md)
