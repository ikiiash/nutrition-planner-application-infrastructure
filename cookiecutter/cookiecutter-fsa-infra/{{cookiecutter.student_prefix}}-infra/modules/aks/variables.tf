# =============================================================================
# Modul Kubernetes (AKS) - Vstupne premenne
# =============================================================================

variable "resource_group" {
  description = "Nazov Azure Resource Group kde sa vytvori AKS"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "aks_name" {
  description = "Nazov AKS clustra"
  type        = string
}

variable "node_resource_group" {
  description = "Nazov resource group pre AKS nody (node RG). DOLEZITE: sem patri aj Public IP!"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix pre AKS API server"
  type        = string
}

variable "node_count" {
  description = "Pocet worker nodov"
  type        = number
  default     = 1
}

variable "vm_size" {
  description = "Velkost VM pre AKS nody"
  type        = string
  default     = "Standard_B2s"
}

variable "environment" {
  description = "Identifikator prostredia"
  type        = string
  default     = "lab"
}

variable "tags" {
  description = "Tagy pre AKS"
  type        = map(string)
  default     = {}
}
