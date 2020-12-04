# Deploy Kubernetes workloads

- Check configuration files, mainly the `config/workloads.yml`.
- Execute the PowerShell script from the folder `automation`.

```shell
deploy-workloads.ps1
```

## Hack

There are two files under the `deployment/infrastructure/ingress` folder.
In case the server cluster is below 1.19 (check with `kubectl version`) then one should succeed! (the other will fail but that can be ignored for now)

Back to main [readme](../README.md)
