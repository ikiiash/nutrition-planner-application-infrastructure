provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

# -----------------------------------------------------------------------------
# Data sources - referencie na existujuce resources
# -----------------------------------------------------------------------------

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

# -----------------------------------------------------------------------------
# PostgreSQL Flexible Server
# -----------------------------------------------------------------------------

resource "azurerm_postgresql_flexible_server" "psql" {
  name                = var.psql_name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  administrator_login    = var.psql_admin_username
  administrator_password = var.psql_admin_password

  sku_name   = var.psql_sku
  version    = var.psql_version
  storage_mb = var.psql_storage_mb

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  tags = var.tags

  lifecycle {
    ignore_changes = [zone]
  }
}

# -----------------------------------------------------------------------------
# Databazy
# -----------------------------------------------------------------------------

resource "azurerm_postgresql_flexible_server_database" "keycloak" {
  name      = "keycloak"
  server_id = azurerm_postgresql_flexible_server.psql.id
  collation = "en_US.utf8"
  charset   = "utf8"

  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_postgresql_flexible_server_database" "app" {
  name      = "fsa-db"
  server_id = azurerm_postgresql_flexible_server.psql.id
  collation = "sk_SK.utf8"
  charset   = "utf8"

  lifecycle {
    prevent_destroy = false
  }
}

# -----------------------------------------------------------------------------
# Firewall rules
# -----------------------------------------------------------------------------

# Povoli plny rozsah IP (vhodne pre workshop / development)
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_all" {
  name             = "allow-all"
  server_id        = azurerm_postgresql_flexible_server.psql.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}
