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
	docker compose -p $(PROJECT_ID) up --no-deps keycloak
