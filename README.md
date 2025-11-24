# Server Provisioning & Web Server Automation (Apache / Nginx / Proxy)

## Introduction

This repository provides a **complete, production-grade Ansible provisioning framework**, combining:

### **PHASE 1 — System Provisioning**
- Package installation  
- User management  
- SSH hardening  
- Firewall automation  
- Directory creation  
- All controlled using **feature flags** via `.env`

### **PHASE 2 — Web Server Provisioning**
- Apache-only mode  
- Nginx-only mode  
- Reverse proxy mode (Nginx → Apache)  
- Multi-environment deployment (dev/staging/prod)  
- Secure secrets with **Ansible Vault**  
- Automated runner script (`execute-playbook.sh`)  
- Powerful Makefile for fast workflows  

---

# Requirements

## Local Machine
- Python 3.x  
- Ansible  
- Ansible Vault  
- Bash  
- OpenSSH client  

## Remote Server
- Ubuntu/Debian Linux  
- SSH key-based access  
- Sudo-enabled user  

---

# Setup Instructions

## 1. Create `.env`

```bash
cp .env-example .env
```

Update values:

```
HOST_IP=your_server_ip
HOST_USER=your_ssh_username
HOST_KEY=/path/to/private/key
PASSWORD=your_sudo_password

ENVIRONMENT=dev
SERVER=apache
SERVER_MODE=single

# SYSTEM PROVISIONING FLAGS
ENABLE_PACKAGES=true
ENABLE_USERS=false
ENABLE_HARDENING=false
ENABLE_FIREWALL=false
ENABLE_DIRS=false
```

---

# 2. Run playbooks automatically

## Default:
```bash
./execute-playbook.sh
```

## Run a specific playbook:
```bash
./execute-playbook.sh playbooks/webserver.yml
```

## Dry-run:
```bash
./execute-playbook.sh playbooks/system.yml --check
```

---

# 3. Makefile Usage

See all available commands:

```bash
make help
```

---

## System Provisioning Commands (NEW)

These allow you to run **only the part of the system role you need**.

### Run full system provisioning:
```
make system
```

### Install packages only:
```
make system-packages
```

### Create users only:
```
make system-users
```

### Apply SSH hardening only:
```
make system-hardening
```

### Configure firewall only:
```
make system-firewall
```

### Create system directories only:
```
make system-dirs
```

---

## System Dry-Run Commands (NEW)

### Test full system provisioning:
```
make dry-system
```

### Dry-run for each component:
```
make dry-system-packages
make dry-system-users
make dry-system-firewall
make dry-system-hardening
make dry-system-dirs
```

---

# Web Server Commands

| Command | Description |
|--------|-------------|
| `make apache` | Deploy Apache-only |
| `make nginx` | Deploy Nginx-only |
| `make proxy` | Deploy Nginx → Apache reverse proxy |
| `make dry-web` | Dry-run for webserver.yml |

---

# Inventory Structure

```
inventory/
├── dev/hosts.yml
├── staging/hosts.yml
└── prod/hosts.yml
```

Example:

```yaml
dev:
  hosts:
    dynamic_host:
      ansible_host: "{{ lookup('env', 'HOST_IP') }}"
      ansible_user: "{{ lookup('env', 'HOST_USER') }}"
      ansible_ssh_private_key_file: "{{ lookup('env', 'HOST_KEY') }}"
      ansible_become: yes
      ansible_become_password: "{{ lookup('env', 'PASSWORD') }}"
```

---

# Secrets with Ansible Vault

Encrypt:
```bash
make vault-encrypt
```

Decrypt:
```bash
make vault-decrypt
```

Edit:
```bash
make vault-edit
```

---

# Troubleshooting

## Nginx fails (port conflict)
```bash
sudo ss -tulpn | grep :80
```

## Missing variables
```bash
make check
```

## SSH issues
```bash
chmod 600 ~/.ssh/id_rsa
```

---

# Project Structure

```
ansible-project/
│
├── roles/
│   ├── system/
│   ├── apache/
│   └── nginx/
│
├── playbooks/
│   ├── site.yml
│   ├── system.yml
│   └── webserver.yml
│
├── inventory/
│   ├── dev/
│   ├── staging/
│   └── prod/
│
├── group_vars/
│   └── all.yml (encrypted)
│
├── execute-playbook.sh
├── Makefile
├── .env
├── .env-example
└── README.md
```

---

# Conclusion

This repository delivers:

- Complete system provisioning  
- Web server automation  
- Multi-environment support  
- Secure secrets  
- Scripted automation  
- Modular, production-ready architecture