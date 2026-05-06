#!/usr/bin/env python3
"""
Cookiecutter pre-generation hook: validacia vstupnych hodnot pred generovanim projektu.
Spusti sa automaticky pred vytvorenim adresarovej struktury.
"""

import sys
import re

# Nacitanie premennych z cookiecutter kontextu
student_prefix = "{{ cookiecutter.student_prefix }}"
subscription_id = "{{ cookiecutter.subscription_id }}"
tenant_id = "{{ cookiecutter.tenant_id }}"
psql_password = "{{ cookiecutter.psql_password }}"
node_count = "{{ cookiecutter.node_count }}"
vm_size = "{{ cookiecutter.vm_size }}"

errors = []

# -----------------------------------------------------------------------
# Validacia student_prefix
# -----------------------------------------------------------------------
# Musi obsahovat iba male pismena, cislice a pomlcky
# Nesmie zacinat ani koncit pomlckou
if not re.match(r'^[a-z0-9][a-z0-9\-]{2,20}[a-z0-9]$', student_prefix):
    errors.append(
        f"CHYBA: 'student_prefix' musi mat 4-22 znakov, obsahovat iba male pismena, "
        f"cislice a pomlcky, a nesmie zacinat ani koncit pomlckou. "
        f"Zadana hodnota: '{student_prefix}'"
    )

# -----------------------------------------------------------------------
# Validacia UUID formatu pre subscription_id a tenant_id
# -----------------------------------------------------------------------
uuid_pattern = re.compile(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
)

if not uuid_pattern.match(subscription_id):
    errors.append(
        f"CHYBA: 'subscription_id' musi byt platne UUID (napr. xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx). "
        f"Zadana hodnota: '{subscription_id}'"
    )

if not uuid_pattern.match(tenant_id):
    errors.append(
        f"CHYBA: 'tenant_id' musi byt platne UUID (napr. xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx). "
        f"Zadana hodnota: '{tenant_id}'"
    )

# -----------------------------------------------------------------------
# Validacia hesla pre PostgreSQL
# -----------------------------------------------------------------------
# Azure vyzaduje aspon 8 znakov, velke, male pismena, cislice a specialny znak
if len(psql_password) < 8:
    errors.append(
        f"CHYBA: 'psql_password' musi mat aspon 8 znakov. "
        f"Aktualna dlzka: {len(psql_password)}"
    )

# -----------------------------------------------------------------------
# Validacia poctu nodov
# -----------------------------------------------------------------------
try:
    nc = int(node_count)
    if nc < 1 or nc > 5:
        errors.append(
            f"CHYBA: 'node_count' musi byt medzi 1 a 5. Zadana hodnota: '{node_count}'"
        )
except ValueError:
    errors.append(
        f"CHYBA: 'node_count' musi byt cele cislo. Zadana hodnota: '{node_count}'"
    )

# -----------------------------------------------------------------------
# Validacia ACR nazvu (vypocitany z student_prefix)
# Azure ACR: iba lowercase alphanumeric, 5-50 znakov, globalne unikatny
# -----------------------------------------------------------------------
acr_name = "acrfsa" + student_prefix.replace("-", "")
if not re.match(r'^[a-z][a-z0-9]{4,49}$', acr_name):
    errors.append(
        f"CHYBA: Vypocitany nazov ACR '{acr_name}' nesplna Azure obmedzenia. "
        f"Musi byt 5-50 znakov, iba male pismena a cislice, zacinat pismenom. "
        f"Skratte svoje meno (student_prefix)."
    )
elif len(acr_name) > 50:
    errors.append(
        f"CHYBA: Vypocitany nazov ACR '{acr_name}' ({len(acr_name)} znakov) je prilis dlhy. "
        f"Azure limit je 50 znakov. Skratte student_prefix na max 44 znakov."
    )

# -----------------------------------------------------------------------
# Validacia vm_size
# -----------------------------------------------------------------------
allowed_vm_sizes = [
    "Standard_B2s_v2", "Standard_B2ms_v2", "Standard_B4ms",
    "Standard_D2s_v3", "Standard_D4s_v3",
    "Standard_D2s_v5", "Standard_D4s_v5",
    "Standard_D2as_v5", "Standard_D4as_v5"
]
if vm_size not in allowed_vm_sizes:
    errors.append(
        f"CHYBA: 'vm_size' musi byt jedna z hodnot: {', '.join(allowed_vm_sizes)}. "
        f"Zadana hodnota: '{vm_size}'"
    )

# -----------------------------------------------------------------------
# Vypis chyb a ukoncenie pri neuspesnej validacii
# -----------------------------------------------------------------------
if errors:
    print("\n" + "="*60)
    print("COOKIECUTTER VALIDACIA ZLYHALA:")
    print("="*60)
    for err in errors:
        print(f"  - {err}")
    print("="*60 + "\n")
    sys.exit(1)

print(f"\n[OK] Validacia prebehla uspesne pre projekt: {student_prefix}")
