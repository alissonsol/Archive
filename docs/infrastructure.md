# Deploy infrastructure components

These scripts will use configuration information from file `config/workloads.yml`.

## Requirements

- Validation of `config/workloads.yml`
  - If not using the local Kubernetes cluster from Docker Desktop, confirm that you have created created the public IP addresses.
    - IMPORTANT: at this time, the DNS should be working.
- Update email address for certificates in file `config/workloads.yml`, field `frontend.certManagerIssuerEmail`

## Deploying the Nginx ingress controller

Add the Nginx ingress controller to the cluster executing the following script from the folder `automation`.

```shell
deploy-ingress.ps1
```

## Deploying certificate

Deploy the certificate, based on the configuration file `config/workloads.yml`. If the `frontend.site` is "localhost" then this script assumes that [mkcert](https://github.com/FiloSottile/mkcert) is installed and will deploy a self-signed certificate. Otherwise, it will deploy the cert-manager service to the cloud cluster. For both cases, notice that the TLS secret should be named "website-kubernetes-tls" (or additional changes are needed in several deployment files).

```shell
deploy-certificate.ps1
```

Back to main [readme](../README.md)
