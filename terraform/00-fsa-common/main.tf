provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

provider "azuread" {
  tenant_id = var.tenant_id
}

# -----------------------------------------------------------------------------
# Resource Group pre zdielane resources (DNS zona, atd.)
# -----------------------------------------------------------------------------

resource "azurerm_resource_group" "rg-common" {
  name     = var.resource_group
  location = var.location

  tags = var.tags
}

# -----------------------------------------------------------------------------
# DNS zona
# Po prvom apply: skopiruj NS zaznamy z outputu a nastav ich u registratora
# -----------------------------------------------------------------------------

resource "azurerm_dns_zone" "fsa" {
  name                = var.dns_zone_name
  resource_group_name = azurerm_resource_group.rg-common.name

  tags = var.tags
}

# @ TXT - popis domeny / ownership
resource "azurerm_dns_txt_record" "apex" {
  name                = "@"
  zone_name           = azurerm_dns_zone.fsa.name
  resource_group_name = azurerm_resource_group.rg-common.name
  ttl                 = 300

  record {
    value = "posam.sk/fullstack"
  }
}

# -----------------------------------------------------------------------------
# Azure AD Application and Service Principal for Gitlab
# -----------------------------------------------------------------------------

resource "random_uuid" "gitlab_oauth_permission_scope" {}

resource "azuread_application" "fsa-gitlab" {
  display_name = "fsa-gitlab"
  owners       = var.owners
  description  = "Pouziva sa pre Gitlab pre FullStackAcademy"

  web {
    homepage_url  = "https://gitlab.fullstackacademy.sk"
    redirect_uris = ["https://gitlab.fullstackacademy.sk/users/auth/openid_connect/callback"]
  }

  api {
    mapped_claims_enabled          = true
    requested_access_token_version = 2

    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access Gitlab on behalf of the signed-in user."
      admin_consent_display_name = "Access Gitlab"
      enabled                    = true
      id                         = random_uuid.gitlab_oauth_permission_scope.result
      user_consent_description   = "Allow the application to access Gitlab on your behalf."
      user_consent_display_name  = "Access Gitlab"
      value                      = "user_impersonation"
    }
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph API

    resource_access {
      # openid - https://learn.microsoft.com/en-us/graph/permissions-reference#openid
      id   = "37f7f235-527c-4136-accd-4a02d197296e"
      type = "Scope"
    }

    resource_access {
      # profile - https://learn.microsoft.com/en-us/graph/permissions-reference#profile
      id   = "14dad69e-099b-42c9-810b-d002981feec1"
      type = "Scope"
    }

    resource_access {
      # email - https://learn.microsoft.com/en-us/graph/permissions-reference#email
      id   = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0"
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "fsa-gitlab" {
  client_id   = azuread_application.fsa-gitlab.client_id
  owners      = var.owners
  description = "Pouziva sa pre Gitlab pre FullStackAcademy"
}

# -----------------------------------------------------------------------------
# Grafana: Azure AD OAuth Application
# -----------------------------------------------------------------------------

resource "random_uuid" "grafana_app_role_admin_id" {}
resource "random_uuid" "grafana_app_role_editor_id" {}

resource "azuread_application" "grafana" {
  display_name     = "fsa-grafana"
  owners           = var.owners
  sign_in_audience = "AzureADMyOrg"

  web {
    homepage_url = "https://grafana.fullstackacademy.sk"
    redirect_uris = [
      "https://grafana.fullstackacademy.sk/login/azuread",
      "https://grafana.fullstackacademy.sk/",
    ]
  }

  # Groups claim — potrebné pre mapovanie Azure AD skupín na Grafana roly
  group_membership_claims = ["SecurityGroup"]

  optional_claims {
    access_token {
      name = "groups"
    }
    id_token {
      name = "groups"
    }
    saml2_token {
      name = "groups"
    }
  }

  # App Roles — mapujú sa na Grafana roly cez role_attribute_path
  app_role {
    id                   = random_uuid.grafana_app_role_admin_id.result
    value                = "Admin"
    display_name         = "Grafana Admin"
    description          = "Plný prístup do Grafana"
    allowed_member_types = ["User"]
    enabled              = true
  }

  app_role {
    id                   = random_uuid.grafana_app_role_editor_id.result
    value                = "Editor"
    display_name         = "Grafana Editor"
    description          = "Úprava dashboardov v Grafana"
    allowed_member_types = ["User"]
    enabled              = true
  }

  lifecycle {
    ignore_changes = [
      identifier_uris,
      api[0].oauth2_permission_scope,
    ]
  }
}

resource "azuread_service_principal" "grafana" {
  client_id = azuread_application.grafana.client_id
  owners    = var.owners
}

# -----------------------------------------------------------------------------
# Grafana: Azure AD Groups + App Role Assignments
# -----------------------------------------------------------------------------

resource "azuread_group" "grafana_admins" {
  display_name     = "fsa-grafana-admins"
  security_enabled = true
  owners           = var.owners
}

resource "azuread_group" "grafana_editors" {
  display_name     = "fsa-grafana-editors"
  security_enabled = true
  owners           = var.owners
}

resource "azuread_app_role_assignment" "grafana_admins" {
  app_role_id         = random_uuid.grafana_app_role_admin_id.result
  principal_object_id = azuread_group.grafana_admins.object_id
  resource_object_id  = azuread_service_principal.grafana.object_id
}

resource "azuread_app_role_assignment" "grafana_editors" {
  app_role_id         = random_uuid.grafana_app_role_editor_id.result
  principal_object_id = azuread_group.grafana_editors.object_id
  resource_object_id  = azuread_service_principal.grafana.object_id
}

# -----------------------------------------------------------------------------
# Grafana: Workload Identity (Federated Credential priamo na App Registration)
# -----------------------------------------------------------------------------

data "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  resource_group_name = var.aks_resource_group_name
}

resource "azuread_application_federated_identity_credential" "grafana" {
  application_id = azuread_application.grafana.id
  display_name   = "grafana-k8s-federated"

  issuer    = data.azurerm_kubernetes_cluster.aks.oidc_issuer_url
  subject   = "system:serviceaccount:${var.monitoring_namespace}:${var.grafana_sa_name}"
  audiences = ["api://AzureADTokenExchange"]
}
