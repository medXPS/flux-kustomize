output "resource_group_name" {
  value = data.azurerm_resource_group.rc-gp.name
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.default.name
}


