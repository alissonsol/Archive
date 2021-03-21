resource "azurerm_kubernetes_cluster" "default" {
  name                = var.clusterName
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = var.clusterDnsPrefix
  kubernetes_version  = var.clusterVersion
  node_resource_group = format("%s_nodes", azurerm_resource_group.default.name)

  default_node_pool {
    name            = "default"
    node_count      = var.nodeCount
    vm_size         = var.nodeType
    os_disk_size_gb = 30
  }

  role_based_access_control {
    enabled = true
  }

  tags = {
    environment = var.resourceTags
  }

  identity {
    type = "SystemAssigned"
  }

  addon_profile {
    http_application_routing {
      enabled = false
    }
  }  

  # Azure-specific: imports the cluster context to local .kube/config
  provisioner "local-exec" {
    command = "./cluster-import.ps1"
    interpreter = local.is_windows ? ["PowerShell", "-Command"] : ["pwsh", "-Command"]

    environment = {
      RESOURCE_GROUP = var.resourceGroup
      CLUSTER_NAME = var.clusterName
      DESTINATION_CONTEXT = var.destinationContext
    }
  }
  
}
