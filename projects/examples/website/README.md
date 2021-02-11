# Website project

A simple .NET C# website container deployed to a Kubernetes cluster.

## Search and replace

What to search and replace in order to reuse this project as the basis for a new one. Search in case-sensitive mode.

- yrn42website-prefix -> Common project prefix for containers. Example: abcd
- yrn42website-namespace -> Kubernetes namespace for installing containers. Example: abcd
- yrn42website-dns -> DNS prefix. Example: abcd
- yrn42website-resource-group -> Name for group of resources (Azure). Example: abcd
- yrn42website-tags -> Resource tags (Cloud, if template uses it). Example: abcd
- yrn42website-domain -> Domain for web email, site, Example: abcd.com
- yrn42website-ip-name -> Name for the public IP address. Example: abcd
- yrn42website-cluster-name -> Name for the K8S cluster (or at least a common prefix). Example: abcd
- yrn42website-sitename -> Name for site in the UX (This will be visible to end users). Example: Abcd

Despite the several placeholders enabling reuse in different configurations, it is recommended to replace as many valuables as possible to become identical, easing future maintenance. Replace `yrn42website-domain` first and then use this regular expression to search and replace the others:  `(yrn42website)[A-Za-z0-9\-]*`

Before deploying to the cloud environments, seek for `TO-SET` and set the required values. See section "Cloud deployment instructions".

## End to end deployment

Below are the end-to-end steps to deploy the `website` project to `localhost` (assuming Docker is installed and Kubernetes enabled). Execution below is from the `automation` folder. You may need to start PowerShell (`pwsh`).

- Create resources

```shell
./yuruna.ps1 resources ../projects/examples/website localhost
```

- Build the components

```shell
./yuruna.ps1 components ../projects/examples/website localhost
```

- Deploy the  workloads

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
- [cert-manager](https://cert-manager.io/docs/), a certificate management controller. It will get a Let’s [Encrypt](https://letsencrypt.org/) certificate for the frontend website, unless it if configured as `localhost` (in that case, a [`mkcert`](https://github.com/FiloSottile/mkcert) certificate is used). Installed using a [Helm chart](https://cert-manager.io/docs/installation/kubernetes/#installing-with-helm).

## Workloads

- The frontend/website will be deployed to the cluster.
- NGINX controller will be deployed to the cluster redirecting ports to the website.
- Cert-manager will be deployed to the cluster, getting a certificate for the frontend "site".

## Cloud deployment instructions

- Edit the files under `projects/examples/config/azure/` and set the `registryName` to a unique name (search for `TO-SET`). Azure requires a globally unique registry name. Ping `yourname.azurecr.io` and confirm that name is not already in use. This should just be the name (like `yuruna`). Azure automatically adds the domain (`azurecr.io`). Set the same across all the files.
  - The current value is intentionally left empty so that validation will point out the need to edit the files.
- Afterwards, execute the same commands above, replacing `localhost` with `azure`.
- Before executing `./yuruna.ps1 workloads` please confirm that the `$site` DNS entry (example: www.yuruna.com) already points to the `$frontendIpAddress`. Without that, the `cert-manager` component cannot automatically perform the challenge process to get the TLS certificate.
- After resource creation, you will get the Terraform output with the `frontendIpAddress`. From the configuration interface for your DNS provider, point the `site` to that IP address.
  - Another option to test is: `curl -v http://$frontendIpAddress -H 'Host: $site'`.
    - Replace the values with those from the `resources.yml` and the `resources.output.yml` files.
  - Yet another option: add an entry to your `hosts` folder pointing `$site` to `$frontendIpAddress`. Don't forget to remove it!

Back to main [readme](../../../README.md). Back to list of [examples](../README.md).
