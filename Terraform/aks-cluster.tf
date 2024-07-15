resource "azurerm_kubernetes_cluster" "default" {
  name                = "adria-aks"
  location            = "westus"  # Change to a different region
  tags                = data.azurerm_resource_group.rc-gp.tags
  resource_group_name = data.azurerm_resource_group.rc-gp.name

  dns_prefix          = "adria-k8s"
  kubernetes_version  = "1.29.2"

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_B2s"  # Retain the same VM size
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  role_based_access_control_enabled = true
}
