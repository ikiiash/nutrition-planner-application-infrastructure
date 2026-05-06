# GRAFANA-ALLOY

- https://github.com/grafana/alloy

## Prerekvizity

Loki musí byť nainštalované a dostupné na `http://loki.monitoring.svc.cluster.local:3100`.

## Inštalácia

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm upgrade --install alloy grafana/alloy \
  -n monitoring \
  --version 1.7.0 \
  -f override.yaml
```

## Odinštalácia

```bash
helm delete alloy -n monitoring
```
