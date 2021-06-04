.PHONY: run menu

menu:
	@echo 'build: Build a Starlight container image and push it to the k3d local registry'
	@echo 'clean: Delete the k3d/k3s cluster for Starlight'
	@echo 'deploy: Deploy the Starlight helm chart into the k3d/k3s cluster'
	@echo 'drop: Delete the namespace of the Starlight development deployment'
	@echo 'registry: Setup a k3d registry at k3d-registry.localhost'
	@echo 'setup: Create a surfliner-dev k3d/k3s cluster'
	@echo 'test: Run the Starlight test suite'

clean:
	scripts/k3d/clean.sh

deploy: setup
	scripts/k3d/deploy.sh

drop:
	scripts/k3d/drop.sh

build: registry
	scripts/k3d/build.sh

registry:
	scripts/k3d/registry.sh

setup:
	scripts/k3d/setup.sh

test:
	scripts/k3d/test.sh "$(TEST_ARGS)"
