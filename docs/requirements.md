# Requirements

These instructions assume that you have a registered domain and know how to create/edit DNS records in your registrar.

Ahead of installing certificates in the localhost, it is recommended to run `mkcert -install` once to create the local certificate authority. That may demand elevation.

## Required tools

- You obviously need [Git](https://git-scm.com/downloads)
  - `git config --global user.name "Your Name"`
  - `git config --global user.email "Your@email.address"`
- Using a Hyper-V machine in Windows? Enable [nested virtualization](https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/user-guide/nested-virtualization)
- Installed [Docker Desktop](https://docs.docker.com/desktop/)
  - Enable [Kubernetes](https://docs.docker.com/get-started/orchestration/)
- Installed [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell)
  - Learn about [execution policies](https:/go.microsoft.com/fwlink/?LinkID=135170)
    - From PowerShell as Administrator, run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned`
  - While in the Administrator PowerShell window, install the module "powershell-yaml"
    - Execute: `Install-Module -Name powershell-yaml`
- Installed [Helm](https://helm.sh/docs/intro/install/) in the path.
- Installed [Terraform](https://www.terraform.io/downloads.html) in the path.
- Installed [mkcert](https://github.com/FiloSottile/mkcert) in the path.
  - Run `mkcert -install`
- Cloud-specific
  - AWS
    - Created [AWS Account](https://aws.amazon.com/free)
    - Installed [AWS CLI](https://aws.amazon.com/cli/)
  - Azure
    - Created [Azure Account](https://azure.microsoft.com/free)
    - Installed [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
  - Google Cloud SDK
    - Created [Google Cloud Account](https://console.cloud.google.com/freetrial)
    - Install the [Google Cloud SDK CLI](https://cloud.google.com/sdk/docs/install)
- DNS provider and instructions to create A record
  - Instructions for [Amazon Route 53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-creating.html)
  - Instructions for [Azure DNS](https://docs.microsoft.com/en-us/azure/dns/dns-getstarted-portal)
  - Instructions for [Google Domains](https://support.google.com/domains/answer/9211383)

## Recommended tools

- Installed version of [Visual Studio Code](https://code.visualstudio.com/)
  - Installed [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) extension.
  - Installed extension for [Kubernetes](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools).
- Installed [Graphviz](https://graphviz.org/download/) in the path.

## Development environment

- Instructions developed and tested with
  - Operating systems
    - Windows 10 Professional.
      - `ver`
        - `Microsoft Windows [Version 10.0.19042.685]`
    - macOs - Big Sur
      - `sw_vers`
        - `ProductVersion: 11.0.1`
        - `BuildVersion: 20B69`
      - Installed tools with [Homebrew](https://brew.sh)
        - `brew cask install docker`
        - `brew cask install powershell`
        - `brew install helm`
        - `brew install terraform`
        - `brew install mkcert`
          - Run `mkcert -install`
        - `brew install graphviz`
        - Cloud-specific
          - `brew install awscli`
          - `brew install azure-cli`
          - `brew cask install google-cloud-sdk`
            - Pay attention to the messages asking to add configuration to the user profile! For PowerShell, added the `bash` lines to `[User]/.bash_profile`.
  - Required tools
    - Docker Desktop
      - `docker version`
        - `Engine: Version: 20.10.0`
      - `kubectl version`
        - `Client Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.3", ...}`
        - `Server Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.3", ...}`
    - PowerShell 7 (x64)
      - `$PSVersionTable`
        - `PSVersion                      7.1.0`
    - Helm
      - `helm version`
        - `version.BuildInfo{Version:"v3.4.2"...`
    - Terraform
      - `terraform version`
        - `Terraform v0.14.3`
    - mkcert
      - `mkcert -version`
        - `v1.4.3`
    - Cloud-specific
      - AWS CLI
        - `aws --version`
          - `aws-cli/2.1.13 Python/3.7.9 Windows/10 exe/AMD64 prompt/off`
      - Azure CLI
        - `az version`
          - `"azure-cli": "2.16.0"`
      - Google Cloud SDK
        - `gcloud --version`
          - `Google Cloud SDK 321.0.0, bq 2.0.64, core 2020.12.11, gsutil 4.57`
    - Recommended tools
      - Visual Studio Code
        - About: `1.52.1 (system setup)`
      - Graphviz
        - `dot -V`
          - `dot - graphviz version 2.44.1 (20200629.0800)`

Back to main [readme](../README.md)
