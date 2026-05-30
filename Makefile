.PHONY: install-deps prepare

# Add user's local bin to PATH for ansible-galaxy and ansible-playbook
export PATH := /Users/v.nam/Library/Python/3.13/bin:$(PATH)

install-deps:
	ANSIBLE_GALAXY=$$(command -v ansible-galaxy) && $$ANSIBLE_GALAXY install -r requirements.yml

prepare: install-deps
	ANSIBLE_PLAYBOOK=$$(command -v ansible-playbook) && $$ANSIBLE_PLAYBOOK -i inventory.ini playbook.yml
