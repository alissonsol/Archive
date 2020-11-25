# Create Public IP

Create public IP address and binds DNS entry to it

## Azure

- Execute script

```shell
automation/azure-create-public-ip.ps1
```

- From now on, this IP address will be the "STATIC_IP" used in commands

## DNS binding

- Go now to the domain registrar and create an A record pointing www.yuruna.com to the STATIC_IP
- You may also want to create an A record pointing just yuruna.com to the STATIC_IP (host recordname `@`)
- It may take a while for the IP address to propagate. Check with a tool like <https://dns.google.com>

Back to main [readme](../README.md)
