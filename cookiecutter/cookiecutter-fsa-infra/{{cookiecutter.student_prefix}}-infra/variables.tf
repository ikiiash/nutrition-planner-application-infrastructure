# =============================================================================
# FSA 2026 DevOps Workshop - Globalne premenne pre vsetky moduly
# =============================================================================

# -----------------------------------------------------------------------------
# Azure autentifikacia - service principal
# -----------------------------------------------------------------------------

variable "subscription_id" {
  description = "Azure Subscription ID - najdete v Azure Portal > Subscriptions"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID - najdete v Azure Portal > Azure Active Directory"
  type        = string
}

# -----------------------------------------------------------------------------
# Spolocne nastavenia projektu
# -----------------------------------------------------------------------------

variable "student_prefix" {
  description = "Jedinecny identifikator studenta - pouziva sa v nazvoch vsetkych resources"
  type        = string
  default     = "{{ cookiecutter.student_prefix }}"
}

variable "location" {
  description = "Azure region pre vsetky resources (okrem Public IP, ktora je v node RG)"
  type        = string
  default     = "{{ cookiecutter.location }}"
}

variable "environment" {
  description = "Identifikator prostredia (lab, dev, prod)"
  type        = string
  default     = "{{ cookiecutter.environment }}"
}

# -----------------------------------------------------------------------------
# PostgreSQL nastavenia
# -----------------------------------------------------------------------------

variable "psql_location" {
  description = "Azure region pre PostgreSQL (moze byt iny ako hlavny region - niektoré subscriptions maju restrickcie)"
  type        = string
  default     = "{{ cookiecutter.psql_location }}"
}

variable "psql_admin" {
  description = "Administrator login pre PostgreSQL Flexible Server"
  type        = string
  default     = "{{ cookiecutter.psql_admin }}"
}

variable "psql_password" {
  description = "Heslo pre PostgreSQL administratora (ulozit ako secret!)"
  type        = string
  sensitive   = true
  default     = "{{ cookiecutter.psql_password }}"
}

# -----------------------------------------------------------------------------
# Kubernetes (AKS) nastavenia
# -----------------------------------------------------------------------------

variable "node_count" {
  description = "Pocet worker nodov v AKS clustri (1-5)"
  type        = string
  default     = "{{ cookiecutter.node_count }}"

  validation {
    condition     = var.node_count >= 1 && var.node_count <= 5
    error_message = "Pocet nodov musi byt medzi 1 a 5."
  }
}

variable "vm_size" {
  description = "Velkost VM pre AKS nody"
  type        = string
  default     = "{{ cookiecutter.vm_size }}"
}
