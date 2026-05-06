provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

# -----------------------------------------------------------------------------
# Data sources - referencie na existujuce resources
# -----------------------------------------------------------------------------

data "azurerm_resource_group" "common" {
  name = var.resource_group_name
}

data "azurerm_public_ip" "pip" {
  name                = var.pip_name
  resource_group_name = var.pip_resource_group_name
}

# DNS zona je permanentna - spravuje ju 00-fsa-common
data "azurerm_dns_zone" "fsa" {
  name                = var.dns_zone_name
  resource_group_name = data.azurerm_resource_group.common.name
}

# -----------------------------------------------------------------------------
# DNS zaznamy (year-specific - mozno zmazat a znovu aplikovat)
# -----------------------------------------------------------------------------

# app A -> PIP
resource "azurerm_dns_a_record" "app" {
  name                = "app"
  zone_name           = data.azurerm_dns_zone.fsa.name
  resource_group_name = data.azurerm_resource_group.common.name
  ttl                 = 300
  records             = [data.azurerm_public_ip.pip.ip_address]
}

# keycloak A -> PIP
resource "azurerm_dns_a_record" "keycloak" {
  name                = "keycloak"
  zone_name           = data.azurerm_dns_zone.fsa.name
  resource_group_name = data.azurerm_resource_group.common.name
  ttl                 = 300
  records             = [data.azurerm_public_ip.pip.ip_address]
}

# gitlab A -> PIP
resource "azurerm_dns_a_record" "gitlab" {
  name                = "gitlab"
  zone_name           = data.azurerm_dns_zone.fsa.name
  resource_group_name = data.azurerm_resource_group.common.name
  ttl                 = 300
  records             = [data.azurerm_public_ip.pip.ip_address]
}

# grafana A -> PIP
resource "azurerm_dns_a_record" "grafana" {
  name                = "grafana"
  zone_name           = data.azurerm_dns_zone.fsa.name
  resource_group_name = data.azurerm_resource_group.common.name
  ttl                 = 300
  records             = [data.azurerm_public_ip.pip.ip_address]
}

# prometheus A -> PIP
resource "azurerm_dns_a_record" "prometheus" {
  name                = "prometheus"
  zone_name           = data.azurerm_dns_zone.fsa.name
  resource_group_name = data.azurerm_resource_group.common.name
  ttl                 = 300
  records             = [data.azurerm_public_ip.pip.ip_address]
}

# alloy A -> PIP (gateway pre studentske logy)
resource "azurerm_dns_a_record" "alloy" {
  name                = "alloy"
  zone_name           = data.azurerm_dns_zone.fsa.name
  resource_group_name = data.azurerm_resource_group.common.name
  ttl                 = 300
  records             = [data.azurerm_public_ip.pip.ip_address]
}
