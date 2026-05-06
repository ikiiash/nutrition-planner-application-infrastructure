# Nutrition Planner — Setup

This repository is used to publish the Nutrition Planner application to Azure AKS.

## Prerequisites

- Azure CLI
- kubectl
- Helm
- Docker
- access to your Azure subscription / resource group

## 1. Provision Azure resources

Use the Terraform folders in [`../terraform/`](../terraform/README.md) to prepare:

- Resource Group
- Azure Container Registry
- AKS cluster
- Public IP
- PostgreSQL Flexible Server

## 2. Build and push Docker images

Backend:

```sh
cd ../nutrition-planner-application-backend
docker build -t <acr-login-server>/nutrition-planner-backend:latest .
docker push <acr-login-server>/nutrition-planner-backend:latest
```

Frontend:

```sh
cd ../nutrition-planner-application-frontend
docker build -t <acr-login-server>/nutrition-planner-frontend:latest .
docker push <acr-login-server>/nutrition-planner-frontend:latest
```

## 3. Fill placeholders

Update these files before deployment:

- `../kubernetes/workload/02-secrets.yaml`
- `../kubernetes/workload/03-app-backend/deployment.yaml`
- `../kubernetes/workload/04-app-frontend/deployment.yaml`
- `../kubernetes/workload/05-ingress/app-ingress.yaml` or `app-ingress-pip.yaml`
- `../kubernetes/helm/helm-values/ingress-nginx/override.yaml`
- `../kubernetes/helm/helm-values/keycloak/override.yaml`
- `../kubernetes/helm/helm-values/cert-manager/letsencrypt-cluster-issuer.yaml`

## 4. Deploy to AKS

Follow the commands from [`../kubernetes/README.md`](../kubernetes/README.md).

Recommended public URL:

- `https://nutrition-planner.<public-ip>.nip.io`

## 5. What to send to the instructor

- public application URL
- GitHub links to backend, frontend and infrastructure repositories
- read permission for the instructor on all repositories
