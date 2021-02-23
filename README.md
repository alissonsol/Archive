# yuruna

A developer toolset for cross-cloud Kubernetes-based applications.

It is provided "as is" without guarantees. See [license](LICENSE.md). Always check for the [latest version](https://bit.ly/asol-yrn) and read the [updates](docs/updates.md) file.

## Requirements and cloud-specific steps

These steps need be executed just once, unless you modify configurations.

- Confirm [requirements](docs/requirements.md)
  - The PowerShell scripts do not verify that requirements are met.
- [Authenticate](docs/authenticate.md) with your cloud provider
  - Instructions from now on assume execution from a PowerShell prompt connected to the cloud account.
  - Depending on your cloud, login mechanism and activity, the authentication may timeout and need to be repeated.
  - *Windows Warning*: Example using Linux-based containers may not work if scripts have the wrong line termination.
    - The recommendation is to set `git config --global core.autocrlf input` before `git clone`.

## Using Yuruna to deploy Kubernetes-based applications to multiple clouds

Include the `automation` folder in the path. Then deploy resources, build components, and install workloads.

See project [examples](projects/examples/README.md) and check the [syntax](docs/syntax.md) documentation for more details.

## Notes

- Creating cloud resources and not deleting them may result in a growing bill even if the clusters aren't used.
  - You should [clean up](docs/cleanup.md) resources if those won't be in use.
- There are known improvements [to do](docs/todo.md) in the roadmap for implementation.
- See the [hacks](docs/hacks.md) document for some workaround and shortcuts that may need to be understood.
- Read more in the list of [references](docs/references.md).
- Questions? Check the [FAQ](docs/faq.md) document.
- Thanks to all users and [contributors](docs/contributors.md)

Copyright (c) 2020-2021 by Alisson Sol et al.
