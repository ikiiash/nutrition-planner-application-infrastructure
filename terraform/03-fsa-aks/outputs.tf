output "aks_id" {
  description = "Resource ID AKS clustra"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "aks_fqdn" {
  description = "FQDN AKS clustra"
  value       = azurerm_kubernetes_cluster.aks.fqdn
}

output "kubeconfig" {
  description = "Kubeconfig pre pristup ku clustru"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "kubelet_identity_object_id" {
  description = "Object ID kubelet managed identity (pouziva sa pre RBAC/ACR)"
  value       = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}
