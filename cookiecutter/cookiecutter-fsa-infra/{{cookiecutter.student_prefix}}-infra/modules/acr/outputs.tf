# =============================================================================
# Modul Container Registry - Vystupy
# =============================================================================

output "registry_login_server" {
  description = "Login server URL pre ACR (napr. myregistry.azurecr.io)"
  value       = azurerm_container_registry.fsa_acr.login_server
}

output "registry_admin_username" {
  description = "Admin username pre docker login do ACR"
  value       = azurerm_container_registry.fsa_acr.admin_username
}

output "registry_admin_password" {
  description = "Admin heslo pre docker login do ACR - ulozit do GitLab CI secrets!"
  value       = azurerm_container_registry.fsa_acr.admin_password
  sensitive   = true
}

output "registry_id" {
  description = "Azure Resource ID ACR"
  value       = azurerm_container_registry.fsa_acr.id
}
