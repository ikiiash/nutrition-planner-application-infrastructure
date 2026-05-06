# =============================================================================
# FSA 2026 DevOps Workshop - Hlavny Terraform subor
# Vola vsetky moduly v spravnom poradi
# =============================================================================

terraform {
  required_version = ">= 1.14.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.64"
    }
  }

  # TF state ulozeny v Azure Storage Account
  # POZNAMKA: Backend nemôže použiť premenné — hodnoty sú priamo z Cookiecutter.
  # Pristup cez osobny Azure ucet (az login), nie Service Principal.
  backend "azurerm" {
    resource_group_name  = "{{ cookiecutter.tfstate_resource_group }}"
    storage_account_name = "{{ cookiecutter.tfstate_storage_account }}"
    container_name       = "{{ cookiecutter.tfstate_container }}"
    key                  = "{{ cookiecutter.tfstate_year }}/{{ cookiecutter.student_prefix }}/terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

# =============================================================================
# Lokalne hodnoty - vypocitane z premennych
# =============================================================================

locals {
  # Meno studenta (kratke, napr. "pieterr")
  name = "{{ cookiecutter.student_prefix }}"

  # Konvencia: <resource>-fsa-<meno>
  resource_group = "rg-fsa-{{ cookiecutter.student_prefix }}"
  aks_name       = "aks-fsa-{{ cookiecutter.student_prefix }}"
  psql_name      = "psql-fsa-{{ cookiecutter.student_prefix }}"

  # ACR naming obmedzenia Azure:
  #   - iba lowercase alphanumeric (ziadne pomlcky ani ine znaky!)
  #   - 5–50 znakov
  #   - globalne unikatny napriec celym Azure
  #   - musi zacinat pismenom
  # "acrfsa" (6 znakov) + meno bez pomlcok = bezpecny zaklad
  acr_name = replace("acrfsa{{ cookiecutter.student_prefix }}", "-", "")

  # Node Resource Group — sem AKS uklada VM nody, disky, siet a Public IP
  # Format inspirovany Azure defaultom (MC_..._region), meno studenta iba raz
  aks_node_rg = "MC_fsa-{{ cookiecutter.student_prefix }}_{{ cookiecutter.location }}"

  # Spolocne tagy pre vsetky resources
  common_tags = {
    environment = var.environment
    project     = "fsa-workshop-2026"
    student     = "{{ cookiecutter.student_prefix }}"
  }
}

# =============================================================================
# Modul 1: Resource Group
# MUSI byt vytvoreny ako prvy - ostatne moduly su na nom zavisle
# =============================================================================

module "resource_group" {
  source = "./modules/rg"

  resource_group = local.resource_group
  location       = var.location
  environment    = var.environment
  tags           = local.common_tags
}

# =============================================================================
# Modul 2: Azure Container Registry (ACR)
# Docker registry pre ulozenie a stiahnutie images
# =============================================================================

module "container_registry" {
  source = "./modules/acr"

  resource_group = module.resource_group.resource_group_name
  location       = module.resource_group.resource_group_location
  acr_name       = local.acr_name
  environment    = var.environment
  tags           = local.common_tags

  # Explicit zavislost: ACR musi byt az po Resource Group
  depends_on = [module.resource_group]
}

# =============================================================================
# Modul 3: Azure Kubernetes Service (AKS)
# Kubernetes cluster pre beh aplikacii
# =============================================================================

module "kubernetes" {
  source = "./modules/aks"

  resource_group      = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  aks_name            = local.aks_name
  node_resource_group = local.aks_node_rg
  dns_prefix          = "{{ cookiecutter.student_prefix }}"
  node_count          = var.node_count
  vm_size             = var.vm_size
  environment         = var.environment
  tags                = local.common_tags

  depends_on = [module.resource_group]
}

# =============================================================================
# Modul 4: Public IP
# DOLEZITE: Musi byt v node_resource_group AKS clustra, nie v hlavnej RG!
# Tuto IP pouziva Ingress Controller pre pristup z internetu
# =============================================================================

module "public_ip" {
  source = "./modules/pip"

  # POZOR: Tuto pouzivame node_resource_group z AKS modulu!
  resource_group = local.aks_node_rg
  location       = module.resource_group.resource_group_location
  pip_name       = "pip-fsa-{{ cookiecutter.student_prefix }}"
  dns_label      = "fsa-{{ cookiecutter.student_prefix }}"
  environment    = var.environment
  tags           = local.common_tags

  # Public IP musi byt az po AKS (node RG sa vytvori pri AKS)
  depends_on = [module.kubernetes]
}

# =============================================================================
# Modul 5: PostgreSQL Flexible Server
# Databazovy server s dvoma databazami: keycloak a fsa-db
# =============================================================================

module "psql" {
  source = "./modules/psql"

  resource_group         = module.resource_group.resource_group_name
  location               = var.psql_location
  psql_name              = local.psql_name
  administrator_login    = var.psql_admin
  administrator_password = var.psql_password
  environment            = var.environment
  tags                   = local.common_tags

  depends_on = [module.resource_group]
}

# =============================================================================
# AcrPull: AKS kubelet identity -> ACR
# Umoznuje AKS automaticky pullovat images z ACR bez docker login credentials
#
# DOLEZITE: Pouzivame kubelet_identity (nie cluster identity!)
# kubelet_identity = identity pouzivana nodmi pri pullovani images
# cluster identity = identity pre spravu Azure resources (networking, disks...)
# =============================================================================

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = module.container_registry.registry_id
  role_definition_name = "AcrPull"
  principal_id         = module.kubernetes.kubelet_identity_object_id

  depends_on = [module.kubernetes, module.container_registry]
}
