# Comet

Comet is a staff facing digital object management system. Comet is based on
[Samvera][samvera] software and uses the [Hyrax][hyrax] engine.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Comet](#comet)
    - [Setting up a development environment](#setting-up-a-development-environment)
        - [Dependency installation for Mac and Windows](#dependency-installation-for-mac-and-windows)
        - [Provisioning the development environment](#provisioning-the-development-environment)

<!-- markdown-toc end -->

## Setting up a development environment

The current practice for Comet development is to use a `k3s` tool called `k3d`
which creates containerized `k3s` clusters.

You will need the following tools installed on your local machine:

* [Docker][docker]
* [kubectl][kubectl]
* [Helm][helm]
* [k3d][k3d]

Additionally, you will want some way of monitoring and managing the application
deployments into the `k3s` cluster. There are a variety of tools for doing this:

* [k9s][k9s] - A terminal-based tool for managing k8s clusters
* [Rancher][rancher] - Provides a very nice UI, but a heavier weight
    installation locally.
* Using `kubectl` and `helm` directly. There are times where this is best, but
    is likely a last resort for regular monitoring.

There are likely other tools in this space as well. As of this writing our team
currently has experience with both `k9s` and `Rancher`, so these are currently
recommended.

In general, it is advisable to keep all of these tools up to date. The
Kubernetes development space and related tooling moves quickly.

For Mac and Windows specific setup of the tooling above, see the section below.

### Dependency installation for Mac and Windows
For both environments, you need to install docker.

**Mac** https://docs.docker.com/docker-for-mac/install/

**Windows** https://docs.docker.com/docker-for-windows/install/

On a Mac, you will also need to install the Command Line Tools for Xcode.

`xcode-select --install`

The install process is much easier with a package manager.

For Mac, we use brew.  The install instructions are here: https://brew.sh/

`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

On Windows, we care going to use Chocolatey.  The install instructions are here: https://chocolatey.org/install

`Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))`

Now we need to install helm.

**Mac** https://helm.sh/docs/intro/install/

`brew install helm`

**Windows** https://helm.sh/docs/intro/install/

`choco install kubernetes-helm`

Then kubectl.

**Mac** https://kubernetes.io/docs/tasks/tools/install-kubectl-macos/#install-with-homebrew-on-macos

`brew install kubectl`

**Windows** https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/#install-on-windows-using-chocolatey-or-scoop

`choco install kubernetes-cli`

And finally, k3d.

**Mac** https://k3d.io/

`brew install k3d`

**Windows** https://k3d.io/

`choco install k3d`

### Provisioning the development environment

1. `make setperms` (currently we have to modify local file permissions because
   the Docker containers run as non-root)
1. `make setup` (create the K8s cluster, namespace, etc. if needed)
1. `make build` (create the Comet Docker image and push it to the local k3d
   registry)
1. `make deploy` (deploy Comet to the local k3d cluster)

#### Customizing Helm Values in Deployment
It may be the case that one needs to specify difference Helm values than are
used by the default `k3d.yaml` file. To do this:

- Create an additional `yaml` file with the values you need to update or change
- Export an environment variable name `LOCAL_VALUES_FILE` and set the value to
    the path to your `yaml` file
- Run `make deploy`

Example:

With a `yaml` file stored in `/tmp/local-comet-values.yaml`

```yaml
ingress:
  enabled: true
  hosts:
    - host: 'comet.k3d.my-server'
      paths: ['/']
```

```sh
export LOCAL_VALUES_FILE="/tmp/local-comet-values.yaml"
make deploy
```


[docker]: https://docs.docker.com/engine/install/
[helm]: https://helm.sh/docs/intro/install/
[hyrax]: https://hyrax.samvera.org/
[k3d]: https://github.com/rancher/k3d/#get
[k9s]: https://github.com/derailed/k9s
[kubectl]: https://kubernetes.io/docs/tasks/tools/
[rancher]: https://rancher.com/docs/rancher/v2.5/en/installation/install-rancher-on-k8s/
[samvera]: https://samvera.org/
