# Project README

## Introduction

This project provides an automated Ansible-based deployment workflow using environment variables, vault encryption, YAML inventory, and a helper script for seamless execution.

## Requirements

* Ansible
* Ansible Vault
* Bash
* SSH access to remote server

## Setup Instructions

### 1. Create your `.env` file

Copy the example template:

```bash
cp .env-example .env
```

Update the variables:

```
HOST_IP=your_server_ip
HOST_USER=your_ssh_username
HOST_KEY=/path/to/private/key
PASSWORD=your_sudo_password
```

### 2. Run the playbook

Execute the automated script:

```bash
./execute-playbook.sh
```

This will load environment variables, validate inputs, request the Ansible Vault password, and run the playbook.

### 3. Using the Makefile

List all available commands:

```bash
make help
```

Common commands:

* Create `.env` file: `make env`
* Validate variables: `make check`
* Run playbook: `make run`
* Encrypt Vault: `make vault-encrypt`
* Decrypt Vault: `make vault-decrypt`
* Edit Vault contents: `make vault-edit`

## Inventory Configuration

The inventory is stored in YAML format (`inventory/vm-playbook/hosts.yml`) and pulls values from environment variables.

## Vault Usage

The file `group_vars/all.yml` is encrypted and stores secure variables. Use the Makefile tools for managing Vault.

## Troubleshooting

* Ensure `.env` exists and contains all required variables.
* Ensure your SSH key path is correct and accessible.
* Use `make check` to verify required variables.

## Project Structure

```
project/
├── execute-playbook.sh
├── Makefile
├── vm-playbook.yml
├── group_vars/
│   └── all.yml (encrypted)
├── inventory/
│   └── vm-playbook/
│       └── hosts.yml
├── roles/
│   └── python/
├── .env-example
└── .env (ignored in Git)
```

## Conclusion

This project structure ensures secure, fast, and automated deployment workflows with minimal manual steps using Ansible, environment variables, and vault encryption.
