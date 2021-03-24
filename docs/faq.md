# `yuruna` Frequently Asked Questions

## Answered

- What is the answer to the ultimate question of life, the universe, and everything?
  - `42`. That is why every example has the easy to find and replace prefixes starting with `yrn42`.

- Why I cannot connect to <https://localhost> in a Windows machine?

  - Try to stop HTTP and related processes. Find which process is holding port 80 with `netstat -nao | find ":80"`. You need to stop the Web service (`net stop http`). That may be hard due to issues like [HTTP services can't be stopped when the Microsoft Web Deployment Service is installed](https://docs.microsoft.com/en-us/troubleshoot/iis/http-service-fail-stopped). Try to stop that service also (`net stop msdepsvc`), reboot, and try steps again.

- I've created cloud resources and components in a machine and moved to develop in another one. Is that possible?
  - Yes. You just need to import the cluster context and the resources.output.yml. The command to import the cluster context should be in the `cluster.tf` for the resource template. You may also try to [merge the Kubernetes configuration](https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/).

- In Windows, got the message: `Error: can't find external program "pwsh"`
  - Check that you have PowerShell version 7.1, with the command `$PSVersionTable`. See latest setup instructions at <https://aka.ms/powershell>.

## Unanswered

- What is the ultimate question of life, the universe, and everything?

Back to main [readme](../README.md)
