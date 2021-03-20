# Hacks

Some notes and hacks learned during the development process.

## Files not changed

Some files are set `assume-unchanged` by scripts that modify the values saved into them. Revert that with the command `git update-index --really-refresh`.

## Note about Docker registry names

It is common for cloud providers to demand a unique registry name and corresponding ([FQDN](https://en.wikipedia.org/wiki/Fully_qualified_domain_name)). Changing the registry name may require changes in the file `config/deployment.yml`.

## Hack to workaround Kubernetes context collision

You can keep contexts simultaneous pointing to the clusters in different clouds by using the [config rename-context](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-em-rename-context-em-) option for `kubectl`.

```shell
kubectl config rename-context old-name new-name
```

## Troubleshooting the automated certificate issuing process

- Check the [cert-manager.io FAQ](https://cert-manager.io/docs/faq/acme/)
  - Under the cluster `Custom Resources`, check the `certificaterequests`
  - Notice this sentence from [Syncing Secrets Across Namespaces](https://cert-manager.io/docs/faq/kubed/): "Wildcard certificates are not supported with HTTP01 validation and require DNS01"
    - See documentation on [Challenge Types](https://letsencrypt.org/docs/challenge-types/)

## Hack to debug issues from container

The containers have minimal software install. Even to ping you have to install it.

```shell
apt-get update
apt-get install -y iputils-ping
```

Then, if you want to build a project outside, you may need to use `dotnet restore`, then `dotnet build` and `dotnet run`. For the restore step to work, you may need to have [`nuget`](https://docs.microsoft.com/en-us/nuget/install-nuget-client-tools) installed and in the path. Then, in what is really the reason for the information to be here in the "hacks" page: at times you first have to execute `nuget restore [name].proj` ahead of `dotnet restore [name].proj`.

See also [kubernetes/ingress-nginx](https://github.com/kubernetes/ingress-nginx/tree/master/docs/examples/grpc) for debugging instructions.

## Docker and Kubernetes issues

Usually, the Docker functionality to `Reset to factory defaults` is the best path to a solution.

Afterwards, remove the `~/.kube` folder and enable Kubernetes again (this loses at least some configuration, and possibly data).

Back to main [readme](../README.md)
