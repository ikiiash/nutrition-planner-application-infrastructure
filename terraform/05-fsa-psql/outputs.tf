output "psql_fqdn" {
  description = "FQDN PostgreSQL servera"
  value       = azurerm_postgresql_flexible_server.psql.fqdn
}

output "psql_name" {
  description = "Nazov PostgreSQL servera"
  value       = azurerm_postgresql_flexible_server.psql.name
}

output "psql_admin_login" {
  description = "Admin login pre PSQL"
  value       = azurerm_postgresql_flexible_server.psql.administrator_login
}
