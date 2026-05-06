# -----------------------------------------------------------------------------
# Azure auth - service principal - autentifikacia do azure
# -----------------------------------------------------------------------------

variable "subscription_id" {
  description = "Subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Tenant ID"
  type        = string
}

# -----------------------------------------------------------------------------
# Globalne nastavenia projektu
# -----------------------------------------------------------------------------

variable "resource_group_name" {
  description = "Resource Group, do ktorej sa PSQL vytvori"
  type        = string
}

# -----------------------------------------------------------------------------
# PostgreSQL
# -----------------------------------------------------------------------------

variable "psql_name" {
  description = "Nazov PostgreSQL Flexible Server"
  type        = string
}

variable "psql_admin_username" {
  description = "Admin username pre PSQL"
  type        = string
}

variable "psql_admin_password" {
  description = "Admin heslo pre PSQL"
  type        = string
  sensitive   = true
}

variable "psql_sku" {
  description = "SKU pre PSQL (napr. B_Standard_B1ms, GP_Standard_D2s_v3)"
  type        = string
  default     = "B_Standard_B1ms"
}

variable "psql_version" {
  description = "Verzia PostgreSQL"
  type        = string
  default     = "16"
}

variable "psql_storage_mb" {
  description = "Velkost uloziska v MB (min 32768)"
  type        = number
  default     = 32768
}

variable "tags" {
  description = "Tagy aplikovane na vsetky resources"
  type        = map(string)
  default = {
    project    = "fsa"
    managed_by = "terraform"
    owner      = "radovan.pieter@posam.sk"
  }
}
