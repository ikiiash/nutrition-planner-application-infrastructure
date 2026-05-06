# Alloy student agent — testovací setup

Testovacia sada pre overenie zberu metrik a logov zo študentského clustra a ich
forwarding na inštruktorský monitoring stack (Prometheus + Loki + Grafana).

## Čo je tu

| Súbor | Popis |
|-------|-------|
| `manifest.yaml` | Deployment + Service — dummy app generujúca metriky (`:9102/metrics`) a JSON logy |
| `alloy.yaml` | Helm values pre Grafana Alloy agent — scrape + forward na inštruktorský cluster |
| `README.md` | Tento súbor |

## Architektúra

```text
[Student AKS]                         [Instructor AKS]
  dummy-app
  (metriky :9102/metrics, JSON logy)
      ↓ scrape (prometheus annotations)
  Alloy agent
  + label: student="PREFIX"
      ↓ remote_write  →  https://prometheus.fullstackacademy.sk/api/v1/write
      ↓ loki push     →  https://alloy.fullstackacademy.sk/loki/api/v1/push
                                  ↓
                             Grafana — filter: student="PREFIX"
```

## Predpoklady

- `kubectl` nakonfigurovaný na študentský AKS cluster
- `helm` nainštalovaný (`helm version`)
- Prístup na inštruktorský cluster overený (Grafana dostupná)

---

## Inštalácia

### 1. Nasaď dummy appku

```bash
kubectl apply -f manifest.yaml
kubectl rollout status deployment/dummy-app -n app
```

### 2. Uprav STUDENT_PREFIX v alloy.yaml

V súbore `alloy.yaml` zmeň dva riadky:

```yaml
- name: STUDENT_PREFIX
  value: "pieterr"      # skutočný prefix študenta
- name: CLUSTER_NAME
  value: "aks-pieterr"  # aks-<prefix>
```

### 3. Nainštaluj Alloy cez Helm

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm upgrade --install alloy-student grafana/alloy \
  --namespace monitoring \
  --create-namespace \
  -f alloy.yaml
```

### 4. Over že Alloy beží

```bash
kubectl get pods -n monitoring
kubectl logs -n monitoring -l app.kubernetes.io/name=alloy --tail=50
```

---

## Overenie v Grafane

**Metriky** — Grafana → Explore → Prometheus:

```promql
up{student="pieterr"}
```

**Logy** — Grafana → Explore → Loki:

```logql
{student="pieterr"}
```

---

## Swap za reálnu Spring Boot appku

Keď budú študenti nasadzovať svoju vlastnú appku, stačí v `manifest.yaml` zmeniť:

```yaml
image: <PREFIX>acr.azurecr.io/backend:<TAG>
# a anotácie:
prometheus.io/port: "8080"
prometheus.io/path: "/actuator/prometheus"
```

Alloy konfigurácia (`alloy.yaml`) zostáva rovnaká — riadi sa len anotáciami podu.

---

## Cleanup

```bash
kubectl delete -f manifest.yaml
helm uninstall alloy-student -n monitoring
```
