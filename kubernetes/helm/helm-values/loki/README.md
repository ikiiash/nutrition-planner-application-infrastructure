# LOKI

- https://github.com/grafana/loki/tree/main/production/helm/loki

> ℹ️ Nasadené v režime **SingleBinary** s lokálnym PVC (filesystem). Loki nie je vystavené navonok — dostupné len interne cez Grafana UI.

## Inštalácia

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm upgrade --install loki grafana/loki \
  -n monitoring \
  --version 6.55.0 \
  -f override.yaml
```

## Odinštalácia

```bash
helm delete loki -n monitoring
```
