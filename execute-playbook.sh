#!/bin/bash
#
# execute-playbook.sh
# --------------------------------------------------
# This script automatically:
#  1. Loads environment variables from .env
#  2. Validates required environment variables
#  3. Supports multi-environment inventories (dev/staging/prod)
#  4. Supports multi-playbook structure (site.yml, webserver.yml)
#  5. Supports SERVER_MODE=single|proxy and SERVER=apache|nginx
#  6. Supports dry-run mode via: ./execute-playbook.sh --check
#  7. Uses Ansible Vault for decryption
#  8. CHECKS if Ansible is installed (NEW)
# --------------------------------------------------

ENV_FILE=".env"

# Colors for cleaner output
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
RESET="$(tput sgr0)"

# --------------------------------------------------
# 0. Check if Ansible is installed (NEW)
# --------------------------------------------------
if ! command -v ansible-playbook >/dev/null 2>&1; then
  echo "${RED}ERROR:${RESET} Ansible is not installed."
  echo
  echo "Install Ansible using one of the commands below:"
  echo
  echo "${GREEN}macOS (Homebrew):${RESET}"
  echo "  brew install ansible"
  echo
  echo "${GREEN}Ubuntu/Debian:${RESET}"
  echo "  sudo apt update && sudo apt install -y ansible"
  echo
  echo "${GREEN}Windows (WSL2):${RESET}"
  echo "  sudo apt update && sudo apt install -y ansible"
  echo
  exit 1
fi

# --------------------------------------------------
# INPUT ARGUMENTS
# --------------------------------------------------
PLAYBOOK="playbooks/site.yml"
DRY_RUN=""

for arg in "$@"; do
  case "$arg" in
    *.yml) PLAYBOOK="$arg" ;;
    --check) DRY_RUN="--check" ;;
  esac
done

# --------------------------------------------------
# ENVIRONMENT SELECTION
# --------------------------------------------------
ENVIRONMENT="${ENVIRONMENT:-dev}"
INVENTORY="inventory/${ENVIRONMENT}/hosts.yml"

echo "---------------------------------------------------"
echo " ${BLUE}Ansible Automated Playbook Runner${RESET}"
echo "---------------------------------------------------"

# --------------------------------------------------
# Ensure .env exists
# --------------------------------------------------
if [ ! -f "$ENV_FILE" ]; then
  echo "${RED}ERROR:${RESET} .env file not found."
  echo "Create one using: cp .env-example .env"
  exit 1
fi

# --------------------------------------------------
# Load .env without overriding exported values
# --------------------------------------------------
echo "${YELLOW}Loading environment variables from .env...${RESET}"

while IFS='=' read -r key value; do
  [[ -z "$key" || "$key" =~ ^# ]] && continue
  if [ -z "${!key}" ]; then export "$key=$value"; fi
done < "$ENV_FILE"

# --------------------------------------------------
# Validate required environment variables
# --------------------------------------------------
required_vars=(HOST_IP HOST_USER HOST_KEY PASSWORD)

for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    echo "${RED}ERROR:${RESET} Missing required variable: $var"
    exit 1
  fi
done

# --------------------------------------------------
# Display configuration summary
# --------------------------------------------------
echo
echo "${GREEN}Environment:${RESET} $ENVIRONMENT"
echo "${GREEN}Inventory:${RESET}  $INVENTORY"
echo "${GREEN}Playbook:${RESET}   $PLAYBOOK"

[ -n "$SERVER" ] && echo "${GREEN}SERVER:${RESET}      $SERVER"
[ -n "$SERVER_MODE" ] && echo "${GREEN}SERVER_MODE:${RESET} $SERVER_MODE"

echo

# --------------------------------------------------
# Validate inventory file exists
# --------------------------------------------------
if [ ! -f "$INVENTORY" ]; then
  echo "${RED}ERROR:${RESET} Inventory file not found: $INVENTORY"
  exit 1
fi

# --------------------------------------------------
# Validate playbook file exists
# --------------------------------------------------
if [ ! -f "$PLAYBOOK" ]; then
  echo "${RED}ERROR:${RESET} Playbook not found: $PLAYBOOK"
  exit 1
fi

# --------------------------------------------------
# RUN ANSIBLE
# --------------------------------------------------
echo "${BLUE}Running Ansible playbook...${RESET}"

ansible-playbook \
  -i "$INVENTORY" \
  "$PLAYBOOK" \
  -e "target_env=$ENVIRONMENT" \
  $DRY_RUN \
  --ask-vault-pass

STATUS=$?

echo "---------------------------------------------------"
if [ $STATUS -eq 0 ]; then
  echo " ${GREEN}Playbook execution completed successfully.${RESET}"
else
  echo " ${RED}Playbook execution failed. See error above.${RESET}"
fi
echo "---------------------------------------------------"

exit $STATUS
