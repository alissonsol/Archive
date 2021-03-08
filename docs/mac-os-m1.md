# macOS M1 instructions

Shortcut to the many guides to install [requirements](./requirements.md) in the macOS.

Instructions under development for the Apple M1 machines. Steps being documented, as well as what doesn't work yet.

## Steps that may need manual interaction

Steps that may need a password or other decisions before proceeding. First, install Brew (may need password and press to continue).

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

`[M1]` Manually add brew to the path:

```shell
echo 'eval $(/opt/homebrew/bin/brew shellenv)' >> /Users/$USER/.zprofile
eval $(/opt/homebrew/bin/brew shellenv)
```

NOTE: When updating the installed versions, use `reinstall` instead of `install` in the commands below.

Install mkcert and then install the root certificates. May need to enter password twice when running `mkcert -install`.

```shell
brew install mkcert
mkcert -install
```

PowerShell may also need the password. Install also the module for Yaml.

`[M1]` Install Rosetta 2 first with: `sudo softwareupdate --install-rosetta`

```shell
brew install --cask powershell
pwsh
Install-Module -Name powershell-yaml
```

If not installed yet, install and configure Git.

```shell
brew install git
git config --global user.name "Your Name"
git config --global user.email "Your@email.address"
```

Install Docker.

Tested with Preview 3.1.0 (60984). References:

- Instructions to install the [Apple M1 Tech Preview](https://docs.docker.com/docker-for-mac/apple-m1/)

Start Docker from the `Applications` folder. Then, open the settings panel and [enable Kubernetes](https://docs.docker.com/docker-for-mac/#kubernetes).

`[M1]` Because the steps to build code will need it, install xcode tools:

```shell
xcode-select --install
```

## Steps without manual interaction

These steps can then be executed to install Terraform, Helm and optionally Visual Studio Code and GraphViz (if you want to visualize Terraform plans).

```shell
brew install --build-from-source terraform
brew install helm
brew install graphviz
brew install --cask visual-studio-code
```

After installing Visual Studio Code, it is recommended to install the externsions for [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker) and [Kubernetes](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools).

Back to main [readme](../README.md)
