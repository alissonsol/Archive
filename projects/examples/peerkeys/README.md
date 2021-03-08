# peerkeys project

Replication of key-value pairs across clusters.

## Search and replace

What to search and replace in order to reuse this project as the basis for a new one. Search in case-sensitive mode.

- yrn42peerkeys-prefix -> Common project prefix for containers. Example: abcd
- yrn42peerkeys-ns -> Kubernetes namespace for installing containers. Example: abcd
- yrn42peerkeys-dns -> DNS prefix. Example: abcd
- yrn42peerkeys-rg -> Name for group of resources (Azure). Example: abcd
- yrn42peerkeys-tags -> Resource tags. Example: abcd
- yrn42peerkeys-domain -> Domain for web email, site, Example: abcd.com
- yrn42peerkeys-host -> Host name. Example: www.abcd.com
- yrn42peerkeys-cluster -> Name for the K8S cluster (or at least a common prefix). Example: abcd
- yrn42peerkeys-uxname -> Name for site in the UX (This will be visible to end users). Example: Abcd

Despite the several placeholders enabling reuse in different configurations, it is recommended to replace as many valuables as possible to become identical, easing future maintenance. Replace `yrn42peerkeys-domain` first and then use this regular expression to search and replace the others:  `(yrn42peerkeys)[A-Za-z0-9\-]*`

Before deploying to the cloud environments, seek for `TO-SET` and set the required values. See section "Cloud deployment instructions".

## End to end deployment

Below are the end-to-end steps to deploy the `peerkeys` project to `localhost` (assuming Docker is installed and Kubernetes enabled). Execution below is from the `automation` folder. You may need to start PowerShell (`pwsh`).

- Create resources

```shell
./yuruna.ps1 resources ../projects/examples/peerkeys localhost
```

- Build the components

```shell
./yuruna.ps1 components ../projects/examples/peerkeys localhost
```

- Deploy the  workloads

```shell
./yuruna.ps1 workloads ../projects/examples/peerkeys localhost
```

## Resources

Terraform will be used to create the following resources:

- Registry: {componentsRegistry}
- Clusters: {yrn42peerkeys001}, {yrn42peerkeys002}, {yrn42peerkeys003}

As output, the following values will become available for later steps:

- ${env:registryName}.registryLocation
- ${context.name}.clusterIp
- ${context.name}.frontendIp
- ${context.name}.hostname

## Components

- A Docker container image for a .NET C# website.
- A Docker container image for a key-value storage API.
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx)
- Azure Kubernetes Service (AKS) [HTTP application routing](https://docs.microsoft.com/en-us/azure/aks/http-application-routing)

## Workloads

- The frontend/website will be deployed to each cluster.
- The key-value storage API contianer will be deployed to each cluster.
- Ingress controller and redirect rules deployed (once only in localhost).

## Cloud deployment instructions

These steps need be executed just once, unless you modify configurations.

- Confirm [requirements](../../../docs/requirements.md)
  - The PowerShell scripts do not verify that requirements are met.
- [Authenticate](../../../docs/authenticate.md) with your cloud provider
  - Instructions assume execution from a PowerShell prompt connected to the cloud account.

After authentication, deploy to Azure using the following sequence.

```shell
./yuruna.ps1 resources ../projects/examples/peerkeys azure
./yuruna.ps1 components ../projects/examples/peerkeys azure
./yuruna.ps1 workloads ../projects/examples/peerkeys azure
```

Endpoints are exposed during the workloads deployment.

## Notes

Peerkeys exemplifies frontend, backend, and K8S "composing".

The example automates the steps to deploy components and expose services, as explained in the MSDN article [Up and Running with Azure Kubernetes Services](https://docs.microsoft.com/en-us/archive/msdn-magazine/2018/december/containers-up-and-running-with-azure-kubernetes-services). In a cloud deployment, each cluster gets the ingress, which will expose the frontend site and the backend API in different endpoints, mapping to the internal service (via HTTP, port 80).

<img src="peerkeys-cloud.png" alt="peerkeys in the cloud" width="640"/>

In the localhost, running all the components in the same cluster creates a collision for the ingress rules. That is solved by using a different "pathBase" for each instance. That results in a problem to enable the services to all operate from the same code, as explained in the blog post [.NET Core hosted on subdirectories in Nginx](https://www.billbogaiv.com/posts/net-core-hosted-on-subdirectories-in-nginx). The solution described there is used, and the single ingress controller maps to each of the internal container via the rules deployed to each namespace.

<img src="peerkeys-localhost.png" alt="peerkeys in the cloud" width="640"/>

## Instructions

- Follow the instructions to create resources, build components and deploy the workloads.
- Connect to one of the frontends.

Back to main [readme](../../../README.md). Back to list of [examples](../README.md).
