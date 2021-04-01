.PHONY: run menu

menu:
	@echo 'build: Build a Comet container image and push it to the k3d local registry'
	@echo 'clean: Delete the surfliner-dev k3d/k3s cluster'
	@echo 'deploy: Deploy the Starlight helm chart into the k3d/k3s cluster'
	@echo 'setup: Create a surfliner-dev k3d/k3s cluster'

clean:
	scripts/clean.sh

deploy: setup
	scripts/deploy.sh

build: setup
	scripts/build.sh

setup:
	scripts/setup.sh
