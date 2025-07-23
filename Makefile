# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: daparici <daparici@student.42madrid.com    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/07/12 15:15:11 by daparici          #+#    #+#              #
#    Updated: 2025/07/23 23:17:30 by daparici         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

SHELL := /bin/bash
COMPOSE = docker compose
DOCKER = docker
SRC_DIR = ./srcs
PROJECT_NAME := inception
DATA_DIR = /home/daparici/data
SECRETS_DIR = ./secrets

SECRET_NAMES := DB_USER_PWD \
				DB_USER \
				DB_MASTER_USER \
				DB_MASTER_PWD \
				DB_NAME \
				WP_MASTER_USER \
				WP_MASTER_PWD \
				WP_MASTER_EMAIL \
				WP_USER_PWD \
				WP_USER \
				WP_USER_EMAIL \

# Get the absolute path of the Makefile's directory
MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
PROJECT_ROOT := $(dir $(MAKEFILE_PATH))
ABSOLUTE_SECRETS_DIR := $(PROJECT_ROOT)$(SECRETS_DIR:../=/)

.PHONY: create-secrets
create-secrets:
	@echo "Creating Docker secrets..."
	@for secret in $(SECRET_NAMES); do \
		SECRET_NAME=$$secret; \
		SECRET_FILE=$(ABSOLUTE_SECRETS_DIR)/$$SECRET_NAME.txt; \
		if $(DOCKER) secret inspect "$$SECRET_NAME" > /dev/null 2>&1; then \
			echo "Secret "$$SECRET_NAME" already exists."; \
		else \
			echo "Creating secret "$$SECRET_NAME" from "$$SECRET_FILE"..."; \
			$(DOCKER) secret create "$$SECRET_NAME" "$$SECRET_FILE"; \
		fi; \
	done
	@echo "Docker secrets creation complete."				


.PHONY: all
all: up

.PHONY: up
up: create-data-dirs create-secrets
	$(COMPOSE) -f $(SRC_DIR)/docker-compose.yml up --build -d

.PHONY: down
down:
	$(COMPOSE) -f $(SRC_DIR)/docker-compose.yml down

.PHONY: stop
stop:
	$(COMPOSE) -f $(SRC_DIR)/docker-compose.yml stop

.PHONY: start
start:
	$(COMPOSE) -f $(SRC_DIR)/docker-compose.yml start

.PHONY: restart
restart: stop start

.PHONY: clean
clean:
	$(COMPOSE) -f $(SRC_DIR)/docker-compose.yml down
	$(COMPOSE) -f $(SRC_DIR)/docker-compose.yml rm -f
	docker image prune -a -f
	docker volume prune -f
	sudo rm -rf $(DATA_DIR)/* # Remove all contents of DATA_DIR
	rmdir $(DATA_DIR) 2>/dev/null || true # Remove DATA_DIR if empty

.PHONY: fclean
fclean: clean
	docker secret rm $(SECRET_NAMES) 2>/dev/null || true
	docker volume rm srcs_Mariadb_volumen srcs_web_volumen 2>/dev/null || true
	# Remove secrets and project volumes, ignore errors if they don't exist

.PHONY: clean-volumes
clean-volumes:
	$(COMPOSE) -f $(SRC_DIR)/docker-compose.yml down -v
	docker volume rm srcs_Mariadb_volumen srcs_web_volumen 2>/dev/null || true

.PHONY: logs
logs:
	$(COMPOSE) -f $(SRC_DIR)/docker-compose.yml logs --tail=50

.PHONY: ps
ps:
	$(COMPOSE) -f $(SRC_DIR)/docker-compose.yml ps

.PHONY: exec-nginx
exec-nginx:
	docker exec -it nginx bash

.PHONY: exec-wordpress
exec-wordpress:
	docker exec -it wp-php bash

.PHONY: exec-mariadb
exec-mariadb:
	docker exec -it mariadb bash

.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make up          - Start and build the containers."
	@echo "  make down        - Stop the containers."
	@echo "  make restart     - Restart the containers."
	@echo "  make clean       - Remove all volumes, images, and data."
	@echo "  make fclean      - Run clean and remove Docker secrets."
	@echo "  make logs        - Show recent logs."
	@echo "  make ps          - Show running containers."
	@echo "  make exec-nginx  - Access the Nginx container."
	@echo "  make exec-wordpress  - Access the WordPress container."
	@echo "  make exec-mariadb  - Access the MariaDB container."

.PHONY: create-data-dirs
create-data-dirs:
	mkdir -p $(DATA_DIR)/mariadb
	mkdir -p $(DATA_DIR)/wordpress


