# Nutrition Planner Keycloak (keycloakx)

- https://github.com/codecentric/helm-charts/tree/master/charts/keycloakx

## Files

| File | Purpose |
|---|---|
| `values-default.yaml` | Reference defaults from the Helm chart |
| `override.yaml` | Project-specific overrides |
| `keycloak-java-config.yaml` | Azure PostgreSQL certificate workaround |
| `realm-nutrition-configmap.yaml` | Realm import for `NUTRITION` |

## Prerequisites

```sh
kubectl apply -f ../../02-secrets.yaml
kubectl apply -f keycloak-java-config.yaml
kubectl apply -f realm-nutrition-configmap.yaml
```

The imported realm contains:

- realm `NUTRITION`
- client `nutrition-planner-client`
- demo roles `ADMIN`, `USER`, `PREMIUM_USER`
- demo users for smoke testing

## Install

```sh
helm repo add codecentric https://codecentric.github.io/helm-charts
helm repo update

helm upgrade --install keycloak -n app codecentric/keycloakx \
  --version 7.1.9 \
  -f override.yaml
```
