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

- Project resources description.

As output, the following values will become available for later steps:

- Project resources output description.

## Components

- Project components description.

## Workloads

- Project workloads description.

## Cloud deployment instructions

### DNS

- Before executing `./yuruna.ps1 workloads` please confirm that the `yrn42peerkeys-domain` DNS entry (example: www.yuruna.com) already points to the `frontendIp`.
  - Without that, the `cert-manager` cannot perform the [challenge process](https://letsencrypt.org/docs/challenge-types/#http-01-challenge) to get the TLS certificate.
  - After resource creation, you will get the Terraform output with the `frontendIp`. From the configuration interface for your DNS provider, point the `yrn42peerkeys-domain` to that IP address.
    - Another option to test is: `curl -v http://{frontendIp} -H 'Host: {yrn42peerkeys-domain}'`.
    - Yet another option: add an entry to your `hosts` folder pointing `yrn42peerkeys-domain` to the resulting value for`frontendIp`. Don't forget to remove it!

### Azure

- Search for `TO-SET`
  - Azure requires a globally unique registry name.
    - Ping `yourname.azurecr.io` and confirm that name is not already in use.
    - Set the value just to the unique host name, like `yrn42peerkeys` (not `yrn42peerkeys.azurecr.io`).
  - The current value is intentionally left empty so that validation will point out the need to edit the files.
- Afterwards, execute the same commands above, replacing `localhost` with `azure`.

Back to main [readme](../../../README.md). Back to list of [examples](../README.md).
