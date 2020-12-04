# Requirements

These instructions assume that you have a registered domain and know how to create/edit DNS records in your registrar.

## Required tools

- Installed [Docker Desktop](https://docs.docker.com/desktop/)
  - Enable [Kubernetes](https://docs.docker.com/get-started/orchestration/)
  - If using Docker in the `localhost`, run the script `automation/registry-run-local.ps1`.
    - This will rename your `docker-desktop` context to `yuruna` or whatever default named that was replaced with!
- Installed [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell)
- Installed [Helm](https://helm.sh/docs/intro/install/) in the path.
- Installed [Terraform](https://www.terraform.io/downloads.html) in the path.
- Installed [mkcert](https://github.com/FiloSottile/mkcert) in the path.
- Cloud-specific
  - AWS
    - Created [AWS Account](https://aws.amazon.com/free)
    - Installed [AWS CLI](https://aws.amazon.com/cli/)
  - Azure
    - Created [Azure Account](https://azure.microsoft.com/free)
    - Installed [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
  - Google Cloud SDK
    - Created [Google Cloud Account](https://console.cloud.google.com/freetrial)
    - Install the [CLI](https://cloud.google.com/sdk/docs/install)
- DNS provider and instructions to create A record
  - Instructions for [Amazon Route 53](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resource-record-sets-creating.html)
  - Instructions for [Azure DNS](https://docs.microsoft.com/en-us/azure/dns/dns-getstarted-portal)
  - Instructions for [Google Domains](https://support.google.com/domains/answer/9211383)

## Recommended tools

- Installed version of [Visual Studio Code](https://code.visualstudio.com/)
  - Installed [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) extension.
  - Installed extension for [Kubernetes](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools).

## Development environment

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
        - `brew cask install powershell`
        - `brew install helm`
        - `brew install terraform`
        - Cloud-specific
          - `brew install awscli`
          - `brew install azure-cli`
          - `brew cask install google-cloud-sdk`
            - Pay attention to the messages asking to add configuration to the user profile! For PowerShell, added the `bash` lines to `[User]/.bash_profile`.
  - Tools
    - Docker Desktop
      - `docker version`
        - `Engine: Version: 19.03.13`
      - `kubectl version`
        - `Client Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.3", ...}`
        - `Server Version: version.Info{Major:"1", Minor:"19", GitVersion:"v1.19.3", ...}`
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
        - `Terraform v0.14.0`
    - mkcert
      - `mkcert -version`
        - `v1.4.3`
    - Cloud-specific
      - AWS CLI
        - `aws --version`
          - `aws-cli/2.1.4 Python/3.7.9 Windows/10 exe/AMD64`
      - Azure CLI
        - `az version`
          - `"azure-cli": "2.15.1"`
      - Google Cloud SDK
        - `gcloud --version`
          - `Google Cloud SDK 319.0.0, bq 2.0.62, core 2020.11.13, gsutil 4.55`

Back to main [readme](../README.md)
