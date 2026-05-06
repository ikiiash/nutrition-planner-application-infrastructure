# Nutrition Planner Infrastructure

Infrastructure repository for deploying the Nutrition Planner application to Microsoft Azure.

This repository contains:

- Azure infrastructure provisioning with Terraform
- AKS deployment manifests for backend, frontend and Keycloak
- ingress and TLS configuration with `ingress-nginx` and `cert-manager`
- observability stack with `Prometheus`, `Grafana`, `Loki` and `Alloy`

## Related repositories

- `nutrition-planner-application-backend`
- `nutrition-planner-application-frontend`
- `nutrition-planner-application-infrastructure`

## Repository structure

- `terraform/` - Azure resource provisioning
- `kubernetes/` - Kubernetes manifests and Helm overrides
- `docs/` - setup notes and supporting documentation

## Deployed Azure components

The deployment is based on:

- Azure Kubernetes Service (`AKS`)
- Azure Container Registry (`ACR`)
- Azure Database for PostgreSQL Flexible Server
- Azure Public IP for ingress

## Application URLs

Production application:

- `https://nutrition-planner.20-166-89-50.nip.io`

Monitoring:

- `https://grafana.20-166-89-50.nip.io`
- `https://prometheus.20-166-89-50.nip.io`

## What is deployed to AKS

- `nutrition-planner-be` - Spring Boot backend
- `nutrition-planner-fe` - Angular frontend served by Nginx
- `nutrition-keycloak` - authentication server
- `ingress-nginx` - public ingress controller
- `cert-manager` - Let's Encrypt certificate automation
- `loki` - log storage
- `kube-prometheus-stack` - Prometheus and Grafana
- `alloy` - metrics and logs collection

## Deployment flow

1. Provision Azure resources from `terraform/`.
2. Build backend and frontend Docker images.
3. Push images to Azure Container Registry.
4. Apply namespaces and secrets from `kubernetes/workload/`.
5. Install infrastructure Helm charts:
   - `ingress-nginx`
   - `cert-manager`
   - `keycloak`
   - `loki`
   - `kube-prometheus-stack`
   - `alloy`
6. Deploy backend, frontend and ingress resources.

## Quick start

From [`kubernetes/`](./kubernetes/):

```sh
kubectl apply -f workload/01-namespace.yaml
kubectl apply -f workload/02-secrets.yaml
```

Then deploy the application stack and monitoring stack using the Helm/value files in:

- `helm/helm-values/ingress-nginx/`
- `helm/helm-values/cert-manager/`
- `helm/helm-values/keycloak/`
- `helm/helm-values/loki/`
- `helm/helm-values/kube-prometheus-stack/`
- `helm/helm-values/grafana-alloy/`

Detailed commands are documented in:

- [kubernetes/README.md](./kubernetes/README.md)
- [docs/SETUP.md](./docs/SETUP.md)

## Checkpoint submission

For checkpoint submission prepare:

- public application URL
- GitHub links to all three project repositories
- read access for the instructor

Recommended submission links:

- App: `https://nutrition-planner.20-166-89-50.nip.io`
- Grafana: `https://grafana.20-166-89-50.nip.io`
- Prometheus: `https://prometheus.20-166-89-50.nip.io`
