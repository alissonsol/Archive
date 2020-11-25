# Use cert-manager to automatically get certificate

Deploy and use cert-manager to get Let's Encrypt certificate.

## Requirements

- Confirm that you have created and tested the website container.
- Public IP. Use that value to replace references to "STATIC_IP" below.
  - IMPORTANT: at this time, the DNS should be working.
    - Execute `ping www.yuruna.com` and check it points to the STATIC_IP. If not, verify your registrar settings.

## Deploying cert-manager

- Following instructions from [cert-manager.io](https://cert-manager.io/docs/installation/kubernetes/), with parts from [DigitalOcean Tutorial](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nginx-ingress-on-digitalocean-kubernetes-using-helm)

- Apply the latest cert-manager release

```shell
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.0.4/cert-manager.yaml
```

- Update email address in file 'deployment/ingress/02-production-issue.yml'  
- Under folder `deployment`, execute

```shell
kubectl apply -f ingress/02-production-issuer.yml --namespace yuruna
```

- If it was created for tests, delete previous ingress without TLS: `kubectl delete -f ingress/01-ingress-to-website.yml --namespace yuruna`
- Apply ingress with TLS, from the `deployment` folder

```shell
kubectl apply -f ingress/03-ingress-to-website-with-tls.yml --namespace yuruna
```

- Troubleshooting instructions: check the [cert-manager.io FAQ](https://cert-manager.io/docs/faq/acme/)
  - Under the cluster `Custom Resources`, check the `certificaterequests`
  - Notice this sentence from [Syncing Secrets Across Namespaces](https://cert-manager.io/docs/faq/kubed/): "Wildcard certificates are not supported with HTTP01 validation and require DNS01"
    - See documentation on [Challenge Types](https://letsencrypt.org/docs/challenge-types/)

Back to main [readme](../README.md)
