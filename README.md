# DevOps for Developers Project - Preparation, Deployment, and Monitoring

This project contains Ansible playbooks and configuration to prepare servers, deploy a Redmine application with a MySQL database, and set up monitoring with DataDog.

## Prerequisites

- Ansible installed on your control machine (you can install it via pip: `pip install ansible`)
- Access to two servers (or virtual machines) with SSH access using a deploy user.
- Docker installed on the servers (will be installed by the preparation playbook).
- A MySQL server running and accessible from the web servers (you can use one of the web servers or a separate server).
- A DataDog account (register at https://www.datadoghq.com/) to obtain API and application keys.
- An Ansible Vault password to encrypt/decrypt the vault file.

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
- Install and configure the DataDog agent (with API and application keys from vault)

## Configure the Database Connection

1. Edit `group_vars/webservers/vars.yml` to set the database connection details:
   - `db_host`: The IP address or hostname of your MySQL server.
   - `db_name`: The database name for Redmine (default: redmine).
   - `db_user`: The username for the Redmine database (default: redmine).
2. The database password is stored in an encrypted file `group_vars/webservers/vault.yml`.
   - To edit the password, run `make decrypt-vault`, edit the file, then run `make encrypt-vault`.
   - To view the encrypted file, run `make view-vault`.
   - The default password in the vault is `mysecretpassword` (for demonstration only). You must change it.

## Configure DataDog Monitoring

1. Register on DataDog (if you haven't already) at https://www.datadoghq.com/ and obtain your API key and application key from the DataDog console (Integrations > APIs).
2. Update the encrypted vault file `group_vars/webservers/vault.yml` with your actual DataDog keys:
   - Run `make decrypt-vault`
   - Edit the file, replacing the placeholder values for `vault_datadog_api_key` and `vault_datadog_app_key` with your actual keys.
   - Run `make encrypt-vault` to re-encrypt the file.
   - (You can also update the vault directly using `ansible-vault edit group_vars/webservers/vault.yml`.)
3. The DataDog agent will be installed and configured during server preparation (`make prepare`). The agent will run an HTTP check to monitor your Redmine application at `http://localhost:<redmine_port>` on each server (by default port 8080).

## Deploy Redmine Application

To deploy the Redmine application with database connection, run:

```bash
make deploy
```
or
```bash
ansible-playbook -i inventory.ini --ask-vault-pass deploy.yml
```

You will be prompted for the Ansible Vault password.

This will:
- Create a directory for Redmine data and configuration
- Run the Redmine container on each server, exposing the container port 3000 to the host port defined by the `redmine_port` variable (default: 8080)
- Set the environment variables for the Redmine container to connect to the MySQL database
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

## Monitoring with DataDog

After the DataDog agent is running on your servers (via the preparation playbook), it will automatically:
- Collect system metrics (CPU, memory, disk, etc.)
- Run the configured HTTP check to verify your Redmine application is responding
- Send metrics and check results to your DataDog account

You can view the HTTP check status in DataDog under Monitors > Service Checks.

## Files

- `inventory.ini`: Inventory file defining the `webservers` group and server hosts.
- `requirements.yml`: Lists required Ansible roles (geerlingguy.pip, geerlingguy.docker, datadog.datadog).
- `playbook.yml`: Preparation playbook that installs pip, Docker, and the DataDog agent.
- `deploy.yml`: Deployment playbook that runs the Redmine container with database connection.
- `group_vars/webservers/vars.yml`: Defines non-secret variables (db_host, db_name, db_user, redmine_port) and references to vault secrets.
- `group_vars/webservers/vault.yml`: Encrypted file containing sensitive data: database password (`vault_db_password`), DataDog API key (`vault_datadog_api_key`), DataDog application key (`vault_datadog_app_key`).
- `templates/.env.j2`: Template for the Redmine container's environment file (not used in the current deploy.yml, but kept for reference).
- `group_vars/`: Directory for group variables.
- `Makefile`: Convenience targets for dependency installation, server preparation, deployment, and vault management.

## Makefile Targets

- `make install-deps`: Install Ansible roles and collections from requirements.yml.
- `make prepare`: Prepare servers by running the preparation playbook (includes DataDog agent installation).
- `make deploy`: Deploy the Redmine application by running the deployment playbook (prompts for vault password).
- `make encrypt-vault`: Encrypt the vault file (prompts for vault password).
- `make decrypt-vault`: Decrypt the vault file (prompts for vault password).
- `make view-vault`: View the encrypted vault file.

## Notes

- The playbooks use `hosts: all` to target all servers in the inventory.
- The `geerlingguy.pip` role is used to install pip and the Docker Python package.
- The `geerlingguy.docker` role is used to install and configure Docker.
- The `datadog.datadog` role is used to install and configure the DataDog agent.
- The Redmine application uses MySQL for persistence; ensure the database and user are created on the MySQL server before deployment.
- The application's data (file uploads) is persisted in `/opt/redmine/data` on the host.
- The DataDog HTTP check is configured to check `http://localhost:<redmine_port>` on each server, which should work if the Redmine container is accessible on that port from the host.

## Deployed Application Link

After setting up the load balancer and DNS, you can access the application at: https://<your_domain>

## DataDog Monitoring Link

Once the agent is running and configured, you can view your Redmine service check in DataDog at: https://app.datadoghq.com/service/checks (replace with your actual DataDog site if not using US1).

