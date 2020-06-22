# Copyright (C) 2013-2020 Nicolas Lamirault <nicolas.lamirault@gmail.com>

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

BANNER = D I V O N A - R O L E S / B A S E
VERSION = 3.0.0

PYTHON3 = python3

ANSIBLE_VERSION = 2.9.9
MOLECULE_VERSION = 3.0.4
ANSIBLE_VENV = $(DIR)/venv
ANSIBLE_ROLES = $(DIR)/roles/

DEBUG ?=

SHELL = /bin/bash

DIR = $(shell pwd)

NO_COLOR=\033[0m
OK_COLOR=\033[32;01m
ERROR_COLOR=\033[31;01m
WARN_COLOR=\033[33;01m
INFO_COLOR=\033[36m
WHITE_COLOR=\033[1m

MAKE_COLOR=\033[33;01m%-20s\033[0m

.DEFAULT_GOAL := help

.DEFAULT_GOAL := help

OK=[✅]
KO=[❌]
WARN=[⚠️]


.PHONY: help
help:
	@echo -e "$(OK_COLOR)             $(BANNER)$(NO_COLOR)"
	@echo "------------------------------------------------------------------"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "${ERROR_COLOR}Usage${NO_COLOR}: make ${INFO_COLOR}<target>${NO_COLOR}\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  ${INFO_COLOR}%-25s${NO_COLOR} %s\n", $$1, $$2 } /^##@/ { printf "\n${WHITE_COLOR}%s${NO_COLOR}\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""

guard-%:
	@if [ "${${*}}" = "" ]; then \
		echo -e "$(ERROR_COLOR)Environment variable $* not set$(NO_COLOR)"; \
		exit 1; \
	fi

check-%:
	@if $$(hash $* 2> /dev/null); then \
		echo -e "$(OK_COLOR)$(OK)$(NO_COLOR) $*"; \
	else \
		echo -e "$(ERROR_COLOR)$(KO)$(NO_COLOR) $*"; \
	fi

print-%:
	@if [ "${$*}" == "" ]; then \
		echo -e "$(ERROR_COLOR)[KO]$(NO_COLOR) $* = ${$*}"; \
	else \
		echo -e "$(OK_COLOR)[OK]$(NO_COLOR) $* = ${$*}"; \
	fi

##@ Development

clean: ## Cleanup
	@echo -e "$(OK_COLOR)[$(BANNER)] Cleanup$(NO_COLOR)"
	@find . -name "*.retry"|xargs rm -fr {} \;
	@rm -fr roles


# ====================================
# A N S I B L E
# ====================================

##@ Ansible

.PHONY: ansible-init
ansible-init: ## Bootstrap Ansible
	@echo -e "$(OK_COLOR)[$(BANNER)] Install requirements$(NO_COLOR)"
	@test -d venv || $(PYTHON3) -m venv venv
	@. venv/bin/activate && pip3 install ansible==$(ANSIBLE_VERSION) molecule==$(MOLECULE_VERSION) docker yamllint

.PHONY: ansible-test
ansible-test: ## Test Ansible role
	@echo -e "$(OK_COLOR)[$(APP)] Verify Ansible$(NO_COLOR)"
	@. venv/bin/activate && molecule $(DEBUG) test
