install-app:
	ansible-playbook -i inventory.ini playbook.yml  --vault-password-file .pass

install-roles:
	ansible-galaxy role install -r requirements.yml

install-colls:
	ansible-galaxy collection install -r requirements.yml

dd-monitoring:
	ansible-playbook -i inventory.ini dd_playbook.yml --vault-password-file .pass

deploy:
	ansible-playbook -i inventory.ini playbook.yml --tags="app" --vault-password-file .pass

vault-edit:
	ansible-vault edit group_vars/webservers/vault.yml --vault-password-file .pass

setup: install-roles install-colls install-app dd-monitoring

rollback-app:
	ansible-playbook -i inventory.ini rollback.yml --tags="app" --vault-password-file .pass

rollback-dd:
	ansible-playbook -i inventory.ini rollback.yml --tags="dd" --vault-password-file .pass

rollback: rollback-app rollback-dd

.PHONY: install-app install-roles install-colls dd-monitoring deploy vault-edit setup
