.PHONY: deps ping bootstrap deploy-rpi deploy-server deploy-all verify backup validate require-inventory

INVENTORY ?=
ANSIBLE := ansible-playbook -i $(INVENTORY)

deps:
	ansible-galaxy collection install -r requirements.yml

require-inventory:
	@test -n "$(INVENTORY)" || { echo "[ERROR] INVENTORY is required"; exit 1; }
	@test -f "$(INVENTORY)" || { echo "[ERROR] inventory file not found: $(INVENTORY)"; exit 1; }

ping: require-inventory
	ansible -i $(INVENTORY) all -m ping

# Prepare nodes (Docker, systemd units, backup timer).
bootstrap: require-inventory
	$(ANSIBLE) playbooks/bootstrap.yml

deploy-server: require-inventory
	$(ANSIBLE) playbooks/deploy-server.yml

deploy-rpi: require-inventory
	$(ANSIBLE) playbooks/deploy-rpi.yml

deploy-all: deploy-server deploy-rpi

# Run verification policy checks.
verify: require-inventory
	$(ANSIBLE) playbooks/verify.yml

# Trigger immediate lightweight backup.
backup: require-inventory
	$(ANSIBLE) playbooks/backup.yml

# Static validation for playbooks and compose files.
validate: require-inventory
	@for playbook in playbooks/*.yml; do \
		ansible-playbook -i $(INVENTORY) --syntax-check $$playbook; \
	done
	docker compose --env-file files/server/.env.example -f files/server/docker-compose.yml config -q
	docker compose --env-file files/rpi/.env.example -f files/rpi/docker-compose.yml config -q
