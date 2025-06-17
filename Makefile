PROJECT_ID := qgis-login

SHELL := /usr/bin/env bash

default: help
help:
	@echo "Makefile for QGIS Login project"
	@echo "Available commands:"
	@echo "  make start       - Run the QGIS Login project"
	@echo "  make start-dev   - Run the QGIS Login project in development mode"

db:
	@echo
	@echo "------------------------------------------------------------------"
	@echo "Running db container for QGIS Login project..."
	@echo "------------------------------------------------------------------"
	@docker compose -p $(PROJECT_ID) up -d db

# ----------------------------------------------------------------------------
#    P R O D U C T I O N     C O M M A N D S
# ----------------------------------------------------------------------------
start:
	@echo "Starting QGIS Login project..."
	docker compose -p $(PROJECT_ID) up -d

# ----------------------------------------------------------------------------
#    D E V E L O P M E N T     C O M M AN D S
# ----------------------------------------------------------------------------
start-dev: db
	@echo "Starting QGIS Login project in development mode..."
	docker compose -p $(PROJECT_ID) up --no-deps keycloak
