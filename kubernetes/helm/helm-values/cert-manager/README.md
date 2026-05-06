# CERT-MANAGER

- https://github.com/cert-manager/cert-manager

## Štruktúra súborov

| Súbor | Popis |
|---|---|
| `values-default.yaml` | Kompletné default values z helm chart 1.20.1 (referencia, nemeniť) |
| `override.yaml` | Len FSA-špecifické zmeny — **tu upravuj hodnoty** |
| `letsencrypt-cluster-issuer.yaml` | ClusterIssuer pre Let's Encrypt (aplikuj po inštalácii) |

## Inštalácia

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm upgrade --install cert-manager jetstack/cert-manager \
  -n cert-manager \
  --version 1.20.1 \
  -f override.yaml

# Po nainštalovaní aplikuj ClusterIssuer
kubectl apply -f letsencrypt-cluster-issuer.yaml
```

## Odinštalácia

```bash
helm delete cert-manager -n cert-manager
kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.20.1/cert-manager.crds.yaml
```
