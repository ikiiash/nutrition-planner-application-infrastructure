# =============================================================================
# Modul Public IP - Vstupne premenne
# =============================================================================

variable "resource_group" {
  description = "POZOR: Musi byt node_resource_group z AKS (napr. mc_<prefix>-aks)"
  type        = string
}

variable "location" {
  description = "Azure region (musi byt rovnaky ako AKS)"
  type        = string
}

variable "pip_name" {
  description = "Nazov Public IP resource"
  type        = string
}

variable "dns_label" {
  description = "DNS label - vytvori FQDN: <label>.<region>.cloudapp.azure.com"
  type        = string
}

variable "environment" {
  description = "Identifikator prostredia"
  type        = string
  default     = "lab"
}

variable "tags" {
  description = "Tagy pre Public IP"
  type        = map(string)
  default     = {}
}
