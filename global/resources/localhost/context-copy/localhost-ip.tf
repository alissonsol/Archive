# Reference: https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/data_source
data "external" "originalIp" {
  program = [
    "pwsh",
    "./localhost-ip.ps1",
    "dummy",
  ]

  query = {
    dummy = "dummy" 
  }
}

output "frontendIp" {
  value = data.external.originalIp.result.ip_address 
}

output "clusterIp" {
  value = data.external.originalIp.result.ip_address
}