.PHONY: build install test
SHELL=/bin/bash

install: install_oic_darwin
	@echo "-> Done installing"

install_oic_darwin:
	@echo "-> Install headers for ruby-oic8 (Darwin)" && \
		bash ./scripts/install-ruby-oic8.sh Darwin
	@echo "-> Bundle install" && \
		OCI_DIR="$(shell pwd)/vendor/oracle/Darwin/instantclient_12_2" \
		BUNDLE_PATH="vendor/bundle-darwin" \
		bundle install 1>/dev/null

install_oic_linux: create_bundler_image
	@echo "-> Extracting files for ruby-oic8 (Linux)" && \
		bash ./scripts/install-ruby-oic8.sh Linux
	@echo "-> Installing dependencies" && \
		docker run \
		--env LD_LIBRARY_PATH=/app/vendor/oracle/Linux/instantclient_12_2 \
		--env BUNDLE_PATH=/app/vendor/bundle-linux \
		--rm -v "$(shell pwd)":/app -w /app bundler:2.1.4 \
		bundle install 1>/dev/null

create_bundler_image:
	@echo "-> Creating bundler docker image" &&\
		docker build \
		-t bundler:2.1.4 \
		-f bundler.Dockerfile \
		- < bundler.Dockerfile 1>/dev/null

build: build_bundler_layer
	@echo "-> Building lambda package"

build_bundler_layer: install_oic_linux
	@echo "-> Building lambda bundler layer"
	@cd vendor/bundle-linux/ && \
		zip -r ../../dist/bundler-layer.zip ./ 1>/dev/null

test:
	@echo "-> Testing $(shell uname)"
	@make test_$(shell uname | tr '[:upper:]' '[:lower:]')

test_integration:
	@echo "-> Testing $(shell uname)"
	@make test_integration_$(shell uname | tr '[:upper:]' '[:lower:]')

test_e2e:
	@echo "-> Testing $(shell uname)"
	@make test_e2e_$(shell uname | tr '[:upper:]' '[:lower:]')

test_all:
	@echo "-> Testing $(shell uname)"
	@make test_all_$(shell uname | tr '[:upper:]' '[:lower:]')

test_darwin: install
	@echo "-> Running tests (Darwin)" && \
		BUNDLE_PATH="vendor/bundle-darwin" \
		bundle exec rspec --exclude-pattern "**/integration/*_spec.rb, **/e2e/*_spec.rb"

test_integration_darwin: install
	@echo "-> Running tests (Darwin)" && \
		BUNDLE_PATH="vendor/bundle-darwin" \
		bundle exec rspec spec/integration

test_e2e_darwin: install
	@echo "-> Running tests (Darwin)" && \
		BUNDLE_PATH="vendor/bundle-darwin" \
		bundle exec rspec spec/e2e

test_all_darwin: install
	@echo "-> Running tests (Darwin)" && \
		BUNDLE_PATH="vendor/bundle-darwin" \
		bundle exec rspec

test_linux: install_oic_linux
	@echo "-> Running tests (Linux)" && \
		docker run \
		--env LD_LIBRARY_PATH=/app/vendor/oracle/Linux/instantclient_12_2 \
		--env BUNDLE_PATH=/app/vendor/bundle-linux \
		--rm -v "$(shell pwd)":/app -w /app bundler:2.1.4 \
		bundle exec rspec --exclude-pattern "**/integration/*_spec.rb, **/e2e/*_spec.rb"

test_integration_linux: install_oic_linux
	@echo "-> Running tests (Linux)" && \
		docker run \
		--env LD_LIBRARY_PATH=/app/vendor/oracle/Linux/instantclient_12_2 \
		--env BUNDLE_PATH=/app/vendor/bundle-linux \
		--rm -v "$(shell pwd)":/app -w /app bundler:2.1.4 \
		bundle exec rspec spec/integration

test_e2e_linux: install_oic_linux
	@echo "-> Running tests (Linux)" && \
		docker run \
		--env LD_LIBRARY_PATH=/app/vendor/oracle/Linux/instantclient_12_2 \
		--env BUNDLE_PATH=/app/vendor/bundle-linux \
		--rm -v "$(shell pwd)":/app -w /app bundler:2.1.4 \
		bundle exec rspec spec/e2e

test_all_linux: install_oic_linux
	@echo "-> Running tests (Linux)" && \
		docker run \
		--env LD_LIBRARY_PATH=/app/vendor/oracle/Linux/instantclient_12_2 \
		--env BUNDLE_PATH=/app/vendor/bundle-linux \
		--rm -v "$(shell pwd)":/app -w /app bundler:2.1.4 \
		bundle exec rspec
