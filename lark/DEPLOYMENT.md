# Deploying Lark

The Lark API service is a vanilla Ruby application with relatively few system
dependencies. A simple deployment could be a single server running Solr,
Postgresql, and the Lark application (`rackup config.ru`). To support more
robust, cloud-native deployments we maintain a [Docker][docker] image and a
[Helm][helm] [chart for deploying Lark][lark-chart] and its dependencies to
[Kubernetes][k8s].

## Docker Images

The `lark_web` docker images are made available in the [GitLab Container
Registry][gitlab-registry] via
`registry.gitlab.com/surfliner/surfliner/lark_web`. These images are built
automatically by our CI/CD pipeline throughout our development process. We
maintain two images for general use:

<dl>
  <dt>`stable`</dt>
  <dd>Surfliner's current deployed version. This image is updated whenever the
    Surfliner team deploys `lark` to production.</dd>
  <dt>`master`</dt>
  <dd>The current `master`. This image is updated whenever code is merged
    to `master`.</dd>
</dl>

We **strongly** reccomend using the `stable` tag
(`registry.gitlab.com/surfliner/surfliner/lark_web:stable`) for deployments.
Since the Surfliner team strives to achieve [Continuous Deployment][cd], it
will lag only slightly behind `master`. The gap time is accounted for by our
Staging deployments and manual review.

## Helm Chart

The Helm chart provides for automated deployment and maintenance of Lark in a
Kubernetes cluster. Surfliner charts are maintained [directly in this
repository][charts], we don't currently publish them elsewhere.

If you have a properly configured [helm installation] pointing at a Kubernetes
cluster, you can deploy `lark` with:

```sh
git clone git@gitlab.com:surfliner/surfliner.git
helm install surfliner/charts/lark/latest
```

Consider reviewing the chart's [app-readme.md][lark-chart-readme] and
[values.yaml][lark-chart-values] before deploying.

[cd]: https://www.agilealliance.org/glossary/continuous-deployment
[charts]: ../charts/
[docker]: https://www.docker.com
[gitlab-registry]: https://docs.gitlab.com/ee/user/project/container_registry.html#gitlab-container-registry
[helm]: https://helm.sh
[helm-installation]: https://helm.sh/docs/using_helm/#installing-helm
[kubernetes]: https://kubernetes.io
[lark-chart]: ../charts/lark/latest
[lark-chart-readme]: ../charts/lark/latest/app-readme.md
[lark-chart-values]: ../charts/lark/latest/values.yaml
