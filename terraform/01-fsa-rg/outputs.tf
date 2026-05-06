output "resource_group_names" {
  description = "Nazvy vytvorenych Resource Groups"
  value       = { for k, rg in azurerm_resource_group.rg : k => rg.name }
}

output "resource_group_ids" {
  description = "Resource ID vytvorenych Resource Groups"
  value       = { for k, rg in azurerm_resource_group.rg : k => rg.id }
}
