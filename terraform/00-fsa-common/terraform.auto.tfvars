# -----------------------------------------------------------------------------
# Azure Subscription and Tenant
# -----------------------------------------------------------------------------

subscription_id = "c92dd394-8e62-4775-9c25-4ce5a5da5938"
tenant_id       = "3590242b-a92d-4bb9-9ff9-eb7a1183f511"

# -----------------------------------------------------------------------------
# Global
# -----------------------------------------------------------------------------

location       = "northeurope"
resource_group = "rg-fsa-common"
dns_zone_name  = "fullstackacademy.sk"

# radovan.pieter@posam.sk -> ObjectID: "f07c709b-a2a4-4538-9b38-3cea737b1a69"
owners = ["f07c709b-a2a4-4538-9b38-3cea737b1a69"]

grafana_sa_name = "kube-prometheus-stack-grafana"
