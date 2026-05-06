# =============================================================================
# Modul: Azure Container Registry (ACR)
# Docker registry pre ukladanie a distribuciu Docker images
# =============================================================================

resource "azurerm_container_registry" "fsa_acr" {
  # Nazov ACR musi byt globalny, bez pomlcok, iba male pismena a cislice
  name                = var.acr_name
  resource_group_name = var.resource_group
  location            = var.location

  # Basic SKU - dostacujuce pre workshop/lab prostredie
  # Standard/Premium pridavaju geo-replication, webhooks a pokrocile features (produkcia)
  sku = "Basic"

  # Admin enabled - potrebne pre jednoduchy docker login v pipeline
  # V produkcii odporucame Service Principal alebo Managed Identity
  admin_enabled          = true
  anonymous_pull_enabled = false

  tags = var.tags
}
