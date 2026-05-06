# =============================================================================
# FSA 2026 DevOps Workshop - Terraform premenne
# Automaticky vygenerovane Cookiecutter-om - netreba nic manualne doplnat.
# NIKDY nepushujte tento subor do Git! (je v .gitignore)
# =============================================================================

subscription_id = "{{ cookiecutter.subscription_id }}"
tenant_id       = "{{ cookiecutter.tenant_id }}"
student_prefix  = "{{ cookiecutter.student_prefix }}"
location        = "{{ cookiecutter.location }}"
environment     = "{{ cookiecutter.environment }}"

# PostgreSQL - moze byt iny region ako AKS (kvoli subscription restricciám)
psql_location = "{{ cookiecutter.psql_location }}"
psql_admin    = "{{ cookiecutter.psql_admin }}"
psql_password = "{{ cookiecutter.psql_password }}"

node_count = "{{ cookiecutter.node_count }}"
vm_size    = "{{ cookiecutter.vm_size }}"
