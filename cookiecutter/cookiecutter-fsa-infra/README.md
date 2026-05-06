# FSA Cookiecutter — Terraform template

Cookiecutter šablóna, ktorá vygeneruje hotový Terraform kód pre Azure infraštruktúru.
Každý študent si spustí jeden príkaz a dostane kompletný, pomenovaný Terraform projekt — **bez toho, aby musel písať kód od nuly**.

---

## Predpoklady

- Python 3 nainštalovaný
- `cookiecutter` CLI nástroj:

```bash
pip install cookiecutter
# alebo
pip3 install cookiecutter
```

---

## Generovanie infraštruktúry

Z koreňa repozitára `FSA-infrastructure` spusti:

```bash
cookiecutter terraform/cookiecutter-fsa-infra/
```

Cookiecutter sa opýta na niekoľko hodnôt — vyplň ich podľa pokynov nižšie.

---

## Premenné — čo vyplniť

| Premenná | Popis | Príklad |
|---|---|---|
| `student_prefix` | Tvoje priezvisko (lowercase, iba pomlčky). Použije sa na pomenovanie všetkých resources. | `novak` |
| `location` | Azure región pre AKS a ostatné resources | `westeurope` |
| `subscription_id` | ID tvojej Azure subscription (nájdeš v portáli alebo `az account show`) | `xxxxxxxx-xxxx-...` |
| `tenant_id` | Azure Tenant ID (nájdeš v portáli → Azure Entra ID) | `xxxxxxxx-xxxx-...` |
| `tfstate_resource_group` | Resource group, kde je uložený Terraform state (vytvorená lektorom) | `rg-tfstate-fsa` |
| `tfstate_storage_account` | Storage account pre Terraform state (dostaneš od lektora) | `stfsapieterr` |
| `tfstate_container` | Container v storage account | `tfstate` |
| `psql_location` | Región pre PostgreSQL (môže sa líšiť od AKS — skús `northeurope` ak `westeurope` nefunguje) | `northeurope` |
| `psql_admin` | Meno administrátora PostgreSQL | `fsaadmin` |
| `psql_password` | Heslo pre PostgreSQL admina | `P@ssword12345!` |
| `node_count` | Počet worker nodov v AKS | `2` |
| `vm_size` | Veľkosť VM pre AKS nody | `Standard_D2s_v5` |

---

## Čo sa vygeneruje

Po spustení vznikne nový priečinok `<student_prefix>-infra/` s kompletným Terraform projektom:

```sh
novak-infra/
├── main.tf           # Definícia všetkých resources (cez moduly)
├── variables.tf      # Definícia premenných
├── outputs.tf        # Výstupy (IP adresy, mená, heslá)
├── terraform.tfvars  # Vyplnené hodnoty z Cookiecutter
└── modules/
    ├── rg/           # Resource Group
    ├── acr/          # Azure Container Registry
    ├── aks/          # Azure Kubernetes Services
    ├── pip/          # Public IP
    └── psql/         # PostgreSQL Flexible Server
```

Vytvorené Azure resources budú pomenované podľa tvojho prefixu:

| Resource | Názov |
|---|---|
| Resource Group | `novak-rg` |
| Container Registry | `novakacrfsa` |
| AKS Cluster | `novak-aks` |
| Public IP | `pip-novak` |
| PostgreSQL Server | `novak-psql` |
| PostgreSQL DB | `keycloak` |
| PostgreSQL DB | `fsa-db` |

---

## Ďalší postup

Po vygenerovaní pokračuj podľa [POSTUP.md](../../POSTUP.md) v koreni repozitára — sekcia **Terraform - postavenie Azure infraštruktúry**.
