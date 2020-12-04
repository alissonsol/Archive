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

Back to main [readme](../README.md)
