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
- Clusters: {yrn42peerkeys001}, {yrn42peerkeys002}, {yrn42peerkeys002}

As output, the following values will become available for later steps:

- ${env:registryName}.registryLocation
- ${context.name}.clusterIp
- ${context.name}.frontendIp
- ${context.name}.hostname

## Components

- A Docker container image for a .NET C# website.
- A Docker container image for a key-value storage API.

## Workloads

- The frontend/website will be deployed to each cluster.
- The key-value storage API contianer will be deployed to each cluster.

## Instructions

- Follow the instructions to create resources, build components and deploy the workloads.
- Connect to one of the frontends. Check your configuration for service endpoint and port (example: `http://localhost:9001`).
  - Test by setting a key/value and retrieving different key-value pairs.
  - Note: you may need to follow one of these instructions if being redirected to https
    - [How to Stop Chrome from Automatically Redirecting to https](https://howchoo.com/chrome/stop-chrome-from-automatically-redirecting-https)
    - [Safari keeps forcing HTTPS on localhost](https://stackoverflow.com/questions/46394682/safari-keeps-forcing-https-on-localhost)
    - [Exclude localhost from Chrome/Chromium Browsers forced HTTPS redirection](https://medium.com/@hmheng/exclude-localhost-from-chrome-chromium-browsers-forced-https-redirection-642c8befa9b)

## Cloud deployment instructions

These steps need be executed just once, unless you modify configurations.

- Confirm [requirements](../../../docs/requirements.md)
  - The PowerShell scripts do not verify that requirements are met.
- [Authenticate](../../../docs/authenticate.md) with your cloud provider
  - Instructions from now on assume execution from a PowerShell prompt connected to the cloud account.

Back to main [readme](../../../README.md). Back to list of [examples](../README.md).
