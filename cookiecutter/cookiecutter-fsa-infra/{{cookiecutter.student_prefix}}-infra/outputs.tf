# =============================================================================
# FSA 2026 DevOps Workshop - Terraform Outputs
# Po "terraform apply" zobrazuje dolezite hodnoty pre dalsi postup
# =============================================================================

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------

output "resource_group_name" {
  description = "Nazov Resource Group"
  value       = module.resource_group.resource_group_name
}

output "resource_group_location" {
  description = "Region Resource Group"
  value       = module.resource_group.resource_group_location
}

# -----------------------------------------------------------------------------
# Azure Container Registry (ACR)
# -----------------------------------------------------------------------------

output "acr_login_server" {
  description = "URL ACR registra - pouzite v GitLab CI premenna ACR_NAME"
  value       = module.container_registry.registry_login_server
}

output "acr_admin_username" {
  description = "ACR admin username pre docker login"
  value       = module.container_registry.registry_admin_username
}

output "acr_admin_password" {
  description = "ACR admin heslo - ulozit do GitLab CI premennej ACR_PASSWORD"
  value       = module.container_registry.registry_admin_password
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Azure Kubernetes Service (AKS)
# -----------------------------------------------------------------------------

output "aks_cluster_name" {
  description = "Nazov AKS clustra - pouzite v GitLab CI premenna AKS_NAME"
  value       = module.kubernetes.aks_cluster_name
}

output "aks_node_resource_group" {
  description = "Node Resource Group AKS clustra (sem patrí Public IP)"
  value       = module.kubernetes.aks_node_resource_group
}

# -----------------------------------------------------------------------------
# Public IP
# -----------------------------------------------------------------------------

output "public_ip_address" {
  description = "Verejná IP adresa pre pristup k aplikacii"
  value       = module.public_ip.public_ip_address
}

output "public_ip_fqdn" {
  description = "DNS nazov Public IP adresy"
  value       = module.public_ip.public_ip_fqdn
}

# -----------------------------------------------------------------------------
# PostgreSQL
# -----------------------------------------------------------------------------

output "psql_server_fqdn" {
  description = "FQDN PostgreSQL servera - pouzite v DB_URL"
  value       = module.psql.psql_server_fqdn
}

output "psql_server_name" {
  description = "Nazov PostgreSQL servera"
  value       = module.psql.psql_server_name
}
