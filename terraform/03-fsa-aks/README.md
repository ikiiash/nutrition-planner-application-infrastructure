# Azure Kubernetes Service
<!-- BEGIN_TF_DOCS -->
## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.app](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_role_assignment.aks_acr_pull](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acr_name"></a> [acr\_name](#input\_acr\_name) | Nazov existujuceho ACR pre napojenie AcrPull | `string` | n/a | yes |
| <a name="input_aks_name"></a> [aks\_name](#input\_aks\_name) | Nazov AKS clustra | `string` | n/a | yes |
| <a name="input_aks_version"></a> [aks\_version](#input\_aks\_version) | Verzia AKS clustra | `string` | n/a | yes |
| <a name="input_app_node_count"></a> [app\_node\_count](#input\_app\_node\_count) | Pocet nodov v app nodepoole | `number` | `1` | no |
| <a name="input_app_node_vm_size"></a> [app\_node\_vm\_size](#input\_app\_node\_vm\_size) | VM size pre app nodepool | `string` | `"Standard_B2ms"` | no |
| <a name="input_infra_node_count"></a> [infra\_node\_count](#input\_infra\_node\_count) | Pocet nodov v infra nodepoole | `number` | `1` | no |
| <a name="input_infra_node_vm_size"></a> [infra\_node\_vm\_size](#input\_infra\_node\_vm\_size) | VM size pre infra (default) nodepool | `string` | `"Standard_D2s_v5"` | no |
| <a name="input_node_pool_drain_timeout"></a> [node\_pool\_drain\_timeout](#input\_node\_pool\_drain\_timeout) | Drain timeout in minutes for node pool | `number` | `30` | no |
| <a name="input_node_pool_max_surge"></a> [node\_pool\_max\_surge](#input\_node\_pool\_max\_surge) | Max surge for node pool | `number` | `1` | no |
| <a name="input_node_pool_soak_duration"></a> [node\_pool\_soak\_duration](#input\_node\_pool\_soak\_duration) | Node soak duration in minutes for node pool | `number` | `30` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource Group, do ktorej sa AKS vytvori | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Subscription ID | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tagy aplikovane na vsetky resources | `map(string)` | <pre>{<br/>  "managed_by": "terraform",<br/>  "owner": "radovan.pieter@posam.sk",<br/>  "project": "fsa"<br/>}</pre> | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Tenant ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aks_fqdn"></a> [aks\_fqdn](#output\_aks\_fqdn) | FQDN AKS clustra |
| <a name="output_aks_id"></a> [aks\_id](#output\_aks\_id) | Resource ID AKS clustra |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Kubeconfig pre pristup ku clustru |
| <a name="output_kubelet_identity_object_id"></a> [kubelet\_identity\_object\_id](#output\_kubelet\_identity\_object\_id) | Object ID kubelet managed identity (pouziva sa pre RBAC/ACR) |
<!-- END_TF_DOCS -->
