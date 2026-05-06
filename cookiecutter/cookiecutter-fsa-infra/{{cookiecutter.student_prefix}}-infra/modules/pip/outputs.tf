# =============================================================================
# Modul Public IP - Vystupy
# =============================================================================

output "public_ip_address" {
  description = "Pridelena staticka verejná IPv4 adresa"
  value       = azurerm_public_ip.fsa_pip.ip_address
}

output "public_ip_fqdn" {
  description = "Plne kvalifikovane domenove meno (napr. prefix.northeurope.cloudapp.azure.com)"
  value       = azurerm_public_ip.fsa_pip.fqdn
}

output "public_ip_id" {
  description = "Azure Resource ID Public IP"
  value       = azurerm_public_ip.fsa_pip.id
}
