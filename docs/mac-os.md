# macOs

Shortcut to the many guides to install [requirements](./requirements.md) in the macOS.

Tested with Big Sur: `sw_vers`: `ProductVersion: 11.0.1`: `BuildVersion: 20B69`.

```shell
brew cask install docker
brew cask install powershell
brew install helm
brew install terraform
brew install mkcert
mkcert -install
brew install graphviz
```

Cloud CLIs

```shell
brew install awscli
brew install azure-cli
brew cask install google-cloud-sdk
```

After the install for the Google CLI, pay attention to the messages asking to add configuration to the user profile! For PowerShell, added the `bash` lines to `[User]/.bash_profile`.

Back to main [readme](../README.md)
