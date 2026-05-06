# =============================================================================
# Modul: Azure Kubernetes Service (AKS)
# Spravovany Kubernetes cluster pre beh kontajnerizovanych aplikacii
#
# DOLEZITE: node_resource_group - sem si AKS vytvara pomocne resources.
# Do tejto skupiny MUSI patrit aj Public IP pre Ingress Controller!
# =============================================================================

resource "azurerm_kubernetes_cluster" "fsa_aks" {
  name                = var.aks_name
  location            = var.location
  resource_group_name = var.resource_group
  dns_prefix          = var.dns_prefix

  # Kubernetes verzia - odporuca sa pouzit LTS verziu
  # 1.34.3 = aktualna stabilna verzia na AKS (nie preview), overena 2026-03-27
  kubernetes_version = "1.34.3"

  # DOLEZITE: Nazov node resource group - NEMENTE po vytvoreni!
  # Sem sa ukladaju VM nody, disky, siet a sem patri Public IP
  node_resource_group = var.node_resource_group

  # Konfiguracia hlavneho (system) node pool
  default_node_pool {
    name            = "systempool"
    node_count      = var.node_count
    vm_size         = var.vm_size
    os_disk_size_gb = 50

    # Nastavenia upgradu nodov
    # max_surge: kolko extra nodov sa moze spustit pocas upgradu
    upgrade_settings {
      max_surge                     = "10%"
      drain_timeout_in_minutes      = 0
      node_soak_duration_in_minutes = 0
    }
  }

  # System-assigned managed identity - AKS potrebuje identity pre spravu resources
  identity {
    type = "SystemAssigned"
  }

  # OIDC issuer - nutne ponechat enabled ak uz bol zapnuty pri vytvoreni clustra
  # (Azure nepovoluje ho vypnut po vytvoreni)
  oidc_issuer_enabled = true

  # Nastavenia siete - defaultne Azure CNI
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }

  tags = var.tags
}
