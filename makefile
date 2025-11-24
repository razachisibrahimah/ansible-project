.PHONY: help env check run dev staging prod apache nginx proxy dry dry-web dry-dev dry-staging dry-prod vault-encrypt vault-decrypt vault-edit clean

# -------------------------------------
#  Project Variables
# -------------------------------------
ENV_FILE        = .env
ENV_EXAMPLE     = .env-example
RUN_SCRIPT      = ./execute-playbook.sh
DEFAULT_PLAYBOOK = playbooks/site.yml


# -------------------------------------
#  Help Menu
# -------------------------------------
help: ## Show help menu
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z0-9_-]+:.*##/ { printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)


# -------------------------------------
#  Environment Setup
# -------------------------------------
env: ## Create .env from template
	@if [ -f $(ENV_FILE) ]; then \
		echo "ERROR: $(ENV_FILE) already exists. Remove it manually if recreating it."; exit 1; \
	fi
	cp $(ENV_EXAMPLE) $(ENV_FILE)
	@echo ".env created."

check: ## Validate required environment variables in .env
	@[ -f $(ENV_FILE) ] || (echo "ERROR: .env missing. Run: make env"; exit 1)
	@export $$(grep -v '^#' $(ENV_FILE) | xargs); \
	req="HOST_IP HOST_USER HOST_KEY PASSWORD"; \
	for v in $$req; do \
		if [ -z "$${!v}" ]; then echo "ERROR: Missing $$v"; exit 1; fi; \
	done; \
	echo "Environment OK."


# -------------------------------------
#  Execute Playbooks (ENVIRONMENT aware)
# -------------------------------------
run: check ## Run default playbook (site.yml)
	@ENVIRONMENT=$${ENVIRONMENT:-dev} $(RUN_SCRIPT) $(DEFAULT_PLAYBOOK)

dev: check ## Run against dev environment
	@ENVIRONMENT=dev $(RUN_SCRIPT) $(DEFAULT_PLAYBOOK)

staging: check ## Run against staging environment
	@ENVIRONMENT=staging $(RUN_SCRIPT) $(DEFAULT_PLAYBOOK)

prod: check ## Run against prod environment
	@ENVIRONMENT=prod $(RUN_SCRIPT) $(DEFAULT_PLAYBOOK)


# -------------------------------------
#  System Provisioning: Individual Components
# -------------------------------------

# =========================================================
# SYSTEM ROLE — Feature Flag Controls
# =========================================================

system: check ## Run full system provisioning using flags in .env
	@$(RUN_SCRIPT) playbooks/system.yml

# =========================================================
# SYSTEM ROLE — Dry-Run Versions (Check Mode)
# =========================================================

# -------------------------------
# Dry-run: FULL system provisioning
# -------------------------------
dry-system: check ## Dry-run full system provisioning
	@DRY_RUN=--check $(RUN_SCRIPT) playbooks/system.yml

# -------------------------------
# Dry-run: packages only
# -------------------------------
dry-system-packages: check ## Dry-run: install packages only
	@ENABLE_PACKAGES=true \
	 ENABLE_USERS=false \
	 ENABLE_FIREWALL=false \
	 ENABLE_HARDENING=false \
	 ENABLE_DIRS=false \
	 $(RUN_SCRIPT) playbooks/system.yml --check

# -------------------------------
# Dry-run: users only
# -------------------------------
dry-system-users: check ## Dry-run: manage users only
	@ENABLE_PACKAGES=false \
	 ENABLE_USERS=true \
	 ENABLE_FIREWALL=false \
	 ENABLE_HARDENING=false \
	 ENABLE_DIRS=false \
	 $(RUN_SCRIPT) playbooks/system.yml --check

# -------------------------------
# Dry-run: firewall only
# -------------------------------
dry-system-firewall: check ## Dry-run: configure firewall only
	@ENABLE_PACKAGES=false \
	 ENABLE_USERS=false \
	 ENABLE_FIREWALL=true \
	 ENABLE_HARDENING=false \
	 ENABLE_DIRS=false \
	 $(RUN_SCRIPT) playbooks/system.yml --check

# -------------------------------
# Dry-run: hardening only
# -------------------------------
dry-system-hardening: check ## Dry-run: apply system hardening only
	@ENABLE_PACKAGES=false \
	 ENABLE_USERS=false \
	 ENABLE_FIREWALL=false \
	 ENABLE_HARDENING=true \
	 ENABLE_DIRS=false \
	 $(RUN_SCRIPT) playbooks/system.yml --check

# -------------------------------
# Dry-run: directories only
# -------------------------------
dry-system-dirs: check ## Dry-run: create directories only
	@ENABLE_PACKAGES=false \
	 ENABLE_USERS=false \
	 ENABLE_FIREWALL=false \
	 ENABLE_HARDENING=false \
	 ENABLE_DIRS=true \
	 $(RUN_SCRIPT) playbooks/system.yml --check


