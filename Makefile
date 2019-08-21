RUN_ARGS := $(strip $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS)) )# Strip off make target and obtain subsequent parameters.
$(eval $(RUN_ARGS):;@:) # ...and turn them into do-nothing targets

CLEANUP_FILES ?= $(CURRENT_DIR)_bundle_cache $(CURRENT_DIR)_socket_dir
CURRENT_DIR = $(notdir $(shell pwd))
DB_USER ?= $(USER)

.DEFAULT_GOAL := help
.PHONY: help

help:
	@grep -Eh '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

check_defined = \
    $(strip $(foreach 1,$1, \
        $(call __check_defined,$1,$(strip $(value 2)))))
__check_defined = \
    $(if $(value $1),, \
      $(error Undefined $1$(if $2, ($2))))

bash: ## Drop into a container shell. i.e. make bash app, make bash postgres
	@docker-compose run --rm $(RUN_ARGS) bash

binstall: ## bundle install: Runs bundle install within the app container to update the local Gemcache volume
	@docker-compose run --no-deps --rm app bundle install

bupdate: ## bundle update: Include "GEMS=<list>" to update gems. Leaving this variable out will do a full bundle install
	@:$(call check_defined, GEMS, gem list)
	@:$(call check_defined, ARTIFACTORY_CREDENTIALS, Artifactory Credentials were not automatically found)
	@docker-compose run --no-deps --rm app bundle update $(GEMS)

bupdate_full: ## full bundle update. You probably don't want to do this.
	@:$(call check_defined, ARTIFACTORY_CREDENTIALS, Artifactory Credentials were not automatically found)
	@docker-compose run --no-deps --rm app bundle update

cleanup: ## Remove volumes (not PGDATA), images, and stop containers created by this Makefile
	@docker-compose down --rmi local
	@docker volume rm $CLEANUP_FILES

dbcerts: ## Setup self signed certificates to be used with SSL & your database
	@echo "Creating certificates!"
	@mkdir -p ~/novu-data/ssl
	@openssl req -new -text -passout pass:abcd -subj /CN=localhost -keyout ~/novu-data/ssl/privkey.pem -out ~/novu-data/ssl/server.req
	@openssl rsa -in ~/novu-data/ssl/privkey.pem -passin pass:abcd -out ~/novu-data/ssl/server.key
	@openssl req -x509 -in ~/novu-data/ssl/server.req -text -key ~/novu-data/ssl/server.key -out ~/novu-data/ssl/server.crt
	@chmod og-rwx ~/novu-data/ssl/server.key

dbconsole: ## Open database console
	@docker-compose exec postgres psql -d $(DB_NAME) -U $(DB_USER)

dbmigrate: ## Runs rake migrate in the container.
	@docker-compose run --no-deps --rm app rake db:migrate

down: ## Shutdown your containers
	@docker-compose down

rake: ## Runs rake task(s) in the app container. Include "TASK=<tasks>" to specify tasks
	@docker-compose run --no-deps --rm app rake $(TASK)

rails: ## Runs rails commands in the app container. Include "COMMAND=<command>" to specify commands
	@docker-compose run --no-deps --rm app rails $(COMMAND)

railsc: ## Drop into a rails console in an already running container
	@docker-compose exec app rails c

test: ## Runs rspec in the app container. Example: make test spec/models/hermes/member_spec.rb
	@docker-compose run --no-deps --rm -e "RAILS_ENV=test" app rspec $(RUN_ARGS)

test_prepare: ## Prepares current project and novu_core test dbs
	@docker-compose run --no-deps --rm -e "RAILS_ENV=test" app rake db:test:prepare

up: ## Bring up all containers in the foreground, building if required
	@docker-compose up

upd: ## Bring up all containers in the background, building if required
	@docker-compose up -d
