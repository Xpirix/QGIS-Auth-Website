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
	@echo "\nSending password resets via host API calls..."
	
	# Get admin token
	@echo "1. Getting admin token..."
	@TOKEN=$$(curl -s -X POST \
		"http://localhost:8081/realms/master/protocol/openid-connect/token" \
		-H "Content-Type: application/x-www-form-urlencoded" \
		-d "client_id=admin-cli" \
		-d "username=$(u)" \
		-d "password=$(p)" \
		-d "grant_type=password" | \
		jq -r '.access_token')
	
	# Get user IDs
	@echo "$$TOKEN"
	@echo "2. Fetching user IDs..."
	@RAW_USERS=$$(curl -s \
		"http://localhost:8081/admin/realms/$(r)/users" \
		-H "Authorization: Bearer $$TOKEN")
	@echo "Raw user data:"
	@echo "$$RAW_USERS" | jq .
	@USER_IDS=$$(echo "$$RAW_USERS" | jq -r '.[].id')
	
	# Send reset emails
	@echo "3. Sending resets to $$(echo "$$USER_IDS" | wc -w) users..."
	@for ID in $$USER_IDS; do \
		echo "Processing $$ID..."; \
		curl -s -X PUT \
			"http://localhost:8081/admin/realms/$(r)/users/$$ID/execute-actions-email" \
			-H "Authorization: Bearer $$TOKEN" \
			-H "Content-Type: application/json" \
			-d '["UPDATE_PASSWORD"]'; \
	done
	
	@echo "Complete"

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
