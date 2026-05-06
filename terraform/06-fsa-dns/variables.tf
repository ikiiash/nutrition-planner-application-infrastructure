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
  description = "Resource Group pre DNS zonu (rg-fsa-common)"
  type        = string
}

variable "dns_zone_name" {
  description = "Nazov DNS zony (napr. fullstackacademy.sk)"
  type        = string
}

variable "pip_name" {
  description = "Nazov existujucej Public IP pre A zaznamy"
  type        = string
}

variable "pip_resource_group_name" {
  description = "Resource Group, kde sa nachadza PIP (node RG)"
  type        = string
}
