# Deploy docker images with Ansible

[![Actions Status](https://github.com/ilrosch/devops-for-developers-project-76/actions/workflows/hexlet-check.yml/badge.svg)](https://github.com/ilrosch/devops-for-developers-project-76/actions)

Deploying an `redmine` application with installation of a `datadog` monitoring system.

[DEMO - click here!](https://cloud.ilrosch.ru)

---

## Requirements

- **Python** >= 3.12
- **Ansible** >= 2.20
- **Make**

---

## Preparing

Configure `inventory.ini` with your machine data:

```
<name> ansible_host=<your-host> ansible_user=<your-user>
...
```

Change `group_vars/all/vars.yml` with your db data ([redmine](https://hub.docker.com/_/redmine)):

```
REDMINE_DB_POSTGRES: <db-host>
REDMINE_DB_PORT: <db-port>
REDMINE_DB_DATABASE: <db-name>
REDMINE_DB_USERNAME: <db-username>
```

Change `vault.yml` with your data ([datadog](https://docs.datadoghq.com/agent/supported_platforms/ansible/#pagetitle)):

```
db_password: <password>
dd_api_key: <datadog-key>
```

Encrypt your data (`vault.yml`) and save your password (`.pass`):

```
ansible-vault encrypt group_vars/webservers/vault.yml
```

---

## Get started

Install app (redmine + datadog):

```
make setup
```

Other commands:

```
make install-app        # Install full redmine app

make install-roles      # Install roles

make install-colls      # Install collections

make dd-monitoring      # Install datadog agent

make deploy             # Only application deployment

make vault-edit         # Change vault.yml

make rollback-app       # Delete only redmine app

make rollback-dd        # Delete only dataog agent

make rollback           # Delete all
```

---

## Example

Install (setup):

[![asciicast](https://asciinema.org/a/evYE5sIUCW1QmEJN.svg)](https://asciinema.org/a/evYE5sIUCW1QmEJN)

Rollback all:

[![asciicast](https://asciinema.org/a/P8Z4tZMtKcLf6V5Y.svg)](https://asciinema.org/a/P8Z4tZMtKcLf6V5Y)
