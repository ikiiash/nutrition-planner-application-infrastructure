# GITLAB

## Install

```bash
helm upgrade --install fsa-gitlab -n infra -f ./helm-values/gitlab/values.yaml ./helm-charts/gitlab/1.0.0/
```

## Uninstall

```bash
helm uninstall fsa-gitlab -n infra
```
