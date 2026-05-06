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
  description = "Resource Group, kde je nasadeny AKS cluster"
  type        = string
}

variable "aks_name" {
  description = "Nazov existujuceho AKS clustra"
  type        = string
}

variable "pip_name" {
  description = "Nazov Public IP adresy"
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
