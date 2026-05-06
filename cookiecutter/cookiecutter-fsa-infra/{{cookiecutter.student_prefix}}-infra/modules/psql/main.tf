# =============================================================================
# Modul: PostgreSQL Flexible Server
#
# Vytvori:
# 1. PostgreSQL Flexible Server (verzia 16)
# 2. Databazu 'keycloak' - pre Keycloak autentifikacny server
# 3. Databazu 'fsa-db' - pre backend aplikaciu
# 4. Firewall pravidlo - umozni pripojenie z Azure resources
#
# POZNAMKA: Povolenie "Allow Azure services" sa musi nastavit manualne
# v Azure Portali (Network > Allow public access from Azure services)
# Viz: https://github.com/hashicorp/terraform-provider-azurerm/issues/14989
# =============================================================================

resource "azurerm_postgresql_flexible_server" "fsa_psql" {
  name                = var.psql_name
  resource_group_name = var.resource_group
  location            = var.location

  # PostgreSQL verzia 17 (LTS, odporucana pre nove deployments - overena 2026-03-27)
  version = "17"

  # Administrator prihlasovanie
  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  # B_Standard_B1ms - dostatocny pre workshop/lab prostredie
  # Pre produkciu odporucame aspon B_Standard_B2ms
  sku_name = "B_Standard_B1ms"

  # Ulozisko v MB (32 GB)
  storage_mb = 32768

  # Zalozky
  backup_retention_days = 7

  # Availability Zone - nespecifikujeme, Azure vyberie dostupnu zonu automaticky
  # (rozne subscriptions maju rozne dostupne zony, pre workshop nie je kriticke)

  tags = var.tags

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [zone]
  }
}

# -----------------------------------------------------------------------------
# Databaza pre Keycloak autentifikacny server
# -----------------------------------------------------------------------------

resource "azurerm_postgresql_flexible_server_database" "keycloak" {
  name      = "keycloak"
  server_id = azurerm_postgresql_flexible_server.fsa_psql.id
  collation = "en_US.utf8"
  charset   = "utf8"

  lifecycle {
    prevent_destroy = false
  }
}

# -----------------------------------------------------------------------------
# Databaza pre FSA backend aplikaciu
# -----------------------------------------------------------------------------

resource "azurerm_postgresql_flexible_server_database" "fsa_app_db" {
  name      = "fsa-db"
  server_id = azurerm_postgresql_flexible_server.fsa_psql.id
  collation = "sk_SK.utf8"
  charset   = "utf8"

  lifecycle {
    prevent_destroy = false
  }
}

# -----------------------------------------------------------------------------
# Firewall pravidlo - povolenie komunikacie z Azure resources
# Toto umoznuje AKS clustru pristup k PostgreSQL serveru
#
# BEZPECNOSTNA POZNAMKA: Pre workshop pouzivame siroky rozsah (0.0.0.0/255.255.255.255).
# V produkcii obmedzte na konkretny rozsah IP adries AKS nodov.
# -----------------------------------------------------------------------------

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure_services" {
  name             = "allow-azure-services"
  server_id        = azurerm_postgresql_flexible_server.fsa_psql.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}
