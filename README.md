# Nutrition Planner Infrastructure

Infrastructure repository for deploying `nutrition-planner-application-backend` and `nutrition-planner-application-frontend` to Azure AKS.

## What is in this repo

- `terraform/` — Azure infrastructure based on the FSA template
- `kubernetes/` — manifests and Helm overrides for AKS deployment
- `docs/` — workshop notes and supporting material

## Azure deployment flow

1. Provision Azure resources from `terraform/`.
2. Build and push backend/frontend Docker images to Azure Container Registry.
3. Replace placeholders in Kubernetes and Helm files.
4. Apply manifests and install Helm charts.

## Recommended public URL

- `https://nutrition-planner.<public-ip>.nip.io`

You can also use your own DNS, for example `https://nutrition-planner.<your-domain>`.

## Checkpoint submission

Prepare:

- a public `IP address / DNS` where the app is published
- GitHub repository links for:
  - `nutrition-planner-application-backend`
  - `nutrition-planner-application-frontend`
  - `nutrition-planner-application-infrastructure`

Grant the instructor read access to all three repositories.
