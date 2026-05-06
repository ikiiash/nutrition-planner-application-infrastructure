# =============================================================================
# Modul Resource Group - Vystupy
# =============================================================================

output "resource_group_name" {
  description = "Nazov vytvorenej Resource Group"
  value       = azurerm_resource_group.fsa_rg.name
}

output "resource_group_location" {
  description = "Region vytvorenej Resource Group"
  value       = azurerm_resource_group.fsa_rg.location
}

output "resource_group_id" {
  description = "Azure Resource ID Resource Group"
  value       = azurerm_resource_group.fsa_rg.id
}
