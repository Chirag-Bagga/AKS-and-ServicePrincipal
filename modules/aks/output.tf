output "config" {
    value = azurerm_kebernetes_cluster.aks-cluster.kube_config_raw
}