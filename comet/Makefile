.PHONY: run menu

menu:
	@echo 'build: Build a Comet container image and push it to the k3d local registry'
	@echo 'clean: Delete the surfliner-dev k3d/k3s cluster'
	@echo 'deploy: Deploy the Comet helm chart into the k3d/k3s cluster'
	@echo 'drop: Delete the namespace of the Comet development deployment'
	@echo 'setup: Create a surfliner-dev k3d/k3s cluster'
	@echo 'setperms" Set permissions to allow pods to access local volumes'

clean:
	scripts/k3d/clean.sh

deploy: setup
	scripts/k3d/deploy.sh

drop:
	scripts/k3d/drop.sh

build: setup
	scripts/k3d/build.sh

setup:
	scripts/k3d/setup.sh

setperms:
	scripts/k3d/setperms.sh
