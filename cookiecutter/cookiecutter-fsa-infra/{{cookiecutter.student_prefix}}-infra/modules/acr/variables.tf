# =============================================================================
# Modul Container Registry - Vstupne premenne
# =============================================================================

variable "resource_group" {
  description = "Nazov Azure Resource Group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "acr_name" {
  description = "Nazov ACR - musi byt globalny, bez pomlcok, iba male pismena a cislice (5-50 znakov)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{5,50}$", var.acr_name))
    error_message = "ACR nazov musi obsahovat iba male pismena a cislice, dlzka 5-50 znakov."
  }
}

variable "environment" {
  description = "Identifikator prostredia"
  type        = string
  default     = "lab"
}

variable "tags" {
  description = "Tagy pre ACR"
  type        = map(string)
  default     = {}
}
