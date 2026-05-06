# Common Infrastructure
<!-- BEGIN_TF_DOCS -->
## Resources

| Name | Type |
|------|------|
| [azuread_app_role_assignment.grafana_admins](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_app_role_assignment.grafana_editors](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/app_role_assignment) | resource |
| [azuread_application.fsa-gitlab](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application.grafana](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_federated_identity_credential.grafana](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_federated_identity_credential) | resource |
| [azuread_group.grafana_admins](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group) | resource |
| [azuread_group.grafana_editors](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group) | resource |
| [azuread_service_principal.fsa-gitlab](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azuread_service_principal.grafana](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurerm_dns_txt_record.apex](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_txt_record) | resource |
| [azurerm_dns_zone.fsa](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dns_zone) | resource |
| [azurerm_resource_group.rg-common](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [random_uuid.gitlab_oauth_permission_scope](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [random_uuid.grafana_app_role_admin_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [random_uuid.grafana_app_role_editor_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aks_name"></a> [aks\_name](#input\_aks\_name) | Nazov instruktorskeho AKS clustra (pre data source OIDC issuer URL) | `string` | `"aks-fsa"` | no |
| <a name="input_aks_resource_group_name"></a> [aks\_resource\_group\_name](#input\_aks\_resource\_group\_name) | Resource Group instruktorskeho AKS clustra | `string` | `"rg-fsa"` | no |
| <a name="input_dns_zone_name"></a> [dns\_zone\_name](#input\_dns\_zone\_name) | Nazov DNS zony (napr. fullstackacademy.sk) | `string` | n/a | yes |
| <a name="input_grafana_sa_name"></a> [grafana\_sa\_name](#input\_grafana\_sa\_name) | Nazov K8s ServiceAccount pre Grafana (helm release 'monitoring' -> 'monitoring-grafana') | `string` | `"monitoring-grafana"` | no |
| <a name="input_location"></a> [location](#input\_location) | Pouzije sa na vytvorenie resource\_group, ostatne resouces dedia tieto nastavenia. | `string` | `"northeurope"` | no |
| <a name="input_monitoring_namespace"></a> [monitoring\_namespace](#input\_monitoring\_namespace) | K8s namespace pre monitoring stack | `string` | `"monitoring"` | no |
| <a name="input_owners"></a> [owners](#input\_owners) | List of owners for the Azure AD application | `list(string)` | <pre>[<br/>  "f07c709b-a2a4-4538-9b38-3cea737b1a69"<br/>]</pre> | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Nazov Resource Group pre zdielane resources (DNS zona, atd.) | `string` | `"rg-fsa-common"` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Subscription ID | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tagy aplikovane na vsetky resources | `map(string)` | <pre>{<br/>  "managed_by": "terraform",<br/>  "owner": "radovan.pieter@posam.sk",<br/>  "project": "fsa"<br/>}</pre> | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Tenant ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_common_resource_group_name"></a> [common\_resource\_group\_name](#output\_common\_resource\_group\_name) | Nazov Resource Group pre zdielane resources |
| <a name="output_dns_zone_id"></a> [dns\_zone\_id](#output\_dns\_zone\_id) | Resource ID DNS zony |
| <a name="output_dns_zone_name"></a> [dns\_zone\_name](#output\_dns\_zone\_name) | Nazov DNS zony |
| <a name="output_dns_zone_name_servers"></a> [dns\_zone\_name\_servers](#output\_dns\_zone\_name\_servers) | Name servery DNS zony - nastav ich u registrara domeny (jednorazovy krok, nesmie sa menit) |
| <a name="output_grafana_client_id"></a> [grafana\_client\_id](#output\_grafana\_client\_id) | Client ID Grafana App Registration — pouzit ako azure.workload.identity/client-id annotation na K8s ServiceAccount |
| <a name="output_grafana_oauth_client_id"></a> [grafana\_oauth\_client\_id](#output\_grafana\_oauth\_client\_id) | Client ID pre Grafana Azure AD OAuth |
<!-- END_TF_DOCS -->
