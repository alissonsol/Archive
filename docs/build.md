# Build code and create container images

## Build images locally

- Set configuration executing from the folder `automation`

```shell
set-dev-environment.ps1
```

- Build containers locally executing from the folder `automation`

```shell
src-build.ps1
```

## Pushing images to registry

- Push containers to registry executing from the folder `automation`

```shell
registry-push.ps1
```

## Deploy images to clusters

- Check configuration files, mainly the `k8s-context-list.yml`
- Execute the PowerShell script from the folder `automation`

```shell
k8s-context-list-deploy.ps1.ps1
```

Back to main [readme](../README.md)
