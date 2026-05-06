#!/usr/bin/env python3
"""
Cookiecutter post-generation hook: vypis nasledujucich krokov po uspesnom vygenerovani projektu.
Spusti sa automaticky po vytvoreni adresarovej struktury.
"""

import os

student_prefix = "{{ cookiecutter.student_prefix }}"
project_dir = os.path.join(os.getcwd(), f"{student_prefix}-infra")

print("\n" + "="*60)
print("  FSA 2026 - Infrastruktura uspesne vygenerovana!")
print("="*60)
print(f"""
Projekt bol vytvoreny v: {project_dir}

PRED SPUSTENIM - overte ze mате:
---------------------------------
[ ] Prihlaseny Azure ucet:
      az login
      az account set --subscription <subscription_id>

[ ] Existujuci Storage Account pre TF state:
      (vytvorte rucne v Azure Portal alebo cez az CLI pred terraform init)
      az group create -n {{ cookiecutter.tfstate_resource_group }} -l {{ cookiecutter.location }}
      az storage account create \\
        --name {{ cookiecutter.tfstate_storage_account }} \\
        --resource-group {{ cookiecutter.tfstate_resource_group }} \\
        --sku Standard_LRS
      az storage container create \\
        --name {{ cookiecutter.tfstate_container }} \\
        --account-name {{ cookiecutter.tfstate_storage_account }} \\
        --auth-mode login

DALSI POSTUP:
-------------
1. Prejdite do adresara projektu:
   cd {student_prefix}-infra/terraform

2. Inicializujte Terraform (pripoji sa na Storage Account backend):
   terraform init

3. Skontrolujte plan - co sa bude vytvarat:
   terraform plan

4. Aplikujte infrastrukturu (POZOR: vytvori Azure resources!):
   terraform apply

PORADIE MODULOV:
----------------
  rg-fsa-{student_prefix}     -> Najskor Resource Group
  acrfsa{student_prefix.replace('-','')}  -> ACR pre Docker images
  aks-fsa-{student_prefix}    -> AKS cluster
  pip-fsa-{student_prefix}    -> Staticka verejná IP (do nodes-fsa-{student_prefix}!)
  psql-fsa-{student_prefix}   -> PostgreSQL Flexible Server + databazy

DOLEZITE POZNAMKY:
------------------
- terraform.tfvars bol automaticky vygenerovany - netreba nic doplnat!
- TF state sa uklada do: {student_prefix}.tfstate v Storage Account
- NIKDY nepushujte terraform.tfvars do Git! (je v .gitignore)
- Po dokonceni si ulozit outputy: terraform output

""")
print("="*60 + "\n")
