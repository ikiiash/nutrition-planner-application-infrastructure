# INGRESS-NGINX

- https://github.com/kubernetes/ingress-nginx/blob/main/README.md
- Co je `reverse proxy`? - https://www.cloudflare.com/en-gb/learning/cdn/glossary/reverse-proxy/

> ⚠️ **ingress-nginx je archived projekt** (od 2026-03-24). Pre nové projekty zvážiť Envoy Gateway + Kubernetes Gateway API.

## Štruktúra súborov

| Súbor | Popis |
|---|---|
| `values-default.yaml` | Kompletné default values z helm chart 4.15.1 (referencia, nemeniť) |
| `override.yaml` | Len FSA-špecifické zmeny — **tu upravuj hodnoty** |

## Príprava pred inštaláciou

Uprav v `override.yaml`:

- `azure-load-balancer-resource-group` — Node Resource Group tvojho AKS clustra (`MC_fsa-<meno>_<region>`)
- `azure-pip-name` — názov Public IP resource (`pip-fsa-<meno>`)

## Inštalácia

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  -n ingress-nginx \
  --version 4.15.1 \
  -f override.yaml
```

## Odinštalácia

```bash
helm delete ingress-nginx -n ingress-nginx
```
