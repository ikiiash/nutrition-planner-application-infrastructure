# KUBE-PROMETHEUS-STACK

- https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack

## Konfigurácia

Skopíruj hodnotu do `override.yaml`:

```yaml
grafana:
  serviceAccount:
    annotations:
      azure.workload.identity/client-id: "<grafana_client_id>"
```

## Inštalácia

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  -n monitoring \
  --version 82.17.0 \
  -f override.yaml
```

## Odinštalácia

```bash
helm delete kube-prometheus-stack -n monitoring
kubectl delete crd alertmanagerconfigs.monitoring.coreos.com \
  alertmanagers.monitoring.coreos.com \
  podmonitors.monitoring.coreos.com \
  probes.monitoring.coreos.com \
  prometheusagents.monitoring.coreos.com \
  prometheuses.monitoring.coreos.com \
  prometheusrules.monitoring.coreos.com \
  scrapeconfigs.monitoring.coreos.com \
  servicemonitors.monitoring.coreos.com \
  thanosrulers.monitoring.coreos.com
```
