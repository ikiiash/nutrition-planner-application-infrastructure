# =============================================================================
# Modul Resource Group - Vstupne premenne
# =============================================================================

variable "resource_group" {
  description = "Nazov Azure Resource Group"
  type        = string
}

variable "location" {
  description = "Azure region (napr. northeurope)"
  type        = string
  default     = "northeurope"
}

variable "environment" {
  description = "Identifikator prostredia (lab, dev, prod)"
  type        = string
  default     = "lab"
}

variable "tags" {
  description = "Tagy pre Resource Group"
  type        = map(string)
  default     = {}
}
