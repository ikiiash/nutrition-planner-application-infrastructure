provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

# -----------------------------------------------------------------------------
# Data sources - referencie na existujuce resources
# -----------------------------------------------------------------------------

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
}

# -----------------------------------------------------------------------------
# AKS cluster
# -----------------------------------------------------------------------------

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = "North Europe"
  resource_group_name = data.azurerm_resource_group.rg.name
  node_resource_group = "mc_${var.resource_group_name}"
  dns_prefix          = var.aks_name
  kubernetes_version  = var.aks_version

  # Zapnutie nastavenia pre povolenie Workload Identity
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name                        = "infra"
    vm_size                     = var.infra_node_vm_size
    orchestrator_version        = var.aks_version
    node_count                  = var.infra_node_count
    temporary_name_for_rotation = "infraall"

    upgrade_settings {
      drain_timeout_in_minutes      = var.node_pool_drain_timeout
      max_surge                     = var.node_pool_max_surge
      node_soak_duration_in_minutes = var.node_pool_soak_duration
    }

    node_labels = {
      "role" = "infra"
    }

    tags = var.tags
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# App nodepool
# -----------------------------------------------------------------------------

resource "azurerm_kubernetes_cluster_node_pool" "app" {
  name                        = "app"
  kubernetes_cluster_id       = azurerm_kubernetes_cluster.aks.id
  vm_size                     = var.app_node_vm_size
  node_count                  = var.app_node_count
  temporary_name_for_rotation = "appall"

  node_labels = {
    "role" = "app"
  }

  upgrade_settings {
    drain_timeout_in_minutes      = var.node_pool_drain_timeout
    max_surge                     = var.node_pool_max_surge
    node_soak_duration_in_minutes = var.node_pool_soak_duration
  }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# ACR pull pravo pre AKS managed identity
# -----------------------------------------------------------------------------

resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = data.azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}
