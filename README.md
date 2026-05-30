# DevOps for Developers Project - Preparation for Deployment

This project contains Ansible playbooks and configuration to prepare servers for deploying an application.

## Prerequisites

- Ansible installed on your control machine (you can install it via pip: `pip install ansible`)
- Access to two servers (or virtual machines) with SSH access using a deploy user.

## Setup

1. Clone this repository.
2. Update the `inventory.ini` file with your server details:
   - Replace the IP addresses (192.168.1.10, 192.168.1.11) with your actual server IPs.
   - Optionally, change the aliases (web1, web2) and the ansible_user (deployer) if needed.
3. Install required Ansible roles and collections:
   ```bash
   make install-deps
   ```
   or
   ```bash
   ansible-galaxy install -r requirements.yml
   ```

## Prepare Servers

To prepare the servers (install pip and Docker module), run:

```bash
make prepare
```
or
```bash
ansible-playbook -i inventory.ini playbook.yml
```

This will:
- Install pip on the servers (if not present)
- Install the Docker Python module via pip
- Configure Docker (via the geerlingguy.docker role)

## Files

- `inventory.ini`: Inventory file defining the `webservers` group and server hosts.
- `requirements.yml`: Lists required Ansible roles (geerlingguy.pip, geerlingguy.docker).
- `playbook.yml`: Main playbook that applies the roles to all hosts.
- `group_vars/`: Directory for group variables (currently empty, but can be used to set variables for the webservers group).
- `Makefile`: Convenience targets for dependency installation and server preparation.

## Makefile Targets

- `make install-deps`: Install Ansible roles from requirements.yml.
- `make prepare`: Prepare servers by running the playbook.

## Notes

- The playbook uses `hosts: all` to target all servers in the inventory.
- The `geerlingguy.pip` role is used to install pip and the Docker Python package.
- The `geerlingguy.docker` role is used to install and configure Docker.

