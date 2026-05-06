# =============================================================================
# Modul PostgreSQL - Vystupy
# =============================================================================

output "psql_server_fqdn" {
  description = "FQDN PostgreSQL servera - pouzit v DB_URL (napr. v K8s secrets)"
  value       = azurerm_postgresql_flexible_server.fsa_psql.fqdn
}

output "psql_server_name" {
  description = "Nazov PostgreSQL servera"
  value       = azurerm_postgresql_flexible_server.fsa_psql.name
}

output "psql_server_id" {
  description = "Azure Resource ID PostgreSQL servera"
  value       = azurerm_postgresql_flexible_server.fsa_psql.id
}

output "psql_keycloak_db_name" {
  description = "Nazov Keycloak databazy"
  value       = azurerm_postgresql_flexible_server_database.keycloak.name
}

output "psql_app_db_name" {
  description = "Nazov aplikacnej databazy"
  value       = azurerm_postgresql_flexible_server_database.fsa_app_db.name
}
