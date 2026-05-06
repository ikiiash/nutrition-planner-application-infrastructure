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
  description = "Resource Group, do ktorej sa AKS vytvori"
  type        = string
}

variable "acr_name" {
  description = "Nazov existujuceho ACR pre napojenie AcrPull"
  type        = string
}

variable "aks_name" {
  description = "Nazov AKS clustra"
  type        = string
}

variable "aks_version" {
  description = "Verzia AKS clustra"
  type        = string
}

variable "node_pool_drain_timeout" {
  description = "Drain timeout in minutes for node pool"
  type        = number
  default     = 30
}

variable "node_pool_max_surge" {
  description = "Max surge for node pool"
  type        = number
  default     = 1
}

variable "node_pool_soak_duration" {
  description = "Node soak duration in minutes for node pool"
  type        = number
  default     = 30
}

# -----------------------------------------------------------------------------
# Infra nodepool (default)
# -----------------------------------------------------------------------------

variable "infra_node_vm_size" {
  description = "VM size pre infra (default) nodepool"
  type        = string
  default     = "Standard_D2s_v5"
}

variable "infra_node_count" {
  description = "Pocet nodov v infra nodepoole"
  type        = number
  default     = 1
}

# -----------------------------------------------------------------------------
# App nodepool
# -----------------------------------------------------------------------------

variable "app_node_vm_size" {
  description = "VM size pre app nodepool"
  type        = string
  default     = "Standard_B2ms"
}

variable "app_node_count" {
  description = "Pocet nodov v app nodepoole"
  type        = number
  default     = 1
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
