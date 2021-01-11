# Frequently Asked Questions

## Answered

- What is the answer to the ultimate question of life, the universe, and everything?
  - 42

- Why is nothing shown during the `yuruna` execution?
  - The output transcript goes to a temporary file. If you want to see the script output during execution, set the following PowerShell variables.

```Shell
$DebugPreference = "Continue"
$InformationPreference = "Continue"
$VerbosePreference = "Continue"
```

- All deployed successfully, but cannot connect to <https://localhost> in a Windows machine. Why?

  - Try to stop HTTP and related processes. Find which process is holding port 80 with `netstat -nao | find ":80"`. You need to stop the Web service (`net stop http`). That may be hard due to issues like [HTTP services can't be stopped when the Microsoft Web Deployment Service is installed](https://docs.microsoft.com/en-us/troubleshoot/iis/http-service-fail-stopped). Try to stop that service also (`net stop msdepsvc`), reboot, and try steps again.

- I've created cloud resources and components in a machine and moved to develop in another one. Is that possible?
  - Yes. You just need to import the cluster context and the resources.output.yml. The command to import the cluster context should be in the `cluster.tf` for the resource template.

- In Windows, got the message: `Error: can't find external program "pwsh"`
  - Check that you have PowerShell version 7.1, with the command `$PSVersionTable`. See latest setup instructions at <https://aka.ms/powershell>.

## Unanswered

- What is the ultimate question of life, the universe, and everything?
- Why all artifacts need to be in same namespace?
- Is there a way for the DNS binding to dynamically update?
  - Need to investigate
    - [ExternalDNS](https://github.com/kubernetes-sigs/external-dns)
    - [Configuring HTTPS with cert-manager and Google Cloud DNS](https://knative.dev/docs/serving/using-cert-manager-on-gcp/)
    - [Kubernetes w/ Let’s Encrypt & Cloud DNS](https://medium.com/google-cloud/kubernetes-w-lets-encrypt-cloud-dns-c888b2ff8c0e)
    - [Use Let’s Encrypt, Cert-Manager and External-DNS to publish your Kubernetes apps to your website](https://medium.com/asl19-developers/use-lets-encrypt-cert-manager-and-external-dns-to-publish-your-kubernetes-apps-to-your-website-ff31e4e3badf)

Back to main [readme](../README.md)
