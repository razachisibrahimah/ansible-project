#!/bin/bash
#
# This script automatically:
#  1. Loads environment variables from .env
#  2. Validates required environment variables
#  3. Runs your Ansible playbook with the YAML inventory
#  4. Uses Ansible Vault to decrypt group_vars/all.yml
#  5. Eliminates manual exports and ansible-playbook commands
#

ENV_FILE=".env"
PLAYBOOK="vm-playbook.yml"
INVENTORY="inventory/vm-playbook/hosts.yml"

echo "---------------------------------------------------"
echo "  Ansible Automated Playbook Runner"
echo "---------------------------------------------------"

# --------------------------------------------------------
# 1. Ensure .env exists
# --------------------------------------------------------
if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: .env file not found."
  echo "Create a .env file from .env-example and set your values."
  exit 1
fi

# --------------------------------------------------------
# 2. Load environment variables
# --------------------------------------------------------
echo "Loading environment variables from .env..."
export $(grep -v '^#' "$ENV_FILE" | xargs)

# --------------------------------------------------------
# 3. Validate required variables
# --------------------------------------------------------
required_vars=(HOST_IP HOST_USER HOST_KEY PASSWORD)

for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    echo "ERROR: Missing required variable: $var"
    echo "Make sure it is set in your .env file."
    exit 1
  fi
done

echo "All required environment variables found."

# --------------------------------------------------------
# 4. Run Ansible with Vault decryption
# --------------------------------------------------------
echo "Running Ansible playbook..."
ansible-playbook -i "$INVENTORY" "$PLAYBOOK" --ask-vault-pass

echo "---------------------------------------------------"
echo " Playbook execution completed."
echo "---------------------------------------------------"
