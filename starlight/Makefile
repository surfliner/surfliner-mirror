.PHONY: run menu

menu:
	@echo 'build: Build a Starlight container image and push it to the k3d local registry'
	@echo 'clean: Delete the k3d/k3s cluster for Starlight'
	@echo 'deploy: Deploy the Starlight helm chart into the k3d/k3s cluster'
	@echo 'setup: Create a k3d/k3s cluster for Starlight'
	@echo 'shell: Enter a shell for the running Starlight application Pod'
	@echo 'test: Run the Starlight test suite'

clean:
	scripts/clean.sh

deploy: setup
	scripts/deploy.sh

build: setup
	scripts/build.sh

setup:
	scripts/setup.sh

shell:
	scripts/shell.sh

test:
	scripts/test.sh "$(TEST_ARGS)"
