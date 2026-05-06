# Public IP
<!-- BEGIN_TF_DOCS -->
## Resources

| Name | Type |
|------|------|
| [azurerm_public_ip.pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aks_name"></a> [aks\_name](#input\_aks\_name) | Nazov existujuceho AKS clustra | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Pouzije sa na vytvorenie resource\_group, ostatne resouces dedia tieto nastavenia. | `string` | `"northeurope"` | no |
| <a name="input_pip_name"></a> [pip\_name](#input\_pip\_name) | Nazov Public IP adresy | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource Group, kde je nasadeny AKS cluster | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Subscription ID | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tagy aplikovane na vsetky resources | `map(string)` | <pre>{<br/>  "managed_by": "terraform",<br/>  "owner": "radovan.pieter@posam.sk",<br/>  "project": "fsa"<br/>}</pre> | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Tenant ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_pip_address"></a> [pip\_address](#output\_pip\_address) | Priradena statická IP adresa |
| <a name="output_pip_id"></a> [pip\_id](#output\_pip\_id) | Resource ID Public IP |
<!-- END_TF_DOCS -->
