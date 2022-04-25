# docker/container guidelines and conventions

Because most of the applications we develop involve multiple interlocking
services, and because our team works in a variety of environments, we use
[containers][container] for both development and production.  In development we
use [docker-compose][docker-compose], and in production we use [Helm
charts][helm] to deploy images into [Kubernetes][k8s].

## we use pre-existing images when we can

Maintaining Docker images for containers requires ongoing work, so when there is
a suitable image available, we try to use it.  For many of the services our
applications depend on, we use [Bitnami][bitnami-docker] images.  They have the
advantage of being well-maintained and offer a consistent set of conventions
(e.g., data is always written to `/bitnami/<image-name>`).

## we follow these rules when we write our own images

When there is no suitable image already existing, we try to follow best
practices while writing our own.  This includes:

- [using `.dockerignore` to keep non-essential files out of the build context](../../../.dockerignore)
- [using multi-stage builds to keep the final image size small](https://www.augmentedmind.de/2022/02/06/optimize-docker-image-size/)
- [running as a non-root
  user](https://github.com/hexops/dockerfile#run-as-a-non-root-user)
- [capturing signals and processes with
  `tini`](https://github.com/hexops/dockerfile#use-tini-as-your-entrypoint)

See our [Comet image definition](../../../comet/Dockerfile) for an example of
these in practice.

[bitnami-docker]: https://hub.docker.com/u/bitnami/
[container]: https://www.redhat.com/en/topics/containers/whats-a-linux-container
[docker-compose]: https://docs.docker.com/compose/
[helm]: https://helm.sh/docs/
[k8s]: https://kubernetes.io
