# =============================================================================
# Modul: Resource Group
# Vytvori Azure Resource Group - "kontajner" pre vsetky ostatne resources
# =============================================================================

resource "azurerm_resource_group" "fsa_rg" {
  name     = var.resource_group
  location = var.location

  tags = var.tags
}
