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
