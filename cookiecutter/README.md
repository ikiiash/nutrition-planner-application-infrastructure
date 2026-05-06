# FSA Cookiecutter

Generátor `Terraform` kódu pre študentov. Každý rok sa spustí jeden script, ktorý zo zoznamu mien vygeneruje hotové konfigurácie a provisioning prebehne automaticky.

---

## Štruktúra

- [`cookiecutter-fsa-infra/`](./cookiecutter-fsa-infra/) — `Cookiecutter` šablóna (nemeniť počas ročníka)
- [`students.txt`](./students.txt) — zoznam prefixov študentov (jeden per riadok)
- [`generate_configurations.sh`](./generate_configurations.sh) — vygeneruje `Terraform` kód pre každého študenta do `generated/`
- [`provision_all.sh`](./provision_all.sh) — spustí `terraform init` + `terraform apply` pre každú vygenerovanú konfiguráciu
- `generated/` — vygenerované konfigurácie (commitnuté v branch daného ročníka)
- `logs/` — logy z provisioning (necommituje sa)

---

## Postup pre nový ročník

### 1. Vytvor novú branch

```sh
git checkout master
git checkout -b fsa-<rok>
```

### 2. Doplň `students.txt`

- Jeden prefix na riadok, iba malé písmená a pomlčky.
- Prázdne riadky a riadky začínajúce `#` sú ignorované.

```sh
# FSA 2027
novakj
horcickar
svobodap
```

### 3. Vygeneruj konfigurácie

```sh
./generate_configurations.sh
# Opýta sa na subscription_id a tenant_id
# Vygeneruje generated/<prefix>-infra/ pre každého študenta
```

- Ak priečinok už existuje, script ho preskočí — bezpečné spustiť opakovane.

### 4. Spusti provisioning

```sh
./provision_all.sh
# Spustí terraform init + apply pre každého študenta sekvenčne
# Logy sú v logs/<prefix>-infra.log
```

- AKS trvá ~5 minút na študenta → pre 9 študentov počítaj ~45 minút.
- Po skončení skontroluj výstup — script vypíše zoznam prípadných chýb.

### 5. Manuálne kroky po provisioning

- Pre každého študenta povoľ v Azure Portal prístup z Azure services na PSQL:
  - `psql-fsa-<prefix>` → `Networking` → `Allow public access from any Azure service within Azure to this server` → `Save`.
- Každému študentovi priraď `Contributor` rolu na jeho `Resource Group`:
  - `rg-fsa-<prefix>` → `Access control (IAM)` → `Add role assignment` → `Contributor` → vyber UPN študenta → `Save`.

### 6. Commitni vygenerované konfigurácie

```sh
git add cookiecutter/generated/
git add cookiecutter/students.txt
git commit -m "fsa-<rok>: vygenerovane konfiguracie"
git push origin fsa-<rok>
```

---

## Konvencia pomenúvania resources

Pre prefix `novakj` sa vytvoria:

| Resource | Názov |
|----------|-------|
| Resource Group | `rg-fsa-novakj` |
| Container Registry | `acrfsanovakj` |
| AKS Cluster | `aks-fsa-novakj` |
| Public IP | `pip-fsa-novakj` |
| PostgreSQL Server | `psql-fsa-novakj` |
| TF state key | `2027/novakj/terraform.tfstate` |

---

## Úprava šablóny

- Šablóna sa nachádza v [`cookiecutter-fsa-infra/`](./cookiecutter-fsa-infra/).
- Po každej zmene šablóny treba vymazať `generated/` a spustiť `generate_configurations.sh` znovu.
- Defaultné hodnoty premenných sú v [`cookiecutter-fsa-infra/cookiecutter.json`](./cookiecutter-fsa-infra/cookiecutter.json).
