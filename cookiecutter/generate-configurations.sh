#!/usr/bin/env bash
# =============================================================================
# generate_configurations.sh
#
# Precita zoznam studentov zo students.txt a pre kazdeho vygeneruje
# infrastrukturny Terraform kod pomocou cookiecutter do priecinka generated/.
#
# Pouzitie:
#   chmod +x generate_configurations.sh
#   ./generate_configurations.sh
#
# Poziadavky:
#   - cookiecutter (pip install cookiecutter)
#   - students.txt v rovnakom priecinku (jeden prefix na riadok)
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/cookiecutter-fsa-infra"
STUDENTS_FILE="$SCRIPT_DIR/students.txt"
OUTPUT_DIR="$SCRIPT_DIR/generated"

# -----------------------------------------------------------------------------
# Kontrola zavislosti
# -----------------------------------------------------------------------------

if ! command -v cookiecutter &>/dev/null; then
  echo "ERROR: cookiecutter nie je nainstalovany."
  echo "       Spusti: pip install cookiecutter"
  exit 1
fi

if [[ ! -f "$STUDENTS_FILE" ]]; then
  echo "ERROR: Subor students.txt neexistuje: $STUDENTS_FILE"
  exit 1
fi

# -----------------------------------------------------------------------------
# Vstupne parametre
# -----------------------------------------------------------------------------

echo "=============================================="
echo " FSA Infrastructure - Generator konfigurácií"
echo "=============================================="
echo ""

read -rp "subscription_id: " SUBSCRIPTION_ID
if [[ -z "$SUBSCRIPTION_ID" ]]; then
  echo "ERROR: subscription_id nesmie byt prazdny."
  exit 1
fi

read -rp "tenant_id:       " TENANT_ID
if [[ -z "$TENANT_ID" ]]; then
  echo "ERROR: tenant_id nesmie byt prazdny."
  exit 1
fi

echo ""

# -----------------------------------------------------------------------------
# Nacitanie studentov (preskoc prazdne riadky a komentare)
# -----------------------------------------------------------------------------

mapfile -t STUDENTS < <(grep -v '^\s*$' "$STUDENTS_FILE" | grep -v '^\s*#')

if [[ ${#STUDENTS[@]} -eq 0 ]]; then
  echo "ERROR: students.txt je prazdny alebo neobsahuje ziadne mena."
  exit 1
fi

echo "Najdenych studentov: ${#STUDENTS[@]}"
printf '  - %s\n' "${STUDENTS[@]}"
echo ""

# -----------------------------------------------------------------------------
# Generovanie konfiguracie pre kazdeho studenta
# -----------------------------------------------------------------------------

mkdir -p "$OUTPUT_DIR"

SUCCESS=0
FAIL=0

for PREFIX in "${STUDENTS[@]}"; do
  PREFIX="$(echo "$PREFIX" | tr -d '[:space:]')"
  TARGET="$OUTPUT_DIR/${PREFIX}-infra"

  echo ">>> Generujem: $PREFIX"

  if [[ -d "$TARGET" ]]; then
    echo "    PRESKAKUJEM - uz existuje: $TARGET"
    echo "    (Zmazni priecinok manualne ak chces regenerovat)"
    continue
  fi

  if cookiecutter "$TEMPLATE_DIR" \
      --no-input \
      --output-dir "$OUTPUT_DIR" \
      student_prefix="$PREFIX" \
      subscription_id="$SUBSCRIPTION_ID" \
      tenant_id="$TENANT_ID"; then
    echo "    OK -> $TARGET"
    SUCCESS=$((SUCCESS + 1))
  else
    echo "    CHYBA pri generovani pre: $PREFIX"
    FAIL=$((FAIL + 1))
  fi

  echo ""
done

# -----------------------------------------------------------------------------
# Zhrnutie
# -----------------------------------------------------------------------------

echo "=============================================="
echo " Hotovo: $SUCCESS OK  |  $FAIL chyb"
echo " Vystup: $OUTPUT_DIR"
echo "=============================================="
