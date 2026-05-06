# =============================================================================
# Modul PostgreSQL - Vstupne premenne
# =============================================================================

variable "resource_group" {
  description = "Nazov Azure Resource Group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "psql_name" {
  description = "Nazov PostgreSQL Flexible Server (musi byt globalny, max 63 znakov)"
  type        = string
}

variable "administrator_login" {
  description = "Administrator login pre PostgreSQL server"
  type        = string
  default     = "fsaadmin"
}

variable "administrator_password" {
  description = "Heslo pre PostgreSQL administratora - pouzit bezpecne heslo!"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Identifikator prostredia"
  type        = string
  default     = "lab"
}

variable "tags" {
  description = "Tagy pre PostgreSQL server"
  type        = map(string)
  default     = {}
}
