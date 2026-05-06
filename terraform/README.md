# FSA Terraform

Infraštruktúra školiteľa v Azure. Každý priečinok je samostatný `Terraform` projekt so vlastným `state`.

---

## Štruktúra a poradie spúšťania

Projekty sa spúšťajú v poradí — každý závisí od predchádzajúceho.

- [`00-fsa-common/`](./00-fsa-common/) — `Enterprise Application` + `Service Principal` pre GitLab SSO, `rg-fsa-common` (Resource Group), `DNS zóna` `fullstackacademy.sk` + @ TXT záznam — **permanent, nemala by byť zmazaná**.
Pokiaľ sa zmaže, treba skontrolovať Nameservery vo WebSupport admin rozhraní.
- [`01-fsa-rg/`](./01-fsa-rg/) — `Resource Group` `rg-fsa` (hlavná)
- [`02-fsa-acr/`](./02-fsa-acr/) — `Azure Container Registry` (`acrfsa`) v `rg-fsa`
- [`03-fsa-aks/`](./03-fsa-aks/) — `AKS cluster` + napojenie na ACR cez `AcrPull` role assignment
- [`04-fsa-pip/`](./04-fsa-pip/) — `Public IP` v node RG (`mc_rg-fsa`) pre Ingress Controller
- [`05-fsa-psql/`](./05-fsa-psql/) — `PostgreSQL Flexible Server` + databázy `keycloak` a `fsa-db`
- [`06-fsa-dns/`](./06-fsa-dns/) — A záznamy (bez zóny — tá je v `00-fsa-common`)
- [`07-fsa-automation/`](./07-fsa-automation/) — `Azure Automation Account` + `Runbook` pre automatické vypínanie študentskej infraštruktúry o 22:00 CEST

> ⚠️ **`07-fsa-automation` môže používať inú subscription** ako ostatné projekty — nasadzuje sa do **študentskej subscription** (kde sú všetky `rg-fsa-<prefix>`). Ak má školiteľ resources v tej istej subscription ako študenti, toto upozornenie ignoruj. Inak skontroluj `subscription_id` v `07-fsa-automation/terraform.auto.tfvars` pred spustením.

---

## Predpoklady pred prvým spustením

- `Resource Group` `rg-fsa-tfstate` a `Storage Account` `fsafstate` musia existovať pred `terraform init` — slúžia ako `backend` pre `Terraform state`. Vytvor ich ručne cez Azure Portal alebo CLI.
- Prihlásenie do Azure: `az login`

---

## Manuálne kroky po apply

- **`00-fsa-common`** (jednorazovo, nie každý ročník):
  - Vygeneruj `Client Secret` pre Service Principal: Azure Portal → `App Registrations` → `fsa-gitlab` → `Certificates & secrets`. Ulož do 1Password.
  - **NS záznamy** — skopíruj z outputu (`dns_zone_name_servers`) a nastav ich u registrátora domény `fullstackacademy.sk`. Počkaj na propagáciu (~1 hodina). Toto je jednorazový krok — NS záznamy sa nemenia dovtedy, kým DNS zónu nevymažeš.

    ```sh
    terraform output dns_zone_name_servers
    # Príklad výstupu:
    # ns1-01.azure-dns.com.
    # ns2-01.azure-dns.net.
    # ns3-01.azure-dns.org.
    # ns4-01.azure-dns.info.
    # Nastav tieto 4 NS záznamy u registrátora (napr. WebSupport → Správa DNS).
    ```

- **`05-fsa-psql`** — po `apply` povol komunikáciu z Azure services:
  - `<PSQL Resource>` → `Networking` → `Allow public access from any Azure service within Azure to this server` → `Save`.
- **`06-fsa-dns`** — žiadny manuálny krok (recordsety sú automatické).

---

## Secrets

- `psql_admin_password` — **nie je commitnuté**. Pre `05-fsa-psql` sa nastavuje cez `.env` file a spúšťa sa cez 1Password:

---

## Štruktúra súborov (každý projekt)

- `main.tf` — definícia resources
- `variables.tf` — definícia premenných a ich typov
- `terraform.auto.tfvars` — hodnoty premenných (automaticky načítané)
- `output.tf` — výstupy po vytvorení resources
- `versions.tf` — verzia Terraform, provider a `backend` konfigurácia

---

## Spúšťanie

```sh
cd terraform/00-fsa-common
cd terraform/01-fsa-rg
cd terraform/02-fsa-acr
cd terraform/03-fsa-aks
cd terraform/04-fsa-pip
cd terraform/06-fsa-dns
cd terraform/07-fsa-automation

terraform init
terraform plan
terraform apply

cd terraform/05-fsa-psql
op run --env-file=.env terraform plan
op run --env-file=.env terraform apply
```
