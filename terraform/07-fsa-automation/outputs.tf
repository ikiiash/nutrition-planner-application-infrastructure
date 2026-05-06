output "automation_account_id" {
  description = "Resource ID Automation Accountu"
  value       = azurerm_automation_account.fsa.id
}

output "automation_identity_principal_id" {
  description = "Principal ID SystemAssigned identity (pouziva sa pre role assignments)"
  value       = azurerm_automation_account.fsa.identity[0].principal_id
}
