# Requirements

These instructions assume that you have a registered domain and know how to create/edit DNS records in your registrar.

## Required tools

- Installed [Docker Desktop](https://docs.docker.com/desktop/)
- Installed [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Installed version of [Visual Studio Code](https://code.visualstudio.com/)
  - Installed [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) extension.
  - Installed extension for [Kubernetes](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools).
- Installed [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell)
- Installed [Helm](https://helm.sh/docs/intro/install/) in the path.
- Installed [Terraform](https://www.terraform.io/downloads.html) in the path.

### Development environment

- Instructions developed and tested with
  - Operating systems
    - Windows 10 Professional.
      - `ver`
      - `Microsoft Windows [Version 10.0.19042.630]`
    - macOs - Big Sur
      - `sw_vers`
      - `ProductVersion: 11.0.1`
      - `BuildVersion: 20B29`
      - Installed tools with [Homebrew](https://brew.sh)
        - `brew cask install docker`
        - `brew update && brew install azure-cli`
        - `brew cask install powershell`
        - `brew install helm`
        - `brew install terraform`
  - Tools
    - Docker Desktop
      - `docker version`
      - `Engine: Version: 19.03.13`
    - Azure CLI
      - `az version`
      - `"azure-cli": "2.15.1"`
    - Visual Studio Code
      - About: `1.51.1 (system setup)`
    - PowerShell 7 (x64)
      - `$PSVersionTable`
      - `PSVersion                      7.1.0`
    - Helm
      - `helm version`
      - `version.BuildInfo{Version:"v3.1.1"...`
    - Terraform
      - `terraform version`
      - `Terraform v0.13.5`  

Back to main [readme](../README.md)
