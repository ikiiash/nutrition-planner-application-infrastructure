output "pip_id" {
  description = "Resource ID Public IP"
  value       = azurerm_public_ip.pip.id
}

output "pip_address" {
  description = "Priradena statická IP adresa"
  value       = azurerm_public_ip.pip.ip_address
}
