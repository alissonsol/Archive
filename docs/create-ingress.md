# Create ingress resources

Create ingress resources in the Kubernetes cluster

## Requirements

- Confirm that you have created and tested the website container.
- Public IP. Use that value to replace references to "STATIC_IP" below.

## Create ingress with Helm

- Ingress with static IP, as per article [Create an ingress controller with a static public IP address in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/ingress-static-ip)
  - Add the ingress-nginx repository to helm

```shell
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
```

- Use Helm to deploy an NGINX ingress controller
  - Uninstall with `helm uninstall nginx-ingress`, if needed.
  - Could only succeed if installing in same namespace (unlike guidance, which uses isolated namespace for the ingress)

```shell
helm install nginx-ingress ingress-nginx/ingress-nginx `
    --namespace yuruna `
    --set controller.replicaCount=2 `
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux `
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux `
    --set controller.service.loadBalancerIP="STATIC_IP" `
    --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-dns-label-name"="yuruna"
```

## Check ingress is working

- Check if the `kubectl get services --namespace yuruna`
  - Wait while it shows the `nginx-ingress-ingress-nginx-controller` with `External-IP` as pending.
- Under folder `deployment`, execute `kubectl apply -f ingress/01-ingress-to-website.yml --namespace yuruna`
- Testing
  - Test with `curl -v http://STATIC_IP -H 'Host: www.yuruna.com'`
  - Option in Windows: add the "STATIC_IP" to %windir%\system32\drivers\etc\hosts, pointing to the DNS (www.yuruna.com) and use a browser

## References

- [Redirect to www with an nginx ingress](https://www.informaticsmatters.com/blog/2020/06/03/redirecting-to-www.html)

Back to main [readme](../README.md)
