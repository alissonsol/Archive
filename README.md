# `yuruna`

A developer toolset for cross-cloud Kubernetes-based applications.

It is provided "as is" without guarantees. See [license](LICENSE.md). Always check for the [latest version](https://bit.ly/asol-yrn) and read the [updates](docs/updates.md) file.

## Requirements and cloud-specific steps

These steps need be executed just once, unless you modify configurations.

- Confirm [requirements](docs/requirements.md)
  - The PowerShell scripts do not verify that requirements are met.
- [Authenticate](docs/authenticate.md) with your cloud provider
  - Instructions assume execution from a PowerShell prompt connected to the cloud account.
  - Depending on your cloud, login mechanism and activity, the authentication may timeout and need to be repeated.
- *Windows Warning*: Examples using Linux-based containers may not work if scripts have the wrong line termination when building locally.
  - The recommendation is to set `git config --global core.autocrlf input` before `git clone`.

## Using `yuruna` to deploy Kubernetes-based applications

Include the `automation` folder in the path. Then deploy resources, build components, and install workloads.

```shell
yuruna.ps1 resources  [project_root] [config_subfolder]
yuruna.ps1 components [project_root] [config_subfolder]
yuruna.ps1 workloads  [project_root] [config_subfolder]
```

Deploying the [peerkeys](projects/examples/peerkeys/README.md) example to the localhost.

```shell
yuruna.ps1 resources  projects/examples/peerkeys localhost
yuruna.ps1 components projects/examples/peerkeys localhost
yuruna.ps1 workloads  projects/examples/peerkeys localhost
```

Deploying the [website](projects/examples/website/README.md) example to Azure, showing debug and verbose messages.

```shell
yuruna.ps1 resources  projects/examples/website azure -debug_mode $true -verbose_mode $true
yuruna.ps1 components projects/examples/website azure -debug_mode $true -verbose_mode $true
yuruna.ps1 workloads  projects/examples/website azure -debug_mode $true -verbose_mode $true
```

See project [examples](projects/examples/README.md) and check the [syntax](docs/syntax.md) documentation for more details.

## Notes

- Creating cloud resources and not deleting them may result in a growing bill even if the clusters aren't used.
  - You should [clean up](docs/cleanup.md) resources if those won't be in use.
- Questions? Check the [FAQ](docs/faq.md) document, the list of [to do](docs/todo.md) tasks, [hacks](docs/hacks.md), and additional [references](docs/references.md).
- Thanks to all users and [contributors](docs/contributors.md)

Copyright (c) 2020-2021 by Alisson Sol et al.
