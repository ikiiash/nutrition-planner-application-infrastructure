# =============================================================================
# Modul: Public IP
#
# KRITICKY DETAIL: Public IP MUSI byt v rovnakej Resource Group ako AKS nody
# (node_resource_group), NIE v hlavnej resource_group!
# Kubernetes ju pouziva pre Ingress Controller (ingress-nginx) na prijem
# externej HTTP/HTTPS prevadzky.
# =============================================================================

resource "azurerm_public_ip" "fsa_pip" {
  name = var.pip_name

  # DOLEZITE: Resource group musi byt node_resource_group z AKS!
  resource_group_name = var.resource_group
  location            = var.location

  # Static alokacia - IP sa nemeni po restarte/redeploy
  allocation_method = "Static"

  # Standard SKU - vyzadovane pre AKS load balancer
  sku = "Standard"

  # DNS label - pristupna ako <dns_label>.<region>.cloudapp.azure.com
  domain_name_label = var.dns_label

  tags = var.tags
}
