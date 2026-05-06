# GITLAB-RUNNER

- https://gitlab.com/gitlab-org/charts/gitlab-runner

## Štruktúra súborov

| Súbor | Popis |
|---|---|
| `values-default.yaml` | Kompletné default values z helm chart 0.87.0 (referencia, nemeniť) |
| `override.yaml` | Len FSA-špecifické zmeny — **tu upravuj hodnoty** |

## Prerekvizity

Pred inštaláciou musí existovať secret s runner tokenom:

```bash
kubectl apply -f 02-secrets.yaml
```

Token získaš v GitLab: **Settings → CI/CD → Runners → New project runner**.

## Inštalácia

```bash
helm repo add gitlab https://charts.gitlab.io
helm repo update

helm upgrade --install gitlab-runner -n infra gitlab/gitlab-runner \
  --version 0.87.0 \
  -f override.yaml
```

## Odinštalácia

```bash
helm delete gitlab-runner -n infra
```