# -------------------------------
# Run ONLY package installation
# -------------------------------
system-packages: check ## Run package installation only
	@ENABLE_PACKAGES=true \
	 ENABLE_USERS=false \
	 ENABLE_FIREWALL=false \
	 ENABLE_HARDENING=false \
	 ENABLE_DIRS=false \
	 $(RUN_SCRIPT) playbooks/system.yml

# -------------------------------
# Run ONLY user creation
# -------------------------------
system-users: check ## Run user management only
	@ENABLE_PACKAGES=false \
	 ENABLE_USERS=true \
	 ENABLE_FIREWALL=false \
	 ENABLE_HARDENING=false \
	 ENABLE_DIRS=false \
	 $(RUN_SCRIPT) playbooks/system.yml

# -------------------------------
# Run ONLY firewall setup
# -------------------------------
system-firewall: check ## Run firewall configuration only
	@ENABLE_PACKAGES=false \
	 ENABLE_USERS=false \
	 ENABLE_FIREWALL=true \
	 ENABLE_HARDENING=false \
	 ENABLE_DIRS=false \
	 $(RUN_SCRIPT) playbooks/system.yml

# -------------------------------
# Run ONLY SSH hardening
# -------------------------------
system-hardening: check ## Run SSH hardening only
	@ENABLE_PACKAGES=false \
	 ENABLE_USERS=false \
	 ENABLE_FIREWALL=false \
	 ENABLE_HARDENING=true \
	 ENABLE_DIRS=false \
	 $(RUN_SCRIPT) playbooks/system.yml

# -------------------------------
# Run ONLY directory creation
# -------------------------------
system-dirs: check ## Create system directories only
	@ENABLE_PACKAGES=false \
	 ENABLE_USERS=false \
	 ENABLE_FIREWALL=false \
	 ENABLE_HARDENING=false \
	 ENABLE_DIRS=true \
	 $(RUN_SCRIPT) playbooks/system.yml


system-all: check ## Run ALL system tasks
	@$(RUN_SCRIPT) playbooks/system.yml

# -------------------------------------
#  Web Server Modes (Apache / Nginx / Proxy)
# -------------------------------------
apache: check ## Run webserver.yml using Apache
	@ENVIRONMENT=$${ENVIRONMENT:-dev} SERVER=apache SERVER_MODE=single $(RUN_SCRIPT) playbooks/webserver.yml

nginx: check ## Run webserver.yml using Nginx
	@ENVIRONMENT=$${ENVIRONMENT:-dev} SERVER=nginx SERVER_MODE=single $(RUN_SCRIPT) playbooks/webserver.yml

proxy: check ## Run webserver.yml in reverse proxy mode (Nginx → Apache)
	@ENVIRONMENT=$${ENVIRONMENT:-dev} SERVER=apache SERVER_MODE=proxy $(RUN_SCRIPT) playbooks/webserver.yml


# -------------------------------------
#  Dry-Run / Check Mode (Environment-aware)
# -------------------------------------
dry: check ## Dry-run default playbook
	@ENVIRONMENT=$${ENVIRONMENT:-dev} $(RUN_SCRIPT) $(DEFAULT_PLAYBOOK) --check

dry-web: check ## Dry-run webserver.yml
	@ENVIRONMENT=$${ENVIRONMENT:-dev} $(RUN_SCRIPT) playbooks/webserver.yml --check

dry-dev: check ## Dry-run dev
	@ENVIRONMENT=dev $(RUN_SCRIPT) $(DEFAULT_PLAYBOOK) --check

dry-staging: check ## Dry-run staging
	@ENVIRONMENT=staging $(RUN_SCRIPT) $(DEFAULT_PLAYBOOK) --check

dry-prod: check ## Dry-run prod
	@ENVIRONMENT=prod $(RUN_SCRIPT) $(DEFAULT_PLAYBOOK) --check


# -------------------------------------
#  Vault Commands
# -------------------------------------
vault-encrypt: ## Encrypt group_vars/all.yml
	@ansible-vault encrypt group_vars/all.yml

vault-decrypt: ## Decrypt group_vars/all.yml
	@ansible-vault decrypt group_vars/all.yml

vault-edit: ## Edit encrypted group_vars/all.yml
	@ansible-vault edit group_vars/all.yml


# -------------------------------------
#  Cleanup
# -------------------------------------
clean: ## Safely delete .env
	@read -p "Delete $(ENV_FILE)? (y/N): " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		rm -f $(ENV_FILE); echo "$(ENV_FILE) deleted."; \
	else \
		echo "Aborted."; \
	fi
