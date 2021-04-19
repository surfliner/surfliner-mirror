.PHONY: run menu

menu:
	@echo 'build: Build a Comet container image and push it to the k3d local registry'
	@echo 'clean: Delete the surfliner-dev k3d/k3s cluster'
	@echo 'deploy: Deploy the Comet helm chart into the k3d/k3s cluster'
	@echo 'drop: Delete the namespace of the Comet development deployment'
	@echo 'registry: Setup a k3d registry at k3d-registry.localhost'
	@echo 'setup: Create a surfliner-dev k3d/k3s cluster'
	@echo 'setperms: Set permissions to allow pods to access local volumes'
	@echo 'test: Run the comet test suite'

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

setup: registry
	scripts/k3d/setup.sh

setperms:
	scripts/k3d/setperms.sh

test:
	scripts/k3d/test.sh
