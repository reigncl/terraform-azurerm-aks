output client_key {
  value = azurerm_kubernetes_cluster.primary.kube_config[0].client_key
}

output client_certificate {
  value = azurerm_kubernetes_cluster.primary.kube_config[0].client_certificate
}

output cluster_ca_certificate {
  value = azurerm_kubernetes_cluster.primary.kube_config[0].cluster_ca_certificate
}

output host {
  value = azurerm_kubernetes_cluster.primary.kube_config[0].host
}

output username {
  value = azurerm_kubernetes_cluster.primary.kube_config[0].username
}

output password {
  value = azurerm_kubernetes_cluster.primary.kube_config[0].password
}

output node_resource_group {
  value = azurerm_kubernetes_cluster.primary.node_resource_group
}

output location {
  value = azurerm_kubernetes_cluster.primary.location
}

output aks_id {
  value = azurerm_kubernetes_cluster.primary.id
}

