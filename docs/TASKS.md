# FSA 2026 — Úlohy po workshope

Toto sú úlohy pre tých, ktorí chcú ísť nad rámec workshopu a precvičiť si nadobudnuté znalosti samostatne.
Úlohy sú zoradené od jednoduchších po zložitejšie.

**Povinná úloha:** úloha označená ⭐ je povinná pre všetkých — bez jej splnenia nie je možné absolvovať checkpoint.
**Výber 1 z ostatných:** okrem povinnej úlohy musíš splniť aspoň 1 ďalšiu úlohu podľa vlastného výberu.
**Bonus:** každá ďalšia splnená úloha pomôže k hodnoteniu pri prezentácií záverečného projektu.

---

## ⭐ 1. Vlastná doména cez nip.io + TLS certifikát

**Kontext:**
Na workshope sme nakonfigurovali cert-manager a ingress-nginx na inštruktorskom clustri s verejnou doménou.
Tvoj AKS cluster má verejnú IP adresu pridelenú `ingress-nginx` LoadBalancerom — pomocou služby [nip.io](https://nip.io)
vieš z tejto IP vytvoriť plnohodnotnú doménu bez registrácie.

**Cieľ:**
Nakonfigurovať ingress-nginx + cert-manager tak, aby tvoje aplikácie bežali na HTTPS doméne vo formáte
`<app>.<IP>.nip.io` s platným Let's Encrypt certifikátom.

**Postup:**

1. Zisti externú IP adresu `ingress-nginx` LoadBalanceru:

   ```bash
   kubectl get svc -n ingress-nginx ingress-nginx-controller
   # EXTERNAL-IP -> napr. 20.123.45.67
   ```

2. Vytvor `ClusterIssuer` pre Let's Encrypt (HTTP-01 challenge):

   ```yaml
   apiVersion: cert-manager.io/v1
   kind: ClusterIssuer
   metadata:
     name: letsencrypt-prod
   spec:
     acme:
       server: https://acme-v02.api.letsencrypt.org/directory
       email: <tvoj-email>
       privateKeySecretRef:
         name: letsencrypt-prod
       solvers:
         - http01:
             ingress:
               class: nginx
   ```

3. Aktualizuj Ingress manifesty aplikácií — nastav `host: <app>.20.123.45.67.nip.io`
   a pridaj anotáciu `cert-manager.io/cluster-issuer: letsencrypt-prod`
4. Overiť, že certifikát bol vydaný: `kubectl get certificate -A`
5. Aktualizuj Keycloak redirect URIs pre `fsa-client` na nové nip.io domény

**Výsledok:** Aplikácia beží na `https://app.20.123.45.67.nip.io` s platným TLS certifikátom.

---

## 2. Automatizovaný deploy cez GitLab CI/CD

**Kontext:**
Pipeline v aplikačnom repozitári aktuálne zvláda build a push Docker image do ACR.
Deploy do AKS je zakomentovaný, lebo K8s manifesty sa nachádzajú v separátnom repozitári (`FSA-infrastructure`).

**Cieľ:**
Rozšíriť pipeline o `deploy` stage, ktorý po úspešnom builde automaticky nasadí novú verziu aplikácie do AKS.

**Postup (návrh):**

1. V GitLab projekte `FSA-infrastructure` pridaj `CI_JOB_TOKEN` prístup pre aplikačný repozitár:
   `Settings → CI/CD → Token Access → Allow CI job token access`
2. V `deploy` stage naklonovaj `FSA-infrastructure` repo pomocou `CI_JOB_TOKEN`:

   ```yaml
   git clone https://gitlab-ci-token:${CI_JOB_TOKEN}@gitlab.fullstackacademy.sk/...
   ```

3. Aplikuj manifesty pomocou `kubectl apply -f k8s/`
4. Overiť, že nová verzia bežia v AKS: `kubectl rollout status deployment/<name>`

---

## 3. Liveness a Readiness Proby

**Kontext:**
V K8s deployment manifestoch sú liveness a readiness proby zakomentované —
aplikácia aktuálne nemá health check endpoint.

**Cieľ:**
Pridať health check endpoint do BE aplikácie a aktivovať K8s proby.

**Postup (návrh):**

1. Pridaj do BE aplikácie health check endpoint (napr. `GET /actuator/health` ak používaš Spring Boot Actuator, alebo vlastný `GET /health`)
2. Endpoint musí vrátiť HTTP 200 ak je aplikácia zdravá
3. V deployment manifeste odkomentuj a nakonfiguruj proby:

   ```yaml
   livenessProbe:
     httpGet:
       path: /health
       port: 8080
     initialDelaySeconds: 30
     periodSeconds: 10
   readinessProbe:
     httpGet:
       path: /health
       port: 8080
     initialDelaySeconds: 15
     periodSeconds: 5
   ```

4. Overiť správanie — čo sa stane ak aplikácia prestane odpovedať?

---

## 4. Napojenie aplikácie na centrálny monitoring

**Kontext:**
Inštruktorský cluster beží Prometheus + Loki + Grafana.
Alloy agent na inštruktorskom clustri slúži ako push gateway pre logy a metriky z externých clustrov.

**Cieľ:**
Nakonfigurovať vlastný Alloy agenta na študentskom clustri tak, aby:

- zberal metriky z aplikácie a posielal ich do inštruktorského Prometheu
- zberal logy z aplikácie a posielal ich do inštruktorského Loki

**Postup (návrh):**

1. Nainštaluj Grafana Alloy na svoj AKS cluster (helm chart `grafana/alloy`)
2. Nakonfiguruj `loki.write` aby posielal logy na:
   `https://alloy.fullstackacademy.sk/loki/api/v1/push`
3. Nakonfiguruj `prometheus.remote_write` aby posielal metriky na inštruktorský Prometheus
4. Overiť v Grafane, že logy a metriky z tvojej aplikácie sú viditeľné

---

*Ďalšie úlohy budú pribudávať...*
