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

variable "resource_group" {
  description = "Nazov Resource Group pre zdielane resources (DNS zona, atd.)"
  type        = string
  default     = "rg-fsa-common"
}

variable "dns_zone_name" {
  description = "Nazov DNS zony (napr. fullstackacademy.sk)"
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

variable "owners" {
  description = "List of owners for the Azure AD application"
  type        = list(string)
  default     = ["f07c709b-a2a4-4538-9b38-3cea737b1a69"]
}

# -----------------------------------------------------------------------------
# Monitoring stack — Workload Identity
# -----------------------------------------------------------------------------

variable "aks_name" {
  description = "Nazov instruktorskeho AKS clustra (pre data source OIDC issuer URL)"
  type        = string
  default     = "aks-fsa"
}

variable "aks_resource_group_name" {
  description = "Resource Group instruktorskeho AKS clustra"
  type        = string
  default     = "rg-fsa"
}

variable "monitoring_namespace" {
  description = "K8s namespace pre monitoring stack"
  type        = string
  default     = "monitoring"
}

variable "grafana_sa_name" {
  description = "Nazov K8s ServiceAccount pre Grafana (helm release 'monitoring' -> 'monitoring-grafana')"
  type        = string
  default     = "monitoring-grafana"
}
