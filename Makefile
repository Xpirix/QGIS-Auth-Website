PROJECT_ID := qgis-auth

SHELL := /usr/bin/env bash

default: help
help:
	@echo "Makefile for QGIS Auth project"
	@echo "Available commands:"
	@echo "  make db           - Start the database container"
	@echo "  make logs [c=...] - Tail logs for all or a specific container"
	@echo "  make start [c=...] - Start a specific container(s)"
	@echo "  make restart [c=...] - Restart all or a specific container(s)"
	@echo "  make kill [c=...] - Kill all or a specific container(s)"
	@echo "  make web          - Start production containers (web, keycloak, dbbackups)"
	@echo "  make certbot      - Run certbot in production mode"
	@echo "  make nginx-shell  - Shell into the NGINX/WEB container"
	@echo "  make nginx-logs   - Tail logs in NGINX/WEB container"
	@echo "  make devweb       - Start the project in development mode"

db:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Running db container for QGIS Auth project..."
	@echo "------------------------------------------------------------------"
	@docker compose -p $(PROJECT_ID) up -d db

logs:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Tailing all logs or a specific container"
	@echo "------------------------------------------------------------------"
	@docker compose -p $(PROJECT_ID) logs -f $(c)

build:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Building all or a specific container(s)"
	@echo "------------------------------------------------------------------"
	@docker compose -p $(PROJECT_ID) build $(c)

start:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Starting a specific container(s). Use up/up-dev if you want to start all."
	@echo "------------------------------------------------------------------"
	@docker compose -p $(PROJECT_ID) up -d $(c)

restart:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Restarting all or a specific container(s)"
	@echo "------------------------------------------------------------------"
	@docker compose -p $(PROJECT_ID) restart $(c)

kill:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Killing all or a specific container(s)"
	@echo "------------------------------------------------------------------"
	@docker compose -p $(PROJECT_ID) kill $(c)

shell:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Shelling into the Keycloak container"
	@echo "------------------------------------------------------------------"
	@docker compose -p $(PROJECT_ID) exec keycloak bash

import-users:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Importing users from a JSON file into Keycloak"
	@echo "------------------------------------------------------------------"
	@docker compose -p $(PROJECT_ID) exec keycloak /opt/keycloak/bin/kc.sh import --file /data/users.json


send-password-reset:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Sending password reset email to all users in Keycloak"
	@echo "------------------------------------------------------------------"
	@docker run --rm -it \
		-e SERVER_URL=$(url) \
		-e REALM=$(r) \
		-e ADMIN_USER=$(u) \
		-e ADMIN_PASSWORD=$(p) \
		-v $(PWD):/app \
		-w /app \
		python:3.13-slim bash -c "\
			pip install python-keycloak && \
			./scripts/send_password_reset.py \
				--server-url \$${SERVER_URL} \
				--realm \$${REALM} \
				--admin-user \$${ADMIN_USER} \
				--admin-password \$${ADMIN_PASSWORD}"

# send-password-reset-host:
# 	@echo "\nSending password resets via host-executed container commands..."
# 	@echo "1. Getting admin token..."
# 	@TOKEN=$$(docker compose -p $(PROJECT_ID) exec keycloak bash -c '\
# 		/opt/keycloak/bin/kcadm.sh config credentials \
# 			--server http://localhost:8080 \
# 			--realm master \
# 			--user $(u) \
# 			--password $(p) >/dev/null; \
# 		cat ~/.keycloak/kcadm.config | grep "token" | cut -d\" -f4'); \
# 	echo "2. Fetching user IDs...";
# 	@USER_IDS=$$(docker compose -p $(PROJECT_ID) exec keycloak bash -c '\
# 		/opt/keycloak/bin/kcadm.sh get users -r $(r) --fields id | \
# 		grep -oE "[a-f0-9]{8}-([a-f0-9]{4}-){3}[a-f0-9]{12}"'); \
# 	echo "3. Sending resets to $$(echo "$$USER_IDS" | wc -w) users..."; \
# 	for ID in $$USER_IDS; do \
# 		echo "Sending to $$ID"; \
# 		docker compose -p $(PROJECT_ID) exec keycloak bash -c '\
# 			/opt/keycloak/bin/kcadm.sh update users/'"$$ID"'/execute-actions-email \
# 				-r $(r) \
# 				-s 'actions=["UPDATE_PASSWORD"]''; \
# 	done; \
# 	echo "Complete"

# ----------------------------------------------------------------------------
#    P R O D U C T I O N     C O M M A N D S
# ----------------------------------------------------------------------------
web: db
	@echo "Starting QGIS Auth project..."
	docker compose -p $(PROJECT_ID) up -d keycloak web dbbackups

certbot: web
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Running cerbot in production mode"
	@echo "------------------------------------------------------------------"
	@docker compose -p $(PROJECT_ID) up -d certbot

nginx-shell:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Shelling into the NGINX/WEB container(s)"
	@echo "------------------------------------------------------------------"
	@docker compose -p $(PROJECT_ID) exec web bash 

nginx-logs:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Tailing logs in NGINX/WEB container(s)"
	@echo "------------------------------------------------------------------"
	@docker compose -p $(PROJECT_ID) logs -f web

# ----------------------------------------------------------------------------
#    D E V E L O P M E N T     C O M M AN D S
# ----------------------------------------------------------------------------
devweb: db
	@echo "Starting QGIS Auth project in development mode..."
	docker compose -p $(PROJECT_ID) up keycloak
