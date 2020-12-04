# References

## Cloud-specific

### AWS

- [Getting started with Amazon ECR using the AWS CLI](https://docs.aws.amazon.com/AmazonECR/latest/userguide/getting-started-cli.html)

### Azure

- [Azure Container Registry documentation](https://docs.microsoft.com/en-us/azure/container-registry/)
- [Use a static public IP address and DNS label with the Azure Kubernetes Service (AKS) load balancer](https://docs.microsoft.com/en-us/azure/aks/static-ip)
- [AKS with multiple nginx ingress controllers, Application Gateway and Key Vault certificates](https://blog.hjgraca.com/aks-with-multiple-nginx-ingress-controllers-application-gateway-and-key-vault-certificates)

### GCP

- [Configuring cluster access for kubectl](https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl)
- [Using Container Registry with Google Cloud](https://cloud.google.com/container-registry/docs/using-with-google-cloud-platform)
- Container Registry Guides: [Authentication methods](https://cloud.google.com/container-registry/docs/advanced-authentication)
- Container Registry Guides: [Configuring access control](https://cloud.google.com/container-registry/docs/access-control)
- [Reserving a static external IP address](https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address#gcloud)
- [Setting up HTTP(S) Load Balancing with Ingress](https://cloud.google.com/kubernetes-engine/docs/tutorials/http-balancer)
  - Notice that this doesn't apply when using [Ingress with NGINX controller on Google Kubernetes Engine](https://cloud.google.com/community/tutorials/nginx-ingress-gke)
  - [Configuring domain names with static IP addresses](https://cloud.google.com/kubernetes-engine/docs/tutorials/configuring-domain-name-static-ip)

### Kubernetes

- [Manage Kubernetes with Terraform](https://learn.hashicorp.com/collections/terraform/kubernetes)
- [Declarative Management of Kubernetes Objects Using Kustomize](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/)

### Ingress

- [ingress-nginx](https://github.com/kubernetes/ingress-nginx/tree/master/charts/ingress-nginx) at GitHub
- [Redirect to www with an nginx ingress](https://www.informaticsmatters.com/blog/2020/06/03/redirecting-to-www.html)
- [How To Set Up an Nginx Ingress on DigitalOcean Kubernetes Using Helm](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nginx-ingress-on-digitalocean-kubernetes-using-helm)

### Certificates

- [mkcert](https://github.com/FiloSottile/mkcert) is a simple tool for making locally-trusted development certificates.
- [cert-manager](https://cert-manager.io/docs/installation/kubernetes/) documentation
- NGINX Ingress Controller [TLS termination](https://kubernetes.github.io/ingress-nginx/examples/tls-termination/)

### PowerShell

- PSScriptAnalyzer [code](https://github.com/PowerShell/PSScriptAnalyzer)
  - `Invoke-ScriptAnalyzer -Path .`

Back to main [readme](../README.md)
