# =============================================================================
# Modul Kubernetes (AKS) - Vystupy
# =============================================================================

output "aks_cluster_name" {
  description = "Nazov AKS clustra - pouzit v GitLab CI AKS_NAME"
  value       = azurerm_kubernetes_cluster.fsa_aks.name
}

output "aks_cluster_id" {
  description = "Azure Resource ID AKS clustra"
  value       = azurerm_kubernetes_cluster.fsa_aks.id
}

output "aks_node_resource_group" {
  description = "Node Resource Group AKS - sem patri Public IP!"
  value       = azurerm_kubernetes_cluster.fsa_aks.node_resource_group
}

output "kube_config" {
  description = "Raw kubeconfig pre kubectl - pouzite pre kubectl pristup"
  value       = azurerm_kubernetes_cluster.fsa_aks.kube_config_raw
  sensitive   = true
}

output "aks_principal_id" {
  description = "Principal ID AKS cluster managed identity"
  value       = azurerm_kubernetes_cluster.fsa_aks.identity[0].principal_id
}

output "kubelet_identity_object_id" {
  description = "Object ID kubelet identity - TOTO potrebuje AcrPull rolu (nie cluster identity!)"
  value       = azurerm_kubernetes_cluster.fsa_aks.kubelet_identity[0].object_id
}
