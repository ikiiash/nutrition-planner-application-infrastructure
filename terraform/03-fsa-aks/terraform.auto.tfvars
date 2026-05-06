# -----------------------------------------------------------------------------
# Azure Subscription and Tenant
# -----------------------------------------------------------------------------

subscription_id = "c92dd394-8e62-4775-9c25-4ce5a5da5938"
tenant_id       = "3590242b-a92d-4bb9-9ff9-eb7a1183f511"

# -----------------------------------------------------------------------------
# Global
# -----------------------------------------------------------------------------

resource_group_name = "rg-fsa"
acr_name            = "acrfsa"
aks_name            = "aks-fsa"
aks_version         = "1.34.4"

infra_node_vm_size = "Standard_B2ms"
infra_node_count   = 1

app_node_vm_size = "Standard_B2ms"
app_node_count   = 1
