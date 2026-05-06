# FSA 2026 - Infrastruktura: {{ cookiecutter.student_prefix }}

Tento projekt obsahuje Terraform kod pre vytvorenie Azure infrastruktury pre FSA DevOps Workshop 2026.

## Predpoklady

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.8.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) nainstalovany a prihlaseny
- Pristup k Azure Subscriptionu

## Prihlasenie do Azure

```bash
az login
az account set --subscription "<SUBSCRIPTION_ID>"
```

## Postup spustenia

### 1. Pripravit konfiguracny subor

```bash
cd terraform/
cp terraform.tfvars.example terraform.tfvars
# Upravit terraform.tfvars - doplnit subscription_id a tenant_id
```

### 2. Inicializovat Terraform

```bash
terraform init
```

### 3. Skontrolovat plan (co sa bude vytvarat)

```bash
terraform plan
```

### 4. Aplikovat infrastrukturu

```bash
terraform apply
```

> Terraform sa opyta na potvrdenie. Zadajte `yes` pre pokracovanie.

### 5. Zobrazit vystupy

```bash
terraform output
# Pre citlive hodnoty:
terraform output acr_admin_password
```

## Vytvorene resources

| Resource | Nazov | Popis |
|----------|-------|-------|
| Resource Group | `{{ cookiecutter.student_prefix }}-rg` | Kontajner pre vsetky resources |
| Container Registry | `{{ cookiecutter.student_prefix | replace("-", "") }}acr` | Docker registry |
| AKS Cluster | `{{ cookiecutter.student_prefix }}-aks` | Kubernetes cluster |
| Public IP | `pip-{{ cookiecutter.student_prefix }}` | Staticka IP pre Ingress |
| PostgreSQL Server | `{{ cookiecutter.student_prefix }}-psql` | DB server |
| PostgreSQL DB | `keycloak` | Databaza pre Keycloak |
| PostgreSQL DB | `fsa-db` | Databaza pre aplikaciu |

## Dolezite poznamky

- **Public IP** musi byt v `node_resource_group` AKS (automaticky nastavene)
- **PostgreSQL**: Po vytvoreni je potrebne manualne povolit `Allow Azure services` v Azure Portal > Network
- **ACR + AKS**: Nezabudnite pripojiť ACR k AKS: `az aks update -n <AKS> -g <RG> --attach-acr <ACR>`

## Znisenie infrastruktury (po skonceni workshopu!)

```bash
terraform destroy
```

> POZOR: Toto vymazе VSETKY vytvorene Azure resources!
