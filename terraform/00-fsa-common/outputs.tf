output "dns_zone_name_servers" {
  description = "Name servery DNS zony - nastav ich u registrara domeny (jednorazovy krok, nesmie sa menit)"
  value       = azurerm_dns_zone.fsa.name_servers
}

output "dns_zone_id" {
  description = "Resource ID DNS zony"
  value       = azurerm_dns_zone.fsa.id
}

output "dns_zone_name" {
  description = "Nazov DNS zony"
  value       = azurerm_dns_zone.fsa.name
}

output "common_resource_group_name" {
  description = "Nazov Resource Group pre zdielane resources"
  value       = azurerm_resource_group.rg-common.name
}

output "grafana_oauth_client_id" {
  description = "Client ID pre Grafana Azure AD OAuth"
  value       = azuread_application.grafana.client_id
}

output "grafana_client_id" {
  description = "Client ID Grafana App Registration — pouzit ako azure.workload.identity/client-id annotation na K8s ServiceAccount"
  value       = azuread_application.grafana.client_id
}
