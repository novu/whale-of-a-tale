RUN_ARGS := $(strip $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS)) )# Strip off make target and obtain subsequent parameters.
$(eval $(RUN_ARGS):;@:) # ...and turn them into do-nothing targets

CLEANUP_FILES ?= $(CURRENT_DIR)_redis $(CURRENT_DIR)_node_modules $(CURRENT_DIR)_bundle
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

sh: ## Drop into a container shell. i.e. make sh web, make sh postgres
	@docker-compose run --rm $(RUN_ARGS) sh

binstall: ## bundle install: Runs bundle install within the web container to update the local Gemcache volume
	@docker-compose run --no-deps --rm web bundle install

bupdate: ## bundle update: Include "GEMS=<list>" to update gems. Leaving this variable out will do a full bundle install
	@:$(call check_defined, GEMS, gem list)
	@docker-compose run --no-deps --rm web bundle update $(GEMS)

bupdate_full: ## full bundle update. You probably don't want to do this.
	@docker-compose run --no-deps --rm web bundle update

cleanup: ## Remove volumes (not PGDATA), images, and stop containers created by this Makefile
	@docker-compose down --rmi local
	@docker volume rm $CLEANUP_FILES

dbcerts: ## Setup self signed certificates to be used with SSL & your database. This lets you use ssl with your docker db!
	@echo "Creating certificates!"
	@mkdir -p tmp/whale-data/ssl
	@openssl req -new -text -passout pass:abcd -subj /CN=localhost -keyout tmp/whale-data/ssl/privkey.pem -out tmp/whale-data/ssl/server.req
	@openssl rsa -in tmp/whale-data/ssl/privkey.pem -passin pass:abcd -out tmp/whale-data/ssl/server.key
	@openssl req -x509 -in tmp/whale-data/ssl/server.req -text -key tmp/whale-data/ssl/server.key -out tmp/whale-data/ssl/server.crt
	@chmod og-rwx tmp/whale-data/ssl/server.key

dbconsole: ## Open database console
	@docker-compose exec postgres psql -d $(DB_NAME) -U $(DB_USER)

dbmigrate: ## Runs rake migrate in the container.
	@docker-compose run --no-deps --rm web rake db:migrate

down: ## Shutdown your containers
	@docker-compose down

rake: ## Runs rake task(s) in the web container. Include "TASK=<tasks>" to specify tasks
	@docker-compose run --no-deps --rm web rake $(TASK)

rails: ## Runs rails commands in the web container. Include "COMMAND=<command>" to specify commands
	@docker-compose run --no-deps --rm web rails $(COMMAND)

railsc: ## Drop into a rails console in an already running container
	@docker-compose run --rm web rails c

test: ## Runs rspec in the web container. Example: make test spec/models/my_app/member_spec.rb
	@docker-compose run --rm -e "RAILS_ENV=test" web rspec $(RUN_ARGS)

test_prepare: ## Prepares current project test dbs
	@docker-compose run --no-deps --rm -e "RAILS_ENV=test" web rake db:test:prepare

up: ## Bring up all containers in the foreground, building if required
	@docker-compose up

upd: ## Bring up all containers in the background, building if required
	@docker-compose up -d