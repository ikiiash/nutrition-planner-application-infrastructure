provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}

# -----------------------------------------------------------------------------
# Studenti - nacitane zo students.txt (jeden prefix na riadok, # = komentar)
# -----------------------------------------------------------------------------

locals {
  student_prefixes = [
    for line in split("\n", file("${path.module}/../../cookiecutter/students.txt")) :
    trimspace(line)
    if trimspace(line) != "" && !startswith(trimspace(line), "#")
  ]
}

# -----------------------------------------------------------------------------
# Common Resource Group v studentskej subscription
# -----------------------------------------------------------------------------

resource "azurerm_resource_group" "rg-common" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Automation Account so SystemAssigned identitou
# -----------------------------------------------------------------------------

resource "azurerm_automation_account" "fsa" {
  name                = "fsa-automation"
  location            = azurerm_resource_group.rg-common.location
  resource_group_name = azurerm_resource_group.rg-common.name
  sku_name            = "Basic"

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Contributor na kazdu studentsku RG - aby automation mohol vypinat AKS + PSQL
# -----------------------------------------------------------------------------

resource "azurerm_role_assignment" "automation_contributor" {
  for_each = toset(local.student_prefixes)

  principal_id         = azurerm_automation_account.fsa.identity[0].principal_id
  role_definition_name = "Contributor"
  scope                = "/subscriptions/${var.subscription_id}/resourceGroups/rg-fsa-${each.value}"
}

# -----------------------------------------------------------------------------
# PowerShell Runbook
# -----------------------------------------------------------------------------

resource "azurerm_automation_runbook" "stop_student_infra" {
  name                    = "stop-student-infra"
  location                = azurerm_resource_group.rg-common.location
  resource_group_name     = azurerm_resource_group.rg-common.name
  automation_account_name = azurerm_automation_account.fsa.name
  runbook_type            = "PowerShell"
  log_verbose             = false
  log_progress            = false

  content = templatefile("${path.module}/runbook.ps1.tpl", {
    student_prefixes = local.student_prefixes
  })

  tags = var.tags
}

# -----------------------------------------------------------------------------
# Schedule - denne o 20:00 UTC (22:00 CEST)
# -----------------------------------------------------------------------------

resource "azurerm_automation_schedule" "daily_shutdown" {
  name                    = "daily-2200-cest"
  resource_group_name     = azurerm_resource_group.rg-common.name
  automation_account_name = azurerm_automation_account.fsa.name
  frequency               = "Day"
  interval                = 1
  timezone                = "Europe/Bratislava"
  start_time              = "${formatdate("YYYY-MM-DD", timeadd(timestamp(), "24h"))}T22:00:00+02:00"
  description             = "Denne vypnutie studentskej infrastruktury o 22:00 CEST"
}

# -----------------------------------------------------------------------------
# Napojenie schedule na runbook
# -----------------------------------------------------------------------------

resource "azurerm_automation_job_schedule" "stop_daily" {
  resource_group_name     = azurerm_resource_group.rg-common.name
  automation_account_name = azurerm_automation_account.fsa.name
  schedule_name           = azurerm_automation_schedule.daily_shutdown.name
  runbook_name            = azurerm_automation_runbook.stop_student_infra.name
}
