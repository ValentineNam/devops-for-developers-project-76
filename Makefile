.PHONY: install-deps prepare deploy encrypt-vault decrypt-vault view-vault

# Add user's local bin to PATH for ansible-galaxy and ansible-playbook
export PATH := /Users/v.nam/Library/Python/3.13/bin:$(PATH)

install-deps:
	ANSIBLE_GALAXY=$$(command -v ansible-galaxy) && $$ANSIBLE_GALAXY install -r requirements.yml

prepare: install-deps
	ANSIBLE_PLAYBOOK=$$(command -v ansible-playbook) && $$ANSIBLE_PLAYBOOK -i inventory.ini playbook.yml

deploy: install-deps
	ANSIBLE_PLAYBOOK=$$(command -v ansible-playbook) && $$ANSIBLE_PLAYBOOK -i inventory.ini --ask-vault-pass deploy.yml

encrypt-vault:
	@echo "Encrypting group_vars/webservers/vault.yml"
	ANSIBLE_VAULT=$$(command -v ansible-vault) && $$ANSIBLE_VAULT encrypt group_vars/webservers/vault.yml

decrypt-vault:
	@echo "Decrypting group_vars/webservers/vault.yml"
	ANSIBLE_VAULT=$$(command -v ansible-vault) && $$ANSIBLE_VAULT decrypt group_vars/webservers/vault.yml

view-vault:
	@echo "Viewing encrypted group_vars/webservers/vault.yml"
	cat group_vars/webservers/vault.yml
