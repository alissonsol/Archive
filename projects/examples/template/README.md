# `yuruna` template project

Folder structure template project.

## Search and replace

Reuse this project by search and replacing placeholders in case-sensitive mode.

- yrn42template-prefix -> Common project prefix for containers. Example: yrn42
- yrn42template-ns -> Kubernetes namespace for installing containers. Example: yrn42
- yrn42template-dns -> DNS prefix. Example: yrn42
- yrn42template-rg -> Name for group of resources (Azure). Example: yrn42
- yrn42template-tags -> Resource tags. Example: yrn42
- yrn42template-domain -> Domain for web email, site. Example: yrn42.com
- yrn42template-host -> Host name. Example: www.yrn42.com
- yrn42template-cluster -> Name for the K8S cluster (or at least a common prefix). Example: yrn42
- yrn42template-uxname -> Name for site in the UX (This will be visible to end users). Example: yrn42

Despite the several placeholders enabling reuse in different configurations, it is recommended to replace as many valuables as possible to become identical, easing future maintenance. Replace `yrn42template-domain` first and then use this regular expression to search and replace the others:  `(yrn42template)[A-Za-z0-9\-]*`

Before deploying to the cloud environments, seek for `TO-SET` and set the required values. See section "Cloud deployment instructions".

## End to end deployment

Below are the end-to-end steps to deploy the `template` project to `localhost` (assuming Docker is installed and Kubernetes enabled). The execution below is from the `automation` folder. You may need to start PowerShell (`pwsh`).

- Create resources

```shell
./yuruna.ps1 resources ../projects/examples/yrn42template localhost
```

- Build the components

```shell
./yuruna.ps1 components ../projects/examples/yrn42template localhost
```

- Deploy the  workloads

```shell
./yuruna.ps1 workloads ../projects/examples/yrn42template localhost
```

## Resources

Terraform will be used to create the following resources:

- Project resources description.

As output, the following values will become available for later steps:

- Project resources output description.

## Components

- Project components description.

## Workloads

- Project workloads description.

## Cloud deployment instructions

### DNS

- Before executing `./yuruna.ps1 workloads` please confirm that the `yrn42template-domain` DNS entry (example: www.yrn42.com) already points to the `frontendIp`.
  - Without that, the `cert-manager` cannot perform the [challenge process](https://letsencrypt.org/docs/challenge-types/#http-01-challenge) to get the TLS certificate.
  - After resource creation, you will get the Terraform output with the `frontendIp`. From the configuration interface for your DNS provider, point the `yrn42template-domain` to that IP address.
    - Another option to test is: `curl -v http://{frontendIp} -H 'Host: {yrn42template-domain}'`.
    - Yet another option: add an entry to your `hosts` folder pointing `yrn42template-domain` to the resulting value for`frontendIp`. Don't forget to remove it!

### Azure

- Search for `TO-SET`
  - Azure requires a globally unique registry name.
    - Ping `yourname.azurecr.io` and confirm that name is not already in use.
    - Set the value just to the unique host name, like `yrn42template` (not `yrn42template.azurecr.io`).
- Afterward, execute the same commands above, replacing `localhost` with `azure`.

Back to main [readme](../../../README.md). Back to list of [examples](../README.md).
