# Kubernetes deployment

This folder contains the Kubernetes manifests needed to publish the Nutrition Planner application on AKS.

## Main steps

```sh
kubectl apply -f workload/01-namespace.yaml
kubectl apply -f workload/02-secrets.yaml
```

Install ingress controller:

```sh
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  -n ingress-nginx \
  --create-namespace \
  --version 4.15.1 \
  -f helm/helm-values/ingress-nginx/override.yaml
```

Install cert-manager:

```sh
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install cert-manager jetstack/cert-manager \
  -n cert-manager \
  --create-namespace \
  --version 1.20.1 \
  -f helm/helm-values/cert-manager/override.yaml
kubectl apply -f helm/helm-values/cert-manager/letsencrypt-cluster-issuer.yaml
```

Install Keycloak:

```sh
helm repo add codecentric https://codecentric.github.io/helm-charts
helm repo update
kubectl apply -f helm/helm-values/keycloak/keycloak-java-config.yaml
kubectl apply -f helm/helm-values/keycloak/realm-nutrition-configmap.yaml
helm upgrade --install keycloak -n app codecentric/keycloakx \
  --version 7.1.9 \
  -f helm/helm-values/keycloak/override.yaml
```

Deploy application:

```sh
kubectl apply -f workload/03-app-backend/
kubectl apply -f workload/04-app-frontend/
kubectl apply -f workload/05-ingress/app-ingress-pip.yaml
```

## Important placeholders

Replace placeholders before deploy:

- `<your-prefix>`
- `<region>`
- `<your-email@example.com>`
- `<your-domain>` or `<public-ip>.nip.io`
- image names in backend/frontend deployments
