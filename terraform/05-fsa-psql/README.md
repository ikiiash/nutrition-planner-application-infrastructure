# PostgreSQL flexible server
<!-- BEGIN_TF_DOCS -->
## Resources

| Name | Type |
|------|------|
| [azurerm_postgresql_flexible_server.psql](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server) | resource |
| [azurerm_postgresql_flexible_server_database.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_database) | resource |
| [azurerm_postgresql_flexible_server_database.keycloak](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_database) | resource |
| [azurerm_postgresql_flexible_server_firewall_rule.allow_all](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server_firewall_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_psql_admin_password"></a> [psql\_admin\_password](#input\_psql\_admin\_password) | Admin heslo pre PSQL | `string` | n/a | yes |
| <a name="input_psql_admin_username"></a> [psql\_admin\_username](#input\_psql\_admin\_username) | Admin username pre PSQL | `string` | n/a | yes |
| <a name="input_psql_name"></a> [psql\_name](#input\_psql\_name) | Nazov PostgreSQL Flexible Server | `string` | n/a | yes |
| <a name="input_psql_sku"></a> [psql\_sku](#input\_psql\_sku) | SKU pre PSQL (napr. B\_Standard\_B1ms, GP\_Standard\_D2s\_v3) | `string` | `"B_Standard_B1ms"` | no |
| <a name="input_psql_storage_mb"></a> [psql\_storage\_mb](#input\_psql\_storage\_mb) | Velkost uloziska v MB (min 32768) | `number` | `32768` | no |
| <a name="input_psql_version"></a> [psql\_version](#input\_psql\_version) | Verzia PostgreSQL | `string` | `"16"` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource Group, do ktorej sa PSQL vytvori | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Subscription ID | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tagy aplikovane na vsetky resources | `map(string)` | <pre>{<br/>  "managed_by": "terraform",<br/>  "owner": "radovan.pieter@posam.sk",<br/>  "project": "fsa"<br/>}</pre> | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Tenant ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_psql_admin_login"></a> [psql\_admin\_login](#output\_psql\_admin\_login) | Admin login pre PSQL |
| <a name="output_psql_fqdn"></a> [psql\_fqdn](#output\_psql\_fqdn) | FQDN PostgreSQL servera |
| <a name="output_psql_name"></a> [psql\_name](#output\_psql\_name) | Nazov PostgreSQL servera |
<!-- END_TF_DOCS -->
