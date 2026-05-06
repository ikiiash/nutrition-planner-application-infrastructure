# Resource Groups
<!-- BEGIN_TF_DOCS -->
## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Pouzije sa na vytvorenie resource\_group, ostatne resouces dedia tieto nastavenia. | `string` | `"northeurope"` | no |
| <a name="input_resource_groups"></a> [resource\_groups](#input\_resource\_groups) | Zoznam Resource Groups na vytvorenie | <pre>map(object({<br/>    name = string<br/>  }))</pre> | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Subscription ID | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tagy aplikovane na vsetky resources | `map(string)` | <pre>{<br/>  "managed_by": "terraform",<br/>  "owner": "radovan.pieter@posam.sk",<br/>  "project": "fsa"<br/>}</pre> | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Tenant ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_resource_group_ids"></a> [resource\_group\_ids](#output\_resource\_group\_ids) | Resource ID vytvorenych Resource Groups |
| <a name="output_resource_group_names"></a> [resource\_group\_names](#output\_resource\_group\_names) | Nazvy vytvorenych Resource Groups |
<!-- END_TF_DOCS -->
