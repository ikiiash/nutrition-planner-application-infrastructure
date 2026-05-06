output "acr_login_server" {
  description = "Login server URL pre ACR (napr. fsaacr.azurecr.io)"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "Admin username pre ACR"
  value       = azurerm_container_registry.acr.admin_username
}

output "acr_admin_password" {
  description = "Admin password pre ACR"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}
