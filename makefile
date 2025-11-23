.PHONY: help env check run vault-encrypt vault-decrypt vault-edit clean

# -------------------------------------
#  Project Variables
# -------------------------------------
ENV_FILE=.env
ENV_EXAMPLE=.env-example
RUN_SCRIPT=./execute-playbook.sh
INVENTORY=inventory/vm-playbook/hosts.yml
PLAYBOOK=vm-playbook.yml

help: ## Show help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

# -------------------------------------
#  Environment Setup
# -------------------------------------

env:
	@if [ -f $(ENV_FILE) ]; then \
		echo "ERROR: $(ENV_FILE) already exists. Remove it manually if you want to recreate it."; \
		exit 1; \
	fi
	cp $(ENV_EXAMPLE) $(ENV_FILE)
	echo ".env created."

check: ## Validate required environment variables from .env
	@[ -f $(ENV_FILE) ] || (echo "ERROR: $(ENV_FILE) missing. Run: make env"; exit 1)
	@export $$(grep -v '^#' $(ENV_FILE) | xargs); \
		required_vars="HOST_IP HOST_USER HOST_KEY PASSWORD"; \
		for var in $$required_vars; do \
			if [ -z "$${!var}" ]; then \
				echo "ERROR: Missing variable: $$var in $(ENV_FILE)"; exit 1; \
			fi; \
		done; \
		echo "All required environment variables found."

# -------------------------------------
#  Ansible Execution
# -------------------------------------

run: check ## Run the Ansible playbook via execute-playbook.sh
	@$(RUN_SCRIPT)

# -------------------------------------
#  Vault Utilities
# -------------------------------------

vault-encrypt: ## Encrypt group_vars/all.yml with Vault
	@ansible-vault encrypt group_vars/all.yml

vault-decrypt: ## Decrypt group_vars/all.yml (view or modify)
	@ansible-vault decrypt group_vars/all.yml

vault-edit: ## Edit encrypted all.yml directly
	@ansible-vault edit group_vars/all.yml

# -------------------------------------
#  Cleanup
# -------------------------------------

clean: ## Remove generated .env (with confirmation)
	@read -p "Are you sure you want to delete $(ENV_FILE)? (y/N) " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		rm -f $(ENV_FILE); \
		echo "$(ENV_FILE) deleted"; \
	else \
		echo "Aborted."; \
	fi
