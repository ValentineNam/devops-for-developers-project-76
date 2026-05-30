# DevOps for Developers Project - Preparation and Deployment

This project contains Ansible playbooks and configuration to prepare servers and deploy a Redmine application.

## Prerequisites

- Ansible installed on your control machine (you can install it via pip: `pip install ansible`)
- Access to two servers (or virtual machines) with SSH access using a deploy user.
- Docker installed on the servers (will be installed by the preparation playbook).

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

To prepare the servers (install pip and Docker), run:

```bash
make prepare
```
or
```bash
ansible-playbook -i inventory.ini playbook.yml
```

This will:
- Install pip on the servers (if not present)
- Install Docker and the Docker Python SDK

## Deploy Redmine Application

To deploy the Redmine application, run:

```bash
make deploy
```
or
```bash
ansible-playbook -i inventory.ini deploy.yml
```

This will:
- Create a directory for Redmine data and configuration
- Generate a .env file with necessary environment variables (using SQLite database)
- Run the Redmine container on each server, exposing the container port 3000 to the host port defined by the `redmine_port` variable (default: 8080)
- Persist file uploads and data in `/opt/redmine/data` on the host

## Accessing the Application

After deployment, you can access Redmine at:
- http://<server_ip>:<redmine_port> (e.g., http://192.168.1.10:8080)

To access via a load balancer with HTTPS:
1. Configure your load balancer (e.g., Nginx, HAProxy, or cloud load balancer) to forward port 443 (HTTPS) to port <redmine_port> on the backend servers.
2. Obtain an SSL certificate for your domain (e.g., using Let's Encrypt or create a self-signed certificate for testing).
3. Configure the load balancer to use the SSL certificate and terminate HTTPS connections.
4. The application will then be accessible at https://<your_domain>

## Example: Self-signed Certificate for Testing

If you want to test HTTPS locally with a self-signed certificate, you can create one:

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/selfsigned.key -out /etc/ssl/certs/selfsigned.crt -subj "/C=US/ST=State/L=City/O=Organization/CN=<your_domain>"
```

Then configure your load balancer (e.g., Nginx) to use this certificate and key.

## Files

- `inventory.ini`: Inventory file defining the `webservers` group and server hosts.
- `requirements.yml`: Lists required Ansible roles (geerlingguy.pip, geerlingguy.docker).
- `playbook.yml`: Preparation playbook that installs pip and Docker.
- `deploy.yml`: Deployment playbook that runs the Redmine container.
- `group_vars/webservers.yml`: Defines the `redmine_port` variable (default 8080).
- `templates/.env.j2`: Template for the Redmine container's environment file.
- `group_vars/`: Directory for group variables.
- `Makefile`: Convenience targets for dependency installation, server preparation, and deployment.

## Makefile Targets

- `make install-deps`: Install Ansible roles and collections from requirements.yml.
- `make prepare`: Prepare servers by running the preparation playbook.
- `make deploy`: Deploy the Redmine application by running the deployment playbook.

## Notes

- The playbooks use `hosts: all` to target all servers in the inventory.
- The `geerlingguy.pip` role is used to install pip and the Docker Python package.
- The `geerlingguy.docker` role is used to install and configure Docker.
- The Redmine application uses SQLite for simplicity; for production, consider using an external database and persisting the data.
- The application's data (file uploads) is persisted in `/opt/redmine/data` on the host.

## Deployed Application Link

After setting up the load balancer and DNS, you can access the application at: https://<your_domain>

