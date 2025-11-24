# Web Server Provisioning (Apache / Nginx / Proxy)

## Introduction

This project provides a fully automated **Ansible-based web server provisioning framework** with support for:

- Apache-only mode  
- Nginx-only mode  
- Reverse proxy mode (Nginx → Apache)  
- Environment-based deployments (dev, staging, prod)  
- Secure variable handling with **Ansible Vault**  
- Dynamic inventory pulling values from a `.env` file  
- A helper execution script and Makefile for developer-friendly workflows  

This ensures a clean, consistent, and production-ready deployment experience.

---

## Requirements

### Local Machine:
- Python 3.x  
- Ansible  
- Ansible Vault  
- Bash  
- OpenSSH client  

### Remote Machine:
- Ubuntu/Debian Linux server  
- SSH access enabled  
- A user with `sudo` privileges  
- Can authenticate using SSH key  

---

## Setup Instructions

### 1. Create your `.env` file

Copy the example:

```bash
cp .env-example .env
```

Update required values:

```
HOST_IP=your_server_ip
HOST_USER=your_ssh_username
HOST_KEY=/path/to/private/key
PASSWORD=your_sudo_password

ENVIRONMENT=dev
SERVER=apache
SERVER_MODE=single
```

### 2. Run the automated execution script

```bash
./execute-playbook.sh
```

This script:

1. Loads `.env` variables  
2. Validates required fields  
3. Selects the correct inventory  
4. Applies options like SERVER / SERVER_MODE  
5. Prompts for your Vault password  
6. Executes the playbook safely  

Run a specific playbook:

```bash
./execute-playbook.sh playbooks/webserver.yml
```

Dry-run mode:

```bash
./execute-playbook.sh playbooks/webserver.yml --check
```

---

## 3. Using the Makefile

See all commands:

```bash
make help
```

### Common commands:

| Command | Description |
|--------|-------------|
| `make env` | Create `.env` file from template |
| `make check` | Validate `.env` |
| `make run` | Run default playbook |
| `make apache` | Deploy Apache only |
| `make nginx` | Deploy Nginx only |
| `make proxy` | Deploy Nginx → Apache reverse proxy |
| `make dry` | Dry-run default playbook |
| `make dry-web` | Dry-run webserver.yml |
| `make vault-encrypt` | Encrypt `group_vars/all.yml` |
| `make vault-decrypt` | Decrypt `group_vars/all.yml` |
| `make vault-edit` | Edit encrypted variables |
| `make clean` | Remove `.env` (with confirmation) |

This makes the project highly developer-friendly.

---

## Inventory Configuration (YAML-based)

Inventory files are stored per environment:

```
inventory/
├── dev/
│   └── hosts.yml
├── staging/
│   └── hosts.yml
└── prod/
    └── hosts.yml
```

Example (`inventory/dev/hosts.yml`):

```yaml
dev:
  hosts:
    dynamic_host:
      ansible_host: "{{ lookup('env', 'HOST_IP') }}"
      ansible_user: "{{ lookup('env', 'HOST_USER') }}"
      ansible_ssh_private_key_file: "{{ lookup('env', 'HOST_KEY') }}"
      ansible_become: yes
      ansible_become_method: sudo
      ansible_become_password: "{{ lookup('env', 'PASSWORD') }}"
```

This ensures secrets stay outside the repository.

---

## Vault Usage

Secret variables are stored in:

```
group_vars/all.yml
```

Encrypt:

```bash
make vault-encrypt
```

Decrypt:

```bash
make vault-decrypt
```

Edit safely:

```bash
make vault-edit
```

All developers can run the repo with the same encrypted file.  
Each provides the **vault password** manually (best practice).

---

## Web Server Modes

### 1. Apache-only Mode
```
SERVER=apache
SERVER_MODE=single
```
- Apache runs on port **80**
- Nginx fully disabled

### 2. Nginx-only Mode
```
SERVER=nginx
SERVER_MODE=single
```
- Nginx runs on port **80**
- Apache fully disabled

### 3. Reverse Proxy Mode (Nginx → Apache)
```
SERVER_MODE=proxy
```
- Apache backend on **8080**
- Nginx frontend on **80**
- Nginx proxies requests → Apache

This is the recommended production setup.

---

## Project Structure

```
ansible-project/
│
├── roles/
│   ├── apache/
│   │   ├── defaults/
│   │   ├── handlers/
│   │   ├── tasks/
│   │   ├── templates/
│   │   └── vars/
│   │
│   └── nginx/
│       ├── defaults/
│       ├── handlers/
│       ├── tasks/
│       ├── templates/
│       └── vars/
│
├── playbooks/
│   ├── site.yml
│   └── webserver.yml
│
├── inventory/
│   ├── dev/
│   ├── staging/
│   └── prod/
│
├── group_vars/
│   └── all.yml  (encrypted)
│
├── execute-playbook.sh
├── makefile
├── .env
├── .env-example
└── README.md
```

---

## Troubleshooting

### Nginx fails to start
Check who is using port 80:

```bash
sudo ss -tulpn | grep :80
```

If `apache2` appears, Nginx cannot bind the port.

### “Missing environment variables”
Run:

```bash
make check
```

### SSH Permission Denied
Verify:

```bash
chmod 600 ~/.ssh/id_rsa
```

### Vault issues
Use:

```bash
make vault-edit
```

---

## Conclusion

This project delivers:

- A secure, automated provisioning framework  
- Multi-environment support  
- Multi-server architecture (apache / nginx / proxy)  
- Vault-based secret handling  
- YAML-driven dynamic inventory  
- A fully automated playbook runner script  
- A Makefile for ease of use  
