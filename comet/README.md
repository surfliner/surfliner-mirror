# Comet

Comet is a staff facing digital object management system. Comet is based on
[Samvera][samvera] software and uses the [Hyrax][hyrax] engine.

[hyrax]: https://hyrax.samvera.org/
[samvera]: https://samvera.org/

# Setting up a development environment

The current practice for Comet development is to use a k3s variant and work in that with helm deployments.

Before you panic, it's not that hard...we are going to cover the TL;DR install for Macs and Windows machines.  We are also going to install a Rancher UI on the local k8s cluster to make things a little more friendly.

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
