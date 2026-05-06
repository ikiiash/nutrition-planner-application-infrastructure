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

variable "location" {
  description = "Pouzije sa na vytvorenie resource_group, ostatne resouces dedia tieto nastavenia."
  type        = string
  default     = "northeurope"
}

variable "resource_group_name" {
  description = "Resource Group, do ktorej sa ACR vytvori"
  type        = string
}

variable "acr_name" {
  description = "Nazov ACR (bez pomlciek, max 50 znakov)"
  type        = string
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
