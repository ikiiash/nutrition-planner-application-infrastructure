#!/usr/bin/env bash
# =============================================================================
# provision_all.sh
#
# Prejde vsetky vygenerovane konfiguracie v generated/ a pre kazdu spusti:
#   terraform init
#   terraform apply -auto-approve
#
# Pouzitie:
#   chmod +x provision_all.sh
#   ./provision_all.sh
#
# Logy su ukladane do logs/<student>-apply.log
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GENERATED_DIR="$SCRIPT_DIR/generated"
LOGS_DIR="$SCRIPT_DIR/logs"

mkdir -p "$LOGS_DIR"

# -----------------------------------------------------------------------------
# Kontrola zavislosti
# -----------------------------------------------------------------------------

if ! command -v terraform &>/dev/null; then
  echo "ERROR: terraform nie je nainstalovany."
  exit 1
fi

# -----------------------------------------------------------------------------
# Nacitanie konfigurácii
# -----------------------------------------------------------------------------

mapfile -t CONFIGS < <(find "$GENERATED_DIR" -maxdepth 1 -mindepth 1 -type d | sort)

if [[ ${#CONFIGS[@]} -eq 0 ]]; then
  echo "ERROR: Ziadne konfiguracie v $GENERATED_DIR"
  echo "       Najprv spusti generate_configurations.sh"
  exit 1
fi

echo "=============================================="
echo " FSA Infrastructure - Provisioning všetkých"
echo "=============================================="
echo ""
echo "Najdenych konfigurácií: ${#CONFIGS[@]}"
printf '  - %s\n' "${CONFIGS[@]##*/}"
echo ""
echo "Logy: $LOGS_DIR"
echo ""

# -----------------------------------------------------------------------------
# Provisioning
# -----------------------------------------------------------------------------

SUCCESS=0
FAIL=0
FAILED_LIST=()

for CONFIG_DIR in "${CONFIGS[@]}"; do
  NAME="${CONFIG_DIR##*/}"
  LOG_FILE="$LOGS_DIR/${NAME}.log"

  echo ">>> [$NAME]"

  # Init
  echo "    terraform init..."
  if ! terraform -chdir="$CONFIG_DIR" init -input=false \
      >> "$LOG_FILE" 2>&1; then
    echo "    CHYBA pri init — pozri: $LOG_FILE"
    FAIL=$((FAIL + 1))
    FAILED_LIST+=("$NAME (init)")
    echo ""
    continue
  fi

  # Apply
  echo "    terraform apply..."
  if ! terraform -chdir="$CONFIG_DIR" apply -auto-approve -input=false \
      >> "$LOG_FILE" 2>&1; then
    echo "    CHYBA pri apply — pozri: $LOG_FILE"
    FAIL=$((FAIL + 1))
    FAILED_LIST+=("$NAME (apply)")
    echo ""
    continue
  fi

  echo "    OK -> log: $LOG_FILE"
  SUCCESS=$((SUCCESS + 1))
  echo ""
done

# -----------------------------------------------------------------------------
# Zhrnutie
# -----------------------------------------------------------------------------

echo "=============================================="
echo " Hotovo: $SUCCESS OK  |  $FAIL chyb"
echo "=============================================="

if [[ ${#FAILED_LIST[@]} -gt 0 ]]; then
  echo ""
  echo "Zlyhali:"
  printf '  - %s\n' "${FAILED_LIST[@]}"
  echo ""
  echo "Pre detail: cat $LOGS_DIR/<student>.log"
  exit 1
fi
