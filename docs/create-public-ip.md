# Create Public IP

Create public IP addresses and binds DNS entries

## Creating the public-ip adddress

Execute the script below from the folder automation/[cloud].

```shell
create-public-ip.ps1
```

- From now on, this IP address will be in the `config/workflows.yml` file and used in the follow-up commands.

## DNS binding

- Configure the `frontend.site` field in the `config/workflows.yml` file.
- Go now to the domain registrar and create an A record pointing the `frontend.site` to the `frontend.ipAddress` value.
- It may take a while for the IP address to propagate. Check with a tool like <https://dns.google.com>

Back to main [readme](../README.md)
